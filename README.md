# spear_phisher_ec521

THIS APPLICATION IS TO BE USED FOR EDUCATIONAL PURPOSES ONLY.

## About

The app.rb script collects random tweets and records them in a file called `tweets.csv`. This is a pipe-delimited file with the format:

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

The script collects tweets that are from one user to another user, and which contain a link. It attempts to exclude duplicate tweets from one user to multiple other users that contain the same text (by comparing the abbreviated text, as described above). If the `tweets.csv` file already exists when the script runs, those results are kept.

## Running

Create a .yml file with your Twitter credentials. It should look like:

    ---
    :twitter:
      :consumer_key: <key>
      :consumer_secret: <secret>

Then run

    $ ruby app.rd
