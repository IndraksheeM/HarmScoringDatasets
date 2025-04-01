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

instagram_chatgpt <- fread(file.path("Bachelorarbeit data", "insta_chatgptlabeled_compiled_updated.csv"))

instagram_chatgpt_dt <- as.data.table(instagram_chatgpt)
instagram_chatgpt_wocomments <- instagram_chatgpt_dt[, -c("Comment", "Background sound / audio", "Post ID")]


instagram_chatgpt_woaudio <- instagram_chatgpt_dt[, -c("Comment", "Background sound / audio", "Post ID")]

instagram_chatgpt_themes <- separate_rows(instagram_chatgpt_wocomments, `Post themes`, sep = ',')
instagram_chatgpt_themes <- mutate(instagram_chatgpt_themes, `Post themes` = trimws(`Post themes`))

instagram_chatgpt_woaudio <- separate_rows(instagram_chatgpt_woaudio, `Post themes`, sep = ',')
instagram_chatgpt_woaudio <- mutate(instagram_chatgpt_woaudio, `Post themes` = trimws(`Post themes`))

instagram_chatgpt_final <- instagram_chatgpt_themes

instagram_chatgpt_woaudio <- as.data.table(instagram_chatgpt_woaudio)
instagram_chatgpt_woaudio <- instagram_chatgpt_woaudio[, .(`Post themes count` = .N , `Average harm score` = mean(`Harm score`, na.rm = TRUE)), by = `Post themes`]
instagram_chatgpt_woaudio_noNA <- drop_na(instagram_chatgpt_woaudio)
instagram_chatgpt_woaudio_clean <- instagram_chatgpt_woaudio_noNA[`Post themes` != ""]


ggplot(instagram_chatgpt_woaudio_clean, aes(x = `Post themes count`, y = `Average harm score`)) + geom_point() + labs(title = "Average GPT 4-o harm score vs count of post themes (Insta)") + theme_bw()
summary(lm(`Post themes count` ~ `Average harm score`, instagram_chatgpt_woaudio_clean))


instagram_chatgpt_final <- as.data.table(instagram_chatgpt_final)
instagram_chatgpt_final <- drop_na(instagram_chatgpt_final)
instagram_chatgpt_final <- instagram_chatgpt_final[`Post themes` != ""]

instagram_chatgpt_final[, `Harm scores` := factor(`Harm score`,
                                               levels = c(0, 0.25, 0.5, 0.75, 1),
                                               labels = c("0", "0.25", "0.5", "0.75", "1"))]



# Count number of posts grouped by theme and harm score bin 
heatmap_values_chatgpt <- instagram_chatgpt_final[, .N, by = .(`Post themes`, `Harm scores`)]

# cast data to wide format
heatmap_valuescasted_chatgpt <- dcast(heatmap_values_chatgpt, `Post themes` ~ `Harm scores`, value.var = "N")

# set rownames
matrix_chatgpt <- as.matrix(heatmap_valuescasted_chatgpt[, -1])

rownames(matrix_chatgpt) <- heatmap_valuescasted_chatgpt$`Post themes`


pheatmap(matrix_chatgpt, cluster_rows = F, cluster_cols = F, main = "Heatmap of GPT 4-o harm scores (Insta)", angle_col = 315)
pheatmap(matrix_chatgpt, cluster_rows = F, cluster_cols = T, main = "Heatmap of GPT 4-o harm scores (Insta)", angle_col = 315) 


matrix_chatgpt[(is.na(matrix_chatgpt))] <- 0
matrix_chatgpt_scaled <- matrix_chatgpt / rowSums(matrix_chatgpt)
rownames(matrix_chatgpt_scaled) <- heatmap_valuescasted_chatgpt$`Post themes`

pheatmap(matrix_chatgpt_scaled, cluster_rows = T, cluster_cols = F, main = "Heatmap of GPT 4-o harm scores (Insta)", angle_col = 315)
pheatmap(matrix_chatgpt_scaled, cluster_rows = T, cluster_cols = T, main = "Heatmap of GPT 4-o harm scores (Insta)", angle_col = 315)


#ggplot(instagram_chatgpt_final, aes(x = `Harm score`)) + geom_density(alpha = 0.4) + facet_wrap( ~ `Post themes`) + ylim(0, 10)
#ggplot(instagram_chatgpt_final, aes(x = `Harm score`)) + geom_density(alpha = 0.4) + facet_wrap( ~ `Post themes`) + ylim(0, 5)
ggplot(instagram_chatgpt_final, aes(x = `Harm score`)) + geom_density() + facet_wrap( ~ `Post themes`) + ylim(0, 2) + labs(title = "Density plots of GPT 4-o harm scores by theme (Insta)", x = "Harm score", y = "Density") + theme_bw() + theme(axis.text.x = element_text(angle = 45, hjust = 1))

#ggplot(instagram_chatgpt_final, aes(x = `Harm score`)) + geom_density(alpha = 0.8) + facet_wrap( ~ `Post themes`) + ylim(0, 2) + labs(title = "Density plots of our harm scores by theme") + theme_minimal()


ggplot(instagram_chatgpt_final, aes(factor(`Harm score`))) +
  geom_bar(fill = "steelblue") +
  labs(title = "Distribution of Harm scores given by GPT 4-o (Insta)", x = "Harm Score", y = "Count") +
  theme_bw() #this works

instagram_chatgpt_nonzero <- instagram_chatgpt_final[`Harm score` != 0]

ggplot(instagram_chatgpt_nonzero, aes(factor(`Post themes`))) +
  geom_bar(fill = "steelblue") +
  labs(title = "Distribution of non Zero Harm scores given by GPT 4-o (Insta)", x = "Harm Score", y = "Count") +
  theme_bw() + theme(axis.text.x = element_text(angle=45, hjust=1)) #this works

ggplot(instagram_chatgpt_final, aes(factor(`Post themes`))) +
  geom_bar(fill = "steelblue") +
  labs(title = "Distribution of Harm scores given by GPT 4-o (Insta)", x = "Harm Score", y = "Count") +
  theme_bw() + theme(axis.text.x = element_text(angle=45, hjust=1)) #this works


# define your harm categories using factor
instagram_chatgpt_final$harm_category <- factor(
  instagram_chatgpt_final$`Harm scores`,
  levels = c(0, 0.25, 0.5, 0.75, 1),
  labels = c("Neutral", "Low Harm", "Medium Harm", "High Harm", "Very High Harm")
)

# create a contingency table of post themes vs harm categories
contingency_table_chatgpt <- table(instagram_chatgpt_final$`Post themes`, instagram_chatgpt_final$harm_category)

# run the Chi-squared test
chisq_result_chatgpt <- chisq.test(contingency_table_chatgpt)

# view the results
print(chisq_result_chatgpt)

