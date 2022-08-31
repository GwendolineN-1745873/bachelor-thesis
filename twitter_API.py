#! /usr/bin/env python3
# Python script used to gather data to form a dataset of tweets about Stray
# Based on https://datascienceparichay.com/article/get-data-from-twitter-api-in-python-step-by-step-guide/

# Libraries

# Tweepy Twitter API library
# 
# __version__ = '3.10.0'
# __author__ = 'Joshua Roesslein'
# __license__ = 'MIT'
import tweepy 
import os
import pandas as pd


# Authentication for Twitter API

consumerKey = os.getenv('CONSUMER_KEY')
consumerSecret = os.getenv('CONSUMER_SECRET')
auth = tweepy.OAuthHandler(consumerKey, consumerSecret)
api = tweepy.API(auth, wait_on_rate_limit=True)

search_query = "stray game -filter:retweets"

# get tweets from the API
tweets_iterator = tweepy.Cursor(api.search,
              q=search_query,
              lang="en",
              since="2022-07-19").items(100)


# store the API responses in a list
tweets = []
for tweet in tweets_iterator:
    tweets.append(tweet)
    
print("Total Tweets fetched:", len(tweets))

tweets_df = pd.DataFrame()

for tweet in tweets:
    hashtags = []
    try:
        for hashtag in tweet.entities["hashtags"]:
            hashtags.append(hashtag["text"])
        text = api.get_status(id=tweet.id, tweet_mode='extended').full_text
    except:
        pass
    tweets_df = tweets_df.append(pd.DataFrame({'user_name': tweet.user.name, 
                                               'user_location': tweet.user.location,
                                               'date': tweet.created_at,
                                               'text': text, 
                                               'hashtags': [hashtags if hashtags else None],
                                               'source': tweet.source}))
    tweets_df = tweets_df.reset_index(drop=True)

# show the dataframe
data_table.DataTable(tweets_df, include_index=False, num_rows_per_page=10)

# Based on https://datascienceparichay.com/article/get-data-from-twitter-api-in-python-step-by-step-guide/

tweets_df.to_csv('datasets/stray-game-14-08.csv')