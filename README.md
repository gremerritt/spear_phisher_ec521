# spear_phisher_ec521

THIS APPLICATION IS TO BE USED FOR EDUCATIONAL PURPOSES ONLY. It was written as a Cybersecurity project based on [this Blackhat talk](https://www.blackhat.com/docs/us-16/materials/us-16-Seymour-Tully-Weaponizing-Data-Science-For-Social-Engineering-Automated-E2E-Spear-Phishing-On-Twitter.pdf).

## Compiling and Installing

We'll assume you're installing on Kali Linux, using Python2.7 and Ruby2.2+ (though instructions should be similar for different platforms / versions.)

This application comes with a pre-trained Neural Network which generated tweets based on a large sample. Instructions for collecting training data and training the NN can be found [below](#Training Your Own Model).

First install the Python dependancies:

Install `TensorFlow`. General instructions are [here](https://www.tensorflow.org/versions/r0.12/get_started/os_setup.html). TL;DR

    $ pip install tensorflow

Install `keras`. General instructions are [here](https://github.com/fchollet/keras#Installation). TL;DR

    $ sudo pip install keras

Now for the Ruby. Make sure you're in the root of the project directory.

Make sure bundler is up-to-date:

    $ gem update bundler

Install the dependancies:

    $ bundle install

Now build the project:

    $ bundle exec rake install

You should get the message:

    spearphisher 0.0.1 built to pkg/spearphisher-0.0.1.gem.
    spearphisher (0.0.1) installed.

## Running

You can run the following to get detailed command-line options

    $ spearphisher -h
    $ spearphisher [COMMAND] -h

First, copy or rename the `config_sample.yml` file to `config.yml`. Follow [these instructions](#Creating a Twitter Client) for creating credentials. As should be obvious from the format of the config file, you can set up different accounts and control which account you use for any given run.

To create a phishing tweet to a specific user, use:

    $ spearphisher target --user <username>

You can also find users to target using a hashtag:

    $ spearphisher target --hashtag "#sometag"

The full list of options is below:

    OPTIONS:

      --group [cybersecurity/politics/science/sports/default]
          Credential set to use (keyword file must also exist in lib/keywords)

      --send [true/false]
          Actually tweet at users (USE WITH CAUTION)
          Default: false

      --hashtag [#<text>]
          Hashtag to search for

      --user [username]
          User to target

      --count [#]
          Number of users to target
          Default: 10

      --display_tweets [true/false]
          Display the tweets collected for a user
          Default: false


## Training Your Own Model

### Generating Sample Tweets

Running the following will generate a file of sample recent and popular tweets.

    $ spearphisher collect

If you'd like to target specific groups, you can create a file in lib/keywords with a list of keywords to use in the collection. The list of options for the `collect` command is:

    OPTIONS:

      --group [cybersecurity/politics/science/sports/default]
          Group to collect tweets for, based on keywords in lib/keywords

      --links [true/false]
          Collect only tweets that include links
          Default: false

### Training the Neural Network


## Creating a Twitter Client

Go to [twitter.com](https://twitter.com) and log in to your account, or create a new one. Make sure you've provided your phone number, as you will not be able to generate API credentials without it on file. Once you're logged into you account go to [dev.twitter.com](https://dev.twitter.com) and click on "My apps". Click "Create New App" and fill in the required fields. Once your application is created, open the settings for the application and click on "Keys and Access Tokens". Under "Your Access Token" click on "Create my access token".

In your `config.yml` file, copy and paste your `Consumer Key`, `Consumer Secret`, `Access Token`, and `Access Token Secret` in to their respective fields (I would suggest pasting them into the `default` section, but you can assign them to specific groups if you wish). Note that you shouldn't have any quotes around the keys in the `.yml` file. It should look something like:

    :twitter:
      default:
        :consumer_key: abc
        :consumer_secret: def
        :access_token: ghi-jkl
        :access_token_secret: mnop
