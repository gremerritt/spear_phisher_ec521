from keras.models import load_model
import numpy as np

# from sklearn.feature_extraction.text import CountVectorizer, TfidfTransformer

import preprocess
import sys

def text2one_hot(text, char_indices):
    """
    Takes some text of length N and a map from character to it's index, and
    returns a matrix of size 1xNxM, where M is the number of characters.
    """
    x = np.zeros((1, len(text), len(char_indices.keys())))
    for t, char in enumerate(text):
        x[0, t, char_indices[char]] = 1.

    return x


def sample(preds, temperature=1.0):
    # helper function to sample an index from a probability array
    preds = np.asarray(preds).astype('float64')
    preds = np.log(preds) / temperature
    exp_preds = np.exp(preds)
    preds = exp_preds / np.sum(exp_preds)
    probas = np.random.multinomial(1, preds, 1)
    return np.argmax(probas)


def _generate_tweet(model, seed_text, chars, text_length, diversity):
    """
    Generates a tweet using some seed. The seed needs to be some text of the same length the network was trained on.
    """
    generated = ''
    generated += seed_text

    char_indices = dict((c, i) for i, c in enumerate(chars))
    indices_char = dict((i, c) for i, c in enumerate(chars))

    for i in range(text_length):
        x = text2one_hot(seed_text, char_indices)

        preds = model.predict(x, verbose=0)[0]
        next_index = sample(preds, diversity)
        next_char = indices_char[next_index]

        generated += next_char
        seed_text = seed_text[1:] + next_char

    return generated


def _find_representative(all_tweets, target_tweets, length):
    """
    Finds a the most representative tweet in a targets tweets and returns it.
    """
    # HACK picks at random for now until i figure out how to get good results with TFIDF
    while True:
        i = np.random.randint(len(target_tweets))
        test = target_tweets[i]

        # check if there isnt an username in the text
        # if len(test) > length and "usr" not in test[:length]:
        if len(test) > length:
            return test[:length]


def _generate_seed(all_tweets, target_tweets, length):
    """
    Generates a good seed from a persons tweet history.
    target_tweets is a list of a persons tweets in unicode,
    all_tweets is a list of all tweets,
    length is the length of the resulting seed.
    """
    # cv = CountVectorizer()
    # all_counts = cv.fit_transform(all_tweets)

    # tfidf = TfidfTransformer()
    # X_train = tfidf.fit_transform(all_counts)
    return _find_representative(all_tweets, target_tweets, length)


def generate(model, all_tweets, target_tweets, text_length, seed_length, diversity):
    chars = sorted(list(set("".join(all_tweets))))

    seed = _generate_seed(all_tweets, target_tweets, seed_length)
    tweet = _generate_tweet(model, seed, chars, text_length, diversity)

    return tweet


def main(model_path, all_tweets_path, target_tweets_path):
    model = load_model(model_path)
    all_tweets = preprocess.clean_tweets(preprocess.load_tweets(all_tweets_path))
    target_tweets = preprocess.clean_tweets(preprocess.load_target_tweets(target_tweets_path))

    tweet = generate(model, all_tweets, target_tweets, text_length=100, seed_length=20, diversity=0.5)

    return tweet


if __name__ == "__main__":
    #print main("lstm.h5", "data/tweets_cybersecurity.csv", "data/swift.csv")
    print main(sys.argv[1], sys.argv[2], sys.argv[3])
