-- streaming command to number lines
DEFINE number_lines `awk '{print NR"\t"$0}'`;

-- load the data
views = LOAD 'movies.tsv' AS (user:long, movie:long);

-- compute the popularity of each movie
movie_popularity = GROUP views BY movie;
movie_popularity = FOREACH movie_popularity GENERATE
	group AS movie,
	COUNT(views) AS count;

-- sort and rank the movies
movie_popularity = ORDER movie_popularity BY count, movie DESC PARALLEL 1;
movie_popularity = STREAM movie_popularity THROUGH number_lines
	AS (rank:long, movie:long, count:long);

-- join views with movie rank
views = JOIN views BY movie, movie_popularity by movie;
views = FOREACH views GENERATE
	views::user AS user,
	movie_popularity::rank AS movie_rank;

-- compute average eccentricity for each user
eccentricity = GROUP views BY user;
eccentricity = FOREACH eccentricity GENERATE
 	group AS user,
	AVG(views.movie_rank) AS avg_movie_rank;

-- store results
STORE movie_popularity INTO 'eccentricity/movie_popularity';
STORE views INTO 'eccentricity/augmented_views';
STORE eccentricity INTO 'eccentricity/user_eccentricity';
