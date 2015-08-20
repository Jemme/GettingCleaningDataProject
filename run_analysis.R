library(reshape2)

Filename <- "dataset.zip"

## Download & extract the dataset:
if (!file.exists(Filename)){
    FileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
    download.file(FileURL, Filename, method="auto")
}  
if (!file.exists("UCI HAR Dataset")) { 
    unzip(Filename) 
}

# Load activity & features
Activity <- read.table("UCI HAR Dataset/activity_labels.txt")
Activity[,2] <- as.character(Activity[,2])
Features <- read.table("UCI HAR Dataset/features.txt")
Features[,2] <- as.character(Features[,2])

# Extract partial data on mean & standard dev
NeededFeatures <- grep(".*mean.*|.*std.*", Features[,2])
NeededFeatures.names <- Features[NeededFeatures,2]
NeededFeatures.names = gsub('-mean', 'Mean', NeededFeatures.names)
NeededFeatures.names = gsub('-std', 'Std', NeededFeatures.names)
NeededFeatures.names <- gsub('[-()]', '', NeededFeatures.names)


# Load datasets
Train <- read.table("UCI HAR Dataset/train/X_train.txt")[NeededFeatures]
TrainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
TrainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
Train <- cbind(TrainSubjects, TrainActivities, Train)

Test <- read.table("UCI HAR Dataset/test/X_test.txt")[NeededFeatures]
TestActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
TestSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
Test <- cbind(TestSubjects, TestActivities, Test)

# merge datasets & add labels
AllData <- rbind(Train, Test)
colnames(AllData) <- c("subject", "activity", NeededFeatures.names)

# turn activities & subjects into factors
AllData$activity <- factor(AllData$activity, levels = Activity[,1], labels = Activity[,2])
AllData$subject <- as.factor(AllData$subject)

AllData.melted <- melt(AllData, id = c("subject", "activity"))
AllData.mean <- dcast(AllData.melted, subject + activity ~ variable, mean)

write.table(AllData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)