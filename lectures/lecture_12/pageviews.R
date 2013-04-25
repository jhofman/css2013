require('plyr')
require('ggplot2')
require('scales')
theme_set(theme_bw())

#
# function to compute geometric mean
#
geom.mean <- function(x,dx=0.01) {
  10^mean(log10(x+dx))-dx
}


# read user pageview data
users <- read.table('users.tsv', header=T, sep="\t")


# plot distribution of daily pageviews across all users
p <- ggplot(data=users, aes(x=daily.views))
p <- p + geom_histogram()
p <- p + scale_x_log10(label=comma, breaks=10^(0:ceiling(log10(max(users$daily.views)))))
p <- p + scale_y_continuous(label=comma)
p <- p + xlab('Daily pageviews') + ylab('')
ggsave(p, filename='figures/daily_pageviews_dist.pdf', width=4, height=4)


# plot all daily pageviews by age, faceted by gender
p <- ggplot(data=users, aes(x=age, y=daily.views))
p <- p + geom_point()
p <- p + facet_wrap(~ gender)
p <- p + xlab('Age') + ylab('Daily pageviews')
ggsave(p, filename='figures/daily_pageviews_by_age_and_gender.pdf', width=8, height=4)


# plot median daily pageviews by age, faceted by gender
views.by.age.gender <- ddply(subset(users, age <= 90),
                             c("age","gender"),
                             summarize,
                             median.daily.views=median(daily.views),
                             geom.mean.daily.views=geom.mean(daily.views),
                             num.users=length(daily.views))
p <- ggplot(data=views.by.age.gender, aes(x=age, y=median.daily.views, colour=gender))
p <- p + geom_line(aes(linetype=gender))
p <- p + xlab('Age') + ylab('Daily pageviews')
p <- p + theme(legend.title=element_blank(), legend.position=c(0.9,0.85))
ggsave(p, filename='figures/median_daily_pageviews_by_age_and_gender.pdf', width=8, height=4)


# model daily pageviews by age and gender
adults <- subset(users, age >= 18 & age <= 65)
model <- lm(log10(daily.views+0.01) ~ 1 + age + I(age^2) + gender + age*gender + I(age^2)*gender, data=adults)
model.adults <- expand.grid(age=18:65, gender=factor(c('Male','Female')))
model.adults$daily.views <- 10^predict(model, model.adults)-0.1


# plot modeled pageviews
plot.data <- merge(model.adults, views.by.age.gender, by=c("age", "gender"))
p <- ggplot(data=plot.data, aes(x=age, y=daily.views, colour=gender))
p <- p + geom_line(aes(linetype=gender))
p <- p + geom_point(aes(x=age, y=geom.mean.daily.views, shape=gender))
p <- p + xlab('Age') + ylab('Daily pageviews')
p <- p + theme(legend.title=element_blank(), legend.position=c(0.9,0.85))
ggsave(p, filename='figures/modeled_daily_pageviews_by_age_and_gender.pdf', width=8, height=4)
