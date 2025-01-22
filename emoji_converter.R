library(tidyverse)
library(stringr)
library(tm)

#assuming your comment file has a column titled "comment"
comments <- read_csv("your_file_path/your_comment_file.csv")

emoji <- read.csv("emoji15_lookup.csv", header = T)
emoji <- emoji %>%
  mutate(text = str_remove_all(text, "\\b(face|red|hand)\\b")) %>% #removes common emoji words for downstream tasks (topic modeling / sentiment analysis) - customize this if your dataset has an abundance of common emojis
  mutate(bytes = str_replace_all(bytes, "([.\\^$*+?(){}\\[\\]|\\\\])", "\\\\\\1"),
         text = str_c(" ", text, " ")) #adds spaces before and after the text

#transform to ascii
comments$comment <- iconv(comments$comment, from = "latin1", to = "ascii", 
                    sub = "byte")

#convert emoji to text
comments <- FindReplace(data = comments, Var = "comment", 
                      replaceData = emoji,
                      from = "bytes", to = "text", 
                      exact = FALSE, vector = FALSE)

#remove residual <>s
comments <- comments %>%
  mutate(comment = str_remove_all(comment, "<[^>]+>"))

write_csv(comments, "converted.csv")
