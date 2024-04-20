import tweepy

client = tweepy.Client(bearer_token='AAAAAAAAAAAAAAAAAAAAALGRtQEAAAAAaQubTUgfpHVDhmEwq2rh3YLdUKc%3D6teN3XZzrYsEqOkluWS7e5s8Zl10nCfDj8ZmM9Nb92js7M52Y0')

# Replace with your own search query
query = 'from:suhemparack -is:retweet'

tweets = client.search_recent_tweets(query=query, tweet_fields=['context_annotations', 'created_at'], max_results=100)

for tweet in tweets.data:
    print(tweet.text)
    if len(tweet.context_annotations) > 0:
        print(tweet.context_annotations)