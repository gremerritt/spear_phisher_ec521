import re
import codecs


def load_tweets(path="data/tweets_cybersecurity.csv"):
    """
    Returns the tweet column from the csv file.
    (CSV in this case uses "|" as the delimiter because "," appears in the text more often)
    """
    # f = open(path, 'r')
    f = codecs.open(path, encoding='utf-8')
    lines = f.readlines()
    tweets = [t.split('|')[-2] for t in lines]

    return tweets


def load_target_tweets(path):
    """
    For some reason, target tweets are not in the same as the dataset tweets
    """
    f = codecs.open(path, encoding="utf-8")
    lines = f.readlines()
    tweets = [t.split('|')[1] for t in lines]

    return tweets


def _replace_mentions(tweet, text="usr"):
    return re.sub('@[0-9a-zA-Z_]+', text, tweet) 


def _replace_hashtags(tweet, text=""):
    return re.sub('#[0-9a-zA-Z_]+', text, tweet) 


def _replace_urls(tweet, text="lnk"):
    return re.sub('https?:\/\/t\.co\/[a-zA-Z0-9]*', text, tweet)


whitelist = re.compile(ur'[^!?#,\.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\n\t ]')
def _remove_extra_characters(tweet):
    """
    Removes characters not found in the whitelist above. 
    The ^ performs a negation of the set and the regex finds everything else, and replaces it with ''.
    """
    return re.sub(whitelist, '', tweet)


def _remove_extra_links(tweet):
    i = tweet.find("lnk")
    tweet = tweet.replace("lnk", "")
    return tweet[:i] + "lnk" + tweet[i:]


def _remove_duplicate_space(tweet):
    return re.sub(' +', ' ', tweet)


def clean_tweets(tweets):
    """
    Removes urls, mentions, hashtags, and removes non-common characters from each tweet.
    """
    for index, tweet in enumerate(tweets):
        tweet = tweet.lower()
        tweet = _replace_urls(tweet)
        tweet = _replace_mentions(tweet)
        tweet = _replace_hashtags(tweet, text="")
        tweet = _remove_extra_links(tweet)
        tweet = _remove_extra_characters(tweet)
        tweet = _remove_duplicate_space(tweet) 

        tweets[index] = tweet

    return tweets


def _find_most_common_characters(tweets):
    """
    Returns the most common characters in a Counter object.
    The method counter.most_common() will show the most common characters
    sorted by frequency. Useful for checking if our cleaning is good.
    """
    from collections import Counter
    return Counter("".join(tweets))


def long_tweets(tweets, length=20):
    """
    Returns tweets longer than a given length
    """
    return [t for t in tweets if len(t) > length]
   

def main():
    tweets = load_tweets("data/tweets300k.csv")
    tweets = clean_tweets(tweets)
    return tweets


    
