library(data.table)
library(magrittr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(gapminder)
library(ggrepel)
library(GGally)
library(pheatmap)
library(mclust)

instagram_self <- fread(file.path("Bachelorarbeit data", "instacomments_shortlisted_labelled_updated.csv"))

instagram_self_dt <- as.data.table(instagram_self)
instagram_self_wocomments <- instagram_self_dt[, -c("Comment ID", "Comment", "Background sound / audio", "Post ID")]


instagram_self_woaudio <- instagram_self_dt[, -c("Comment ID", "Comment", "Background sound / audio", "Post ID")]

instagram_self_themes <- separate_rows(instagram_self_wocomments, `Post themes`, sep = ',')
instagram_self_themes <- mutate(instagram_self_themes, `Post themes` = trimws(`Post themes`))

instagram_self_woaudio <- separate_rows(instagram_self_woaudio, `Post themes`, sep = ',')
instagram_self_woaudio <- mutate(instagram_self_woaudio, `Post themes` = trimws(`Post themes`))

instagram_self_final <- instagram_self_themes

instagram_self_woaudio <- as.data.table(instagram_self_woaudio)
instagram_self_woaudio <- instagram_self_woaudio[, .(`Post themes count` = .N , `Average harm score` = mean(`Harm score`, na.rm = TRUE)), by = `Post themes`]
instagram_self_woaudio_noNA <- drop_na(instagram_self_woaudio)
instagram_self_woaudio_clean <- instagram_self_woaudio_noNA[`Post themes` != ""]


ggplot(instagram_self_woaudio_clean, aes(x = `Post themes count`, y = `Average harm score`)) + geom_point() + labs(title = "Average harm score given by us vs count of post themes (Insta)") + theme_bw()
summary(lm(`Post themes count` ~ `Average harm score`, instagram_self_woaudio_clean))


instagram_self_final <- as.data.table(instagram_self_final)
instagram_self_final <- drop_na(instagram_self_final)
instagram_self_final <- instagram_self_final[`Post themes` != ""]

instagram_self_final[, `Harm scores` := factor(`Harm score`,
                                            levels = c(0, 0.25, 0.5, 0.75, 1),
                                            labels = c("0", "0.25", "0.5", "0.75", "1"))]



# Count number of posts grouped by theme and harm score bin 
heatmap_values_self <- instagram_self_final[, .N, by = .(`Post themes`, `Harm scores`)]

# cast data to wide format
heatmap_valuescasted_self <- dcast(heatmap_values_self, `Post themes` ~ `Harm scores`, value.var = "N")

# set rownames
matrix_self <- as.matrix(heatmap_valuescasted_self[, -1])

rownames(matrix_self) <- heatmap_valuescasted_self$`Post themes`


pheatmap(matrix_self, cluster_rows = F, cluster_cols = F, main = "Heatmap of harm scores given by us (Insta)", angle_col = 315)
pheatmap(matrix_self, cluster_rows = F, cluster_cols = T, main = "Heatmap of harm scores given by us (Insta)", angle_col = 315) 


matrix_self[(is.na(matrix_self))] <- 0
matrix_self_scaled <- matrix_self / rowSums(matrix_self)
rownames(matrix_self_scaled) <- heatmap_valuescasted_self$`Post themes`

pheatmap(matrix_self_scaled, cluster_rows = T, cluster_cols = F, main = "Heatmap of harm scores given by us (Insta)", angle_col = 315)
pheatmap(matrix_self_scaled, cluster_rows = T, cluster_cols = T, main = "Heatmap of harm scores given by us (Insta)", angle_col = 315)


#ggplot(instagram_self_final, aes(x = `Harm score`)) + geom_density(alpha = 0.4) + facet_wrap( ~ `Post themes`) + ylim(0, 10)
#ggplot(instagram_self_final, aes(x = `Harm score`)) + geom_density(alpha = 0.4) + facet_wrap( ~ `Post themes`) + ylim(0, 5)
ggplot(instagram_self_final, aes(x = `Harm score`)) + geom_density() + facet_wrap( ~ `Post themes`) + ylim(0, 2) + labs(title = "Density plots of our harm scores by theme (Insta)", x = "Harm score", y = "Density") + theme_bw() + theme(axis.text.x = element_text(angle = 45, hjust = 1), strip.text = element_text(size = 7))

#ggplot(instagram_self_final, aes(x = `Harm score`)) + geom_density(alpha = 0.8) + facet_wrap( ~ `Post themes`) + ylim(0, 2) + labs(title = "Density plots of our harm scores by theme") + theme_minimal()


ggplot(instagram_self_final, aes(factor(`Harm score`))) +
  geom_bar(fill = "steelblue") +
  labs(title = "Distribution of Harm scores given by us (Insta)", x = "Harm Score", y = "Count") +
  theme_bw() #this works

instagram_self_nonzero <- instagram_self_final[`Harm score` != 0]

ggplot(instagram_self_nonzero, aes(factor(`Post themes`))) +
  geom_bar(fill = "steelblue") +
  labs(title = "Distribution of non Zero Harm scores given by us (Insta)", x = "Harm Score", y = "Count") +
  theme_bw() + theme(axis.text.x = element_text(angle=45, hjust=1)) #this works

ggplot(instagram_self_final, aes(factor(`Post themes`))) +
  geom_bar(fill = "steelblue") +
  labs(title = "Distribution of Harm scores given by us (Insta)", x = "Harm Score", y = "Count") +
  theme_bw() + theme(axis.text.x = element_text(angle=45, hjust=1)) #this works


# define your harm categories using factor
instagram_self_final$harm_category <- factor(
  instagram_self_final$`Harm scores`,
  levels = c(0, 0.25, 0.5, 0.75, 1),
  labels = c("Neutral", "Low Harm", "Medium Harm", "High Harm", "Very High Harm")
)

# create a contingency table of post themes vs harm categories
contingency_table_self <- table(instagram_self_final$`Post themes`, instagram_self_final$harm_category)

# run the Chi-squared test
chisq_result_self <- chisq.test(contingency_table_self)

# view the results
print(chisq_result_self)




