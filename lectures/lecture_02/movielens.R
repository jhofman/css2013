require(data.table)    # install.packages('data.table')
require(plyr)    # install.packages('plyr')
require(ggplot2) # install.packages('ggplot2')
require(scales)    # install.packages('scales')

# todo: global figure style
theme_set(theme_bw())

data.dir <- '../../data/movielens'

# read ratings from csv file
system.time(
  ratings <- read.delim(sprintf('%s/movielens_10M/ratings.csv', data.dir),
                        sep=',', header=F,
                        col.names=c('user.id','movie.id','rating','timestamp'),
                        colClasses=c('integer','integer','numeric','integer'))
)
print(object.size(ratings), units="Mb")

####################
# brief look at data
####################

head(ratings)
nrow(ratings)
str(ratings)

# convert to data table for quick aggregations
ratings <- data.table(ratings)

####################
# aggregate stats
####################

# compute aggregate stats
summary(ratings$rating)

# plot distribution of ratings
p <- ggplot(data=ratings, aes(x=rating))
p <- p + geom_histogram()
p <- p + scale_y_continuous(labels=comma)
p <- p + xlab('Rating') + ylab('Count')
ggsave(p, file="figures/rating_dist.pdf", width=4, height=4)


####################
# per-movie stats
####################

# group ratings by movie
setkey(ratings, "movie.id")

# aggregate ratings by movie, computing mean and number of ratings
movie.stats <- ratings[, list(num.ratings=length(rating), mean.rating=mean(rating)), by="movie.id"]

# compare to:
# movie.stats <- ddply(ratings, "movie.id", summarize,
#                            num.ratings=length(rating),
#                            mean.rating=mean(rating))

# compute movie-level summary stats
summary(movie.stats)

# plot distribution of movie popularity
p <- ggplot(data=movie.stats, aes(x=num.ratings))
p <- p + geom_histogram()
p <- p + scale_x_continuous(labels=comma)
p <- p + scale_y_continuous(labels=comma)
p <- p + xlab('Number of Ratings by Movie') + ylab('Count')
ggsave(p, file="figures/movie_popularity_dist.pdf", width=4, height=4)

# plot distribution of mean ratings by movie
p <- ggplot(data=movie.stats, aes(x=mean.rating))
p <- p + stat_density()
p <- p + scale_x_continuous(labels=comma)
p <- p + scale_y_continuous(labels=comma)
p <- p + theme(axis.text.y=element_blank(), axis.ticks.y=element_blank())
p <- p + xlab('Mean Rating by Movie') + ylab('Density')
ggsave(p, file="figures/mean_rating_by_movie_dist.pdf", width=4, height=4)

# rank movies by popularity and compute cdf
setkey(movie.stats, "num.ratings")
movie.stats <- transform(movie.stats,
                         rank=rank(-num.ratings),
                         cdf=rev(cumsum(rev(num.ratings)))/sum(num.ratings))

# plot CCDF of movie popularity
p <- ggplot(data=movie.stats, aes(x=rank, y=cdf))
p <- p + geom_line()
p <- p + scale_x_continuous(labels=comma)
p <- p + scale_y_continuous(labels=percent)
p <- p + xlab('Movie Rank') + ylab('CDF')
ggsave(p, file="figures/movie_popularity_cdf.pdf", width=4, height=4)


####################
# per-user stats
####################

# group ratings by user
setkey(ratings, "user.id")

# aggregate ratings by user, computing mean and number of ratings
user.stats <- ratings[, list(num.ratings=length(rating), mean.rating=mean(rating)), by="user.id"]

# compute user-level stats
summary(user.stats)

# plot distribution of user activity
p <- ggplot(data=user.stats, aes(x=num.ratings))
p <- p + geom_histogram()
p <- p + scale_x_continuous(labels=comma)
p <- p + scale_y_continuous(labels=comma)
p <- p + xlab('Number of Ratings by User') + ylab('Count')
ggsave(p, file="figures/user_activity_dist.pdf", width=4, height=4)


ratings.with.movie.stats <- merge(ratings, movie.stats, by="movie.id")

setkey(ratings.with.movie.stats, "user.id")
user.stats <- ratings.with.movie.stats[, list(median.rank=median(rank)), by="user.id"]

# plot distribution of user eccentricity
p <- ggplot(data=user.stats, aes(x=median.rank))
p <- p + stat_density()
p <- p + scale_x_log10(labels=comma)
p <- p + scale_y_continuous(labels=comma)
p <- p + theme(axis.text.y=element_blank(), axis.ticks.y=element_blank())
p <- p + xlab('User eccentricity') + ylab('Density')
ggsave(p, file="figures/user_eccentricity_dist.pdf", width=4, height=4)


