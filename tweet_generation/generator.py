from __future__ import print_function
from keras.models import Sequential
from keras.layers import Dense, Activation, Dropout
from keras.layers import LSTM
from keras.optimizers import RMSprop
from keras.utils.data_utils import get_file
import numpy as np
import random
import sys

from sklearn.feature_extraction.text import CountVectorizer, TfidfTransformer


def load_model(path):
    from keras.models import load_model
    model = load_model(path)
    return model


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


def _generate_tweet(model, seed_text, chars, text_length=100, diversity=0.5):
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
    # picks at random for now until i figure out how to get good results with TFIDF
    tweet = None
    while not tweet:
        i = np.random.randint(len(target_tweets))
        test = target_tweets[i]

        # check if there isnt an username in the text
        if len(test) > length and "usr" not in test:
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
    

