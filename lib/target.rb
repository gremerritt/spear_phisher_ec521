module SpearPhisher

  class Targeter

    def self.start options
      raise "Invalid group" if !SpearPhisher.groups.include? options.group
      @send = options.send == 'true' ? true : false
      @display = options.display_tweets == 'true' ? true : false
      @link = options.link

      if (options.hashtag.nil? && options.user.nil?) ||
         (!options.hashtag.nil? && !options.user.nil?)
        puts "Must provide either a hashtag OR a user"
        return
      end

      if @send
        puts "\nYou're about to send out live tweets."
        return if !agree("Are you sure you want to continue? [y/n]")
      end

      @client = SpearPhisher.setup_client 'default'

      begin
        if !options.hashtag.nil?
          if options.hashtag.class == TrueClass
            raise "Please provide a valid hashtag (wrapped in quotes)"
          end

          if !(/^#[[:alnum:]]*$/.match(options.hashtag))
            raise "Tag [#{options.hashtag}] must be a valid hashtag"
          end

          users = Array.new
          puts "Searching for #{options.count} recent tweets with #{options.hashtag}"
          tweets = @client.search("#{options.hashtag} -rt", lang: "en", result_type: "recent").take(options.count)
          tweets.each do |tweet|
            username = tweet.user.screen_name
            id = tweet.id
            if !(users.include?(username))
              puts "\nUsername: #{username}"
              puts "Link: https://twitter.com/#{username}/status/#{id}"
              puts "Tweet: #{tweet.text}"
              users.push username
              generate_tweet username, id
            end
          end
        elsif !options.user.nil?
          puts "\nUsername: #{options.user}"
          generate_tweet options.user
        end
      rescue Twitter::Error::TooManyRequests => msg
        puts "Twitter::Error::TooManyRequests: #{msg}"
        sleep_for = msg.rate_limit.reset_in + 10
        puts "Wait at least #{sleep_for} second before re-running"
        return
      rescue Twitter::Error => msg
        puts "#{msg.class}: #{msg}"
        return
      rescue Interrupt
        puts "\nStopping"
        return
      rescue StandardError => msg
        puts "Error: #{msg}"
        return
      end

    end

    def self.generate_tweet username, id
      tweets = Array.new
      get_tweets_for_user username, tweets

      if tweets.length > 0
        len = tweets.length
        puts "  #{len} tweet#{(len == 1) ? '' : 's'} found"
        text = generate_tweet_text tweets
        send_tweet username, text, id
      else
        puts "  No tweets found for #{username}"
      end
    end

    def self.generate_tweet_text tweets
      puts "  Generating a tweet"
      display_tweets tweets if @display
      # This is where we'll use the NN and the recent tweets to generate
      # a tweet to that user
      "Some sample return"
    end

    def self.display_tweets tweets
      tweets.each do |tweet|
        puts tweet.values.join '|'
      end
    end

    def self.send_tweet username, text, in_reply_to = nil
      tweet = "@#{username} #{text}"
      tweet << " #{@link}" if !@link.empty?
      puts "  #{@send ? 'Sending' : 'Would send'} '#{tweet}' to #{username}"
      @client.update(tweet, :in_reply_to_status_id => in_reply_to) if @send
    end

    def self.collect_with_max_id(collection=[], max_id=nil, &block)
      response = yield(max_id)
      collection += response
      response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
    end

    def self.get_tweets_for_user username, tweets
      puts "  Collecting recent tweets"

      begin
        def @client.get_all_tweets(user)
          collect_with_max_id do |max_id|
            options = {count: 200, include_rts: true}
            options[:max_id] = max_id unless max_id.nil?
            user_timeline(user, options)
          end
        end

        @client.get_all_tweets(username).each do |tweet|
          text = tweet.text.gsub("|", " ").gsub("\n", " ").gsub("\r", " ")
          tweets.push({:id => tweet.id,
                       :text => text,
                       :text_abbr => SpearPhisher.abbreviate(text),
                       :favorite_count => tweet.favorite_count,
                       :retweet_count => tweet.retweet_count,
                       :timestamp => tweet.created_at.to_i})
        end
      rescue Twitter::Error::NotFound => msg
        puts "  Username #{username} not found"
        return
      end
    end

  end

end
