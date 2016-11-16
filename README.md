# spear_phisher_ec521

THIS APPLICATION IS TO BE USED FOR EDUCATIONAL PURPOSES ONLY.

## About

The app.rb script has two functions, described below.

### Collect random tweets

The script collects tweets and records them in a pipe-delimited file called, with the format:

    Tweet ID
    From Username
    To Username
    From User ID
    To User ID
    In Reply To Tweet ID
    Favorite Count
    Retweet Count
    Unix Timestamp
    Tweet Text
    Tweet Text Abbreviated (excludes @-mentions and links)

There is an option to collect tweets only from specific groups. This uses a file of keywords to search for. The currently defined groups are:

    cybersecurity
    politics
    science
    sports

For each group defined, there should be a set of credentials and a keyword file called `<group>_keywords.txt`. The config file `config.yml` should look like `config_sample.yml`.

If no group is provided, the default credentials will be used and no keywords will be used. By default, we won't specifically search for tweets with links. You can provide the `--links=true` option to search only for tweets with links.

To collect tweets, run:

    $ ruby app.rb collect [--group=<group>] [--links=true/false]

### Find recent tweets with a hashtag

The script will find recent tweets that contain a specific hashtag. For the users associated with those tweets, we will collect up to their most recent ~3200 tweets.

In code, the `users` hash (on line 59 of app.rb) will have the following format:

    users = {<user1>: [
                       {:id             => <user1_tweet1_id>,
                        :text           => <user1_tweet1_text>,
                        :text_abbr      => <user1_tweet1_text_abbr>,
                        :favorite_count => <user1_tweet1_favorite_count>,
                        :timestamp      => <user1_tweet1_timestamp>},
                       {:id             => <user1_tweet2_id>,
                        :text           => <user1_tweet2_text>,
                        :text_abbr      => <user1_tweet2_text_abbr>,
                        :favorite_count => <user1_tweet2_favorite_count>,
                        :timestamp      => <user1_tweet2_timestamp>},
                       ...],
             <user1>: [
                       {:id             => <user2_tweet1_id>,
                        :text           => <user2_tweet1_text>,
                        :text_abbr      => <user2_tweet1_text_abbr>,
                        :favorite_count => <user2_tweet1_favorite_count>,
                        :timestamp      => <user2_tweet1_timestamp>},
                       {:id             => <user2_tweet2_id>,
                        :text           => <user2_tweet2_text>,
                        :text_abbr      => <user2_tweet2_text_abbr>,
                        :favorite_count => <user2_tweet2_favorite_count>,
                        :timestamp      => <user2_tweet2_timestamp>},
                       ...],
              ...}

To run:

    $ ruby app.rb target '#hashtag' 10

The last parameter is the max number of users to collect, and defaults to 10.
