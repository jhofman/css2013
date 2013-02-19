import mr
import itertools
import string

def word_split(lines):
	words = []
	for line in lines:
		words += line.split()

	words = [word.lower().translate(string.maketrans("",""), string.punctuation).strip() for word in words]
	words = [word for word in words if word]
		
	return words
		
def count_grouped_words(lines):
	c = []
	for k, val in itertools.groupby(lines, key=mr.first_col):
		out = k + '\t' + str(len(list(val)))
		c.append(out)
	return c

mr.mr(word_split, count_grouped_words, 'shakespeare/parts/*', 
	output_dir = 'foo_output', 
	shuffle_dir = 'foo_shuffled',
	parallelism=2)
