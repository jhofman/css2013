'''

mr.py is a single-machine, parallel implementation of map-reduce.

Example usage: word count
  python mr.py -m 'tr " " "\n"' -r 'uniq -c' -i INPUT_FILES -o OUTPUT_DIR


'''

import sys
import os
import multiprocessing
import subprocess
from subprocess import PIPE
import itertools
import argparse
import logging
import tempfile
import shutil
import glob

### extract the 1st tab-separated column from a line ###
def first_col(line):
	return line.split('\t',1)[0]

### construct a wrapper around a shell command ###
def construct_stream_func(cmd):
	logger = logging.getLogger("MR")
	
	def f(data):
		try:
			p = subprocess.Popen(cmd, stdin=PIPE, stdout=PIPE, stderr=PIPE, shell=True)
			data_str = '\n'.join(data) + '\n'
			std_out, std_err = p.communicate(data_str)
		except:
			logger.error('UNEXCEPTED ERROR IN %s: %s' % (cmd, sys.exc_info()[0]))
			raise
	
		if std_err:
			logger.error('UNEXCEPTED ERROR IN %s: %s' % (cmd, std_err))
			raise Exception()
			
		output_lines = std_out.splitlines()
		return output_lines
	
	return f

### set up the mapper that operates on a single input file ###
def mapper((map_func, key_func, input_file, output_dir, num_part_files, file_locks)):
	
	logger = logging.getLogger("MR")
	
	if type(map_func) == str:
		map_func = construct_stream_func(map_func)
	if type(key_func) == str:
		key_func = construct_stream_func(key_func)
	
	try:
		with open(input_file) as f:
			lines = f.read().splitlines()
		
		output = map_func(lines)
	except IOError as e:
		logger.error('CANNOT OPEN FILE: %s' % input_file)
		raise
	except:
	    logger.error('UNEXCEPTED ERROR IN MAPPER: %s' % sys.exc_info()[0])
	    raise
		
	## shuffle the map output ##
	buckets = [[] for i in range(num_part_files)]
	
	for line in output:
		key = key_func(line)
		bucket = hash(key) % num_part_files
		buckets[bucket].append(line)
		
	for ndx, bucket in enumerate(buckets):
		file_locks[ndx].acquire()
			
		fname = os.path.join(output_dir, 'part-%05d' % ndx)
		with open(fname, 'a') as f:
		    f.write('\n'.join(bucket) + '\n')
				
		file_locks[ndx].release()
			
### set up the reducer that operates on a single input file ###
def reducer((reduce_func, input_file, output_file)):
	
	logger = logging.getLogger("MR")
		
	if type(reduce_func) == str:
		reduce_func = construct_stream_func(reduce_func)
		
	try:
		with open(input_file) as f:
			lines = f.read().splitlines()
		
		lines.sort()
		output = reduce_func(lines)
	except IOError as e:
		logger.error('CANNOT OPEN FILE: %s' % input_file)
		raise
	except:
	    logger.error('UNEXCEPTED ERROR IN REDUCER: %s' % sys.exc_info()[0])
	    raise
		
	with open(output_file, 'w') as f:
	    f.write('\n'.join(output) + '\n')

			
### the primary MapReduce function ###
def mr(f_map, f_reduce, input_files, output_dir, f_key=first_col, 
	shuffle_dir=None, parallelism=1, num_part_files=None, verbose=True):
	
	### setup logging ###
	if verbose:
		logging_level = logging.INFO
	else:
		logging_level = logging.ERROR
	logging.basicConfig(level=logging_level, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")
	logger = logging.getLogger("MR")
	
	# parse the input file list if necessary
	if type(input_files) == str:
		input_files = glob.glob(input_files)
	if len(input_files) == 0:
		logger.error('NO VALID INPUT FILES SPECIFIED')
		sys.exit()
	
	# validate or set the number of part files #
	if num_part_files and num_part_files <= 0:
		logger.error('INVALID NUMBER OF PART FILES SPECIFIED')
		sys.exit(1)
	
	if not num_part_files:
		num_part_files = len(input_files)
	
	# set up locks for file write sync during shuffle #
	manager = multiprocessing.Manager()
	locks = [manager.Lock() for i in range(num_part_files)]
	
	# create output directory #	
	try:
		os.mkdir(output_dir)
	except:	
		logger.error('OUTPUT DIRECTORY COULD NOT BE CREATED')
		sys.exit(1)
		
	# create shuffle directory #
	if shuffle_dir:
		delete_shuffle_dir = False
		try:
			os.mkdir(shuffle_dir)
		except:
			logger.error('SHUFFLE DIRECTORY COULD NOT BE CREATED: %s' % shuffle_dir)
			sys.exit(1)
	else: 
		shuffle_dir = tempfile.mkdtemp()
		delete_shuffle_dir = True		
	
	for ndx in range(num_part_files):
		fname = os.path.join(shuffle_dir, 'part-%05d' % ndx)
		f = open(fname, 'w')
		f.close()
		
	# map #
	logger.info('STARTING MAP')
	args = [(f_map, f_key, input_file, shuffle_dir, num_part_files, locks) for input_file in input_files]
	if parallelism > 1:
		pool = multiprocessing.Pool(parallelism)
		pool.map(mapper, args)
		pool.close()
		pool.join()
	else:
		map(mapper, args)
	logger.info('MAP COMPLETE')
			
	if f_reduce:
		# reduce #	
		logger.info('STARTING REDUCE')
		f_input = [os.path.join(shuffle_dir, 'part-%05d' % ndx) for ndx in range(num_part_files)]
		f_output = [os.path.join(output_dir, 'part-%05d' % ndx) for ndx in range(num_part_files)]
		args = [(f_reduce, f_input[ndx], f_output[ndx]) for ndx in range(num_part_files)]
		if parallelism > 1:
			pool = multiprocessing.Pool(parallelism)
			pool.map(reducer, args)
			pool.close()
			pool.join()
		else:
			map(reducer, args)
		logger.info('REDUCE COMPLETE')
	else:
		# copy files from shuffle directory to output directory #
		for ndx in range(num_part_files):
			src = os.path.join(shuffle_dir, 'part-%05d' % ndx)
			dest = os.path.join(output_dir, 'part-%05d' % ndx)
			shutil.copyfile(src, dest)
				
	# delete the temporary shuffle directory #
	if delete_shuffle_dir:
		shutil.rmtree(shuffle_dir)
	
		
if __name__ == "__main__":
	
	### parse command-line args ###
	parser = argparse.ArgumentParser(description='Local MapReduce', add_help=False)
	parser.add_argument('-m', dest='map_cmd', default='cat')
	parser.add_argument('-r', dest='reduce_cmd', default=None)
	parser.add_argument('-i', dest='input_files', required=True, metavar='INPUT_FILE', nargs='+')
	parser.add_argument('-o', dest='output_dir', required=True)
	parser.add_argument('-s', dest='shuffle_dir', default=None)
	parser.add_argument('-p', dest='num_cores', type=int, default=1)
	parser.add_argument('-n', dest='num_part_files', type=int, default=None)
	parser.add_argument('-v', dest='verbose', action='store_true')
	params = parser.parse_args()
	
	if not params.num_part_files:
		params.num_part_files = len(params.input_files)
	
	### run the MR job ###
	mr(params.map_cmd, params.reduce_cmd, params.input_files, params.output_dir, first_col,
		params.shuffle_dir, params.num_cores, params.num_part_files, params.verbose)
