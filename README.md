# The Telstra Network Disruptions competition on Kaggle.com

The goal of the competition was to predict Telstra network's fault severity at a time at a particular location based on log data provided. Most of the feature engineering involved reshaping the log data into categorical data, and extracting additional information from the log data.

Although the locations at which faults occured was provided, there was no explicit information about the time or temporal order of the faults. However, the order of some of the log files provided additional predictive power, probably because it reflected a temporal ordering. This feature was the elusive "magical" featre that so many Kagglers were asking about in the forums.

Model-fitting was done using XGBoost.

These scripts were good for a spot in the top 5% on the leaderboard (46th/974).

https://www.kaggle.com/c/telstra-recruiting-network/leaderboard
