library(xgboost)

# Train model on volume data
dtrain <- xgb.DMatrix(data = as.matrix(tt[train_id, c(-1,-3,-8)]), 
                      label=as.matrix(tt[train_id,3]))

set.seed(666)
param <- list(max.depth = 14, eta = 0.05, nthread = 3,
              min_child_weight = 1.25, max_delta_step = 0, gamma = 1,
              colsample_bytree = 0.4, subsample = 1,
              eval.metric = "mlogloss", objective = "multi:softprob")

hist <- xgb.cv(data = dtrain, param = param, num_class = 3, nrounds = 5000,
               maximize = FALSE, early.stop.round = 10, nfold = 5)

set.seed(666)
fit <- xgboost(data = dtrain, param = param, num_class = 3, nrounds = nrow(hist))

# Predict on submission test data
pred <- predict(fit, as.matrix(tt[test_sub_id,c(-1,-3,-8)]))

probs <- t(matrix(pred, nrow=3, ncol=length(pred)/3))
sample_sub <- read.csv("Data/sample_submission.csv")
sample_sub[,2:4] <- probs
write.csv(sample_sub, file = "sub_xgb.csv", quote = FALSE, row.names = FALSE)
