# spear_phisher_ec521

THIS APPLICATION IS TO BE USED FOR EDUCATIONAL PURPOSES ONLY.

## About

The app.rb script has two functions, described below:

### Collect random tweets

The script collects tweets that are from one user to another user and which contain a link, and records them in a file called `tweets.csv`. This is a pipe-delimited file with the format:

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

It attempts to exclude duplicate tweets from one user to multiple other users that contain the same text (by comparing the abbreviated text, as described above). If the `tweets.csv` file already exists when the script runs, those results are kept.

To collect tweets, run:

    $ ruby app.rb collect

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
