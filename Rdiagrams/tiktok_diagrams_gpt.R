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

tiktok_ChatGPT <- fread(file.path("Bachelorarbeit data", "tiktok_ChatGPTlabeled_compiled.csv"))

tiktok_ChatGPT_dt <- as.data.table(tiktok_ChatGPT)
tiktok_ChatGPT_wocomments <- tiktok_ChatGPT_dt[, -c("Comment ID", "Comment", "Post ID", "Score explanation", "Background song/audio")]


tiktok_ChatGPT_woaudio <- tiktok_ChatGPT_dt[, -c("Comment ID", "Comment", "Post ID", "Score explanation", "Background song/audio")]

tiktok_ChatGPT_themes <- separate_rows(tiktok_ChatGPT_wocomments, `Post themes`, sep = ',')
tiktok_ChatGPT_themes <- mutate(tiktok_ChatGPT_themes, `Post themes` = trimws(`Post themes`))

tiktok_ChatGPT_woaudio <- separate_rows(tiktok_ChatGPT_woaudio, `Post themes`, sep = ',')
tiktok_ChatGPT_woaudio <- mutate(tiktok_ChatGPT_woaudio, `Post themes` = trimws(`Post themes`))

tiktok_ChatGPT_final <- tiktok_ChatGPT_themes


tiktok_ChatGPT_woaudio <- as.data.table(tiktok_ChatGPT_woaudio)
tiktok_ChatGPT_woaudio <- tiktok_ChatGPT_woaudio[, .(`Post themes count` = .N , `Average harm score` = mean(`Harm score`, na.rm = TRUE)), by = `Post themes`]
tiktok_ChatGPT_woaudio_noNA <- drop_na(tiktok_ChatGPT_woaudio)
tiktok_ChatGPT_woaudio_clean <- tiktok_ChatGPT_woaudio_noNA[`Post themes` != ""]

ggplot(tiktok_ChatGPT_woaudio_clean, aes(x = `Post themes count`, y = `Average harm score`)) + geom_point() + labs(title = "Average GPT 4-o harm score vs count of post themes (TikTok)") + theme_bw()
summary(lm(`Post themes count` ~ `Average harm score`, tiktok_ChatGPT_woaudio_clean))


tiktok_ChatGPT_final <- as.data.table(tiktok_ChatGPT_final)
tiktok_ChatGPT_final <- drop_na(tiktok_ChatGPT_final)
tiktok_ChatGPT_final <- tiktok_ChatGPT_final[`Post themes` != ""]

tiktok_ChatGPT_final[, `Harm scores` := factor(`Harm score`,
                                            levels = c(0, 0.25, 0.5, 0.75, 1),
                                            labels = c("0", "0.25", "0.5", "0.75", "1"))]



# Count number of posts grouped by theme and harm score bin 
heatmap_values_chatgpt <- tiktok_ChatGPT_final[, .N, by = .(`Post themes`, `Harm scores`)]


# cast data to wide format
heatmap_valuescasted_chatgpt <- dcast(heatmap_values, `Post themes` ~ `Harm scores`, value.var = "N")

# set rownames
matrix_chatgpt <- as.matrix(heatmap_valuescasted[, -1])
rownames(matrix_chatgpt) <- heatmap_valuescasted$`Post themes`


pheatmap(matrix_chatgpt, cluster_rows = F, cluster_cols = F, main = "Heatmap of GPT 4-o harm scores (TikTok)", angle_col = 315)
pheatmap(matrix_chatgpt, cluster_rows = F, cluster_cols = T, main = "Heatmap of GPT 4-o harm scores (TikTok)", angle_col = 315)


matrix_chatgpt[(is.na(matrix_chatgpt))] <- 0
matrix_chatgpt_scaled <- matrix_chatgpt / rowSums(matrix_chatgpt)
rownames(matrix_chatgpt_scaled) <- heatmap_valuescasted_chatgpt$`Post themes`

pheatmap(matrix_chatgpt_scaled, cluster_rows = T, cluster_cols = F, main = "Heatmap of GPT 4-o harm scores (TikTok)", angle_col = 315)
pheatmap(matrix_chatgpt_scaled, cluster_rows = T, cluster_cols = T, main = "Heatmap of GPT 4-o harm scores (TikTok)", angle_col = 315)


ggplot(tiktok_ChatGPT_final, aes(x = `Harm score`)) + geom_density() + facet_wrap( ~ `Post themes`) + ylim(0, 2) + labs(title = "Density plots of GPT 4-o harm scores by theme (TikTok)", x = "Harm score", y = "Density") + theme_bw()

ggplot(tiktok_ChatGPT_final, aes(factor(`Harm score`))) +
  geom_bar(fill = "steelblue") +
  labs(title = "Distribution of Harm scores given by GPT 4-o (TikTok)", x = "Harm Score", y = "Count") +
  theme_bw() #this works

tiktok_ChatGPT_nonzero <- tiktok_ChatGPT_final[`Harm score` != 0]

ggplot(tiktok_ChatGPT_nonzero, aes(factor(`Post themes`))) +
  geom_bar(fill = "steelblue") +
  labs(title = "Distribution of non Zero Harm scores given by GPT 4-o (TikTok)", x = "Harm Score", y = "Count") +
  theme_bw() + theme(axis.text.x = element_text(angle=45, hjust=1)) #this works

ggplot(tiktok_ChatGPT_final, aes(factor(`Post themes`))) +
  geom_bar(fill = "steelblue") +
  labs(title = "Distribution of Harm scores given by GPT 4-o (TikTok)", x = "Harm Score", y = "Count") +
  theme_bw() + theme(axis.text.x = element_text(angle=45, hjust=1)) #this works


# define your harm categories using factor
tiktok_ChatGPT_final$harm_category <- factor(
  tiktok_ChatGPT_final$`Harm scores`,
  levels = c(0, 0.25, 0.5, 0.75, 1),
  labels = c("Neutral", "Low Harm", "Medium Harm", "High Harm", "Very High Harm")
)

# create a contingency table of post themes vs harm categories
contingency_table_ChatGPT <- table(tiktok_ChatGPT_final$`Post themes`, tiktok_ChatGPT_final$harm_category)

# run the Chi-squared test
chisq_result_ChatGPT <- chisq.test(contingency_table_ChatGPT)

# view the results
print(chisq_result_ChatGPT)

