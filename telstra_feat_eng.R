library(dplyr)
library(reshape2)
library(caret)

# Set WD
setwd("C:/Users/Job Lindsen/Desktop/Kaggle/Telstra")

# Load data
train <- read.csv("Data/train.csv")
test_sub <- read.csv("Data/test.csv")
log_feature <- read.csv("Data/log_feature.csv")
severity <- read.csv("Data/severity_type.csv")
resource <- read.csv("Data/resource_type.csv")
event <- read.csv("Data/event_type.csv")

# Get rows of train and test data
train_id <- train$id
test_sub_id  <- test_sub$id

tt <- full_join(train, test_sub)

# Add number of times a locations is in data
tt %>% 
  count(location) -> loc_count
colnames(loc_count) <- c("location", "n_loc")
tt <- merge(tt, loc_count, by="location")
rm(loc_count)

# Add number of logs for each id
log_feature %>%
  count(id) -> n_log_feature
colnames(n_log_feature) <- c("id","n_feat")
tt <- merge(tt, n_log_feature, by="id")

resource %>%
  count(id) -> n_resource
colnames(n_resource) <- c("id","n_resource")
tt <- merge(tt, n_resource, by="id")

event %>%
  count(id) -> n_event
colnames(n_event) <- c("id","n_event")
tt <- merge(tt, n_event, by="id")

rm(n_log_feature, n_resource, n_event)

# Add order from severity log
severity_order <- cbind(severity$id, seq(1:nrow(severity)))
severity_order <- as.data.frame(severity_order)
colnames(severity_order) <- c("id","new_order")
tt <- merge(tt, severity_order, by="id")

tt <- tt[order(tt$new_order),]
tt %>%
  group_by(location) %>%
  mutate(loc_order = row_number()) -> tt

# Reshape Log_feature
log_feature %>%
  dcast(id ~ log_feature) -> log_feature

log_feature[is.na(log_feature)] <- 0

tt <- merge(tt, log_feature, by="id")
rm(log_feature, sum_volume)

#Reshape severity
severity %>%
  cbind(rep(1,nrow(severity))) %>%
  dcast(id ~ severity_type) -> severity

severity[is.na(severity)] <- 0
tt <- merge(tt, severity, by="id")
rm(severity)

#Reshape location
tt %>%
  cbind(rep(1,nrow(tt))) %>%
  dcast(id ~ location) -> location_tt

location_tt <- location_tt[,c("id",intersect(test_sub$location,train$location))]
location_tt[is.na(location_tt)] <- 0
tt <- merge(tt, location_tt, by="id")
rm(location_tt)
rm(train, test_sub)

#Reshape resource
resource %>%
  cbind(rep(1,nrow(resource))) %>%
  dcast(id ~ resource_type) -> resource

resource[is.na(resource)] <- 0
tt <- merge(tt, resource, by="id")
rm(resource)

#Reshape event
event %>%
  cbind(rep(1,nrow(event))) %>%
  dcast(id ~ event_type) -> event

event[is.na(event)] <- 0
tt <- merge(tt, event, by="id")
rm(event)

locs <- unlist(strsplit(tt$location, " ", fixed = TRUE))
tt$location <- as.numeric(locs[seq(2,length(locs),by=2)])
rm(locs)

tt$id <- as.numeric(tt$id)
