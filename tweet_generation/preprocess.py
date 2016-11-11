import re


def load_tweets(path):
    """
    Returns the tweet column from the csv file.
    (CSV in this case uses "|" as the delimiter because "," appears in the text more often)
    """
    f = open(path, 'r')
    lines = f.readlines()
    tweets = [t.split('|')[-2] for t in lines]

    return tweets


def replace_mentions(tweet, exp, text="@"):
    return re.sub('@[0-9a-zA-Z]+', text, tweet) 


def replace_urls(tweet, text="URL"):
    return re.sub('https?:\/\/t\.co\/[a-zA-Z0-9]*', text, tweet)
    
