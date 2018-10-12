library(dplyr)

# Fetching data, unzip data in data.dir
data.url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
data.dir = "dataset/"

# Only do it when dataset file is not downloaded
if (!file.exists("dataset.zip")) {
  download.file(data.url, "dataset.zip")
  unzip("dataset.zip", exdir = data.dir)
}

# Loading features
features.data <- read.table(paste0(data.dir, "UCI HAR Dataset/features.txt"))
features.labels <- features.data[, 2]
features.selected <- features.data[grep('(mean|std)\\(\\)', features.labels), 2]

# Load activity labels
activities.data <- 
  paste0(data.dir, "UCI HAR Dataset/activity_labels.txt") %>%
  read.table(col.names = c('activity_id', 'activity_label'))

# Load trainingdata
x_train <-
  paste0(data.dir, "UCI HAR Dataset/train/X_train.txt") %>%
  read.table(col.names = features.labels) %>%
  select(contains(".mean."), contains(".std."))

y_train <- 
  paste0(data.dir, "UCI HAR Dataset/train/y_train.txt") %>%
  read.table(col.names = c("activity_id"))

subject_train <-
  paste0(data.dir, "UCI HAR Dataset/train/subject_train.txt") %>%
  read.table(col.names = c("subject_id"))

dataset.train <- 
  cbind(y_train, subject_train) %>% 
  cbind(x_train)

## Loading testdata
x_test <- 
  paste0(data.dir, "UCI HAR Dataset/test/X_test.txt") %>%
  read.table(col.names = features.labels) %>%
  select(contains(".mean."), contains(".std."))

y_test <- 
  paste0(data.dir, "UCI HAR Dataset/test/y_test.txt") %>%
  read.table(col.names = c("activity_id"))

subject_test <-
  paste0(data.dir, "UCI HAR Dataset/test/subject_test.txt") %>%
  read.table(col.names = c("subject_id"))

dataset.test <- 
  cbind(y_test, subject_test) %>% 
  cbind(x_test)

## Merge train and test
dataset.merged <- 
  rbind(dataset.train, dataset.test) %>% 
  merge(activities.data, by='activity_id')
 
## Create independent tidy data set with the average of each variable for each activity and each subject.
dataset.grouped <-
  dataset.merged %>%
  group_by(activity_id, subject_id) %>%
  summarise_all(mean, .vars = -activity_label)
  
# Write tidy file  
write.table(dataset.grouped, "tidy.txt")

