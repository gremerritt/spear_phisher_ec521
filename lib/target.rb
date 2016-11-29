module SpearPhisher

  class Targeter

    def self.start options
      if options[:send]
        puts "\nYou're about to send out live tweets."
        while true
          print "Are you sure you want to continue? [y/n] "
          yn = STDIN.gets.chomp.downcase
          case yn
          when 'y'
            break
          when 'n'
            return
          else
            puts "  Invalid response, enter 'y' or 'n'"
          end
        end
      end


      begin
        if !options[:hashtag].nil?
          if !(/^#[[:alnum:]]*$/.match(options[:hashtag]))
            puts "Tag [#{options[:hashtag]}] must be a valid hashtag"
            return
          end

          users = Array.new
          puts "Searching for #{options[:count]} recent tweets with #{options[:hashtag]}"
          tweets = client.search("#{options[:hashtag]} -rt", lang: "en", result_type: "recent").take(options[:count])
          tweets.each do |tweet|
            username = tweet.user.screen_name
            if !(users.include?(username))
              puts "\nUsername: #{username}\nOriginal Tweet: #{tweet.text}"
              users.push(username)
              generateTweet username, options[:send], client
            end
          end
        elsif !options[:user].nil?
          puts "\nUsername: #{options[:user]}"
          generateTweet options[:user], options[:send], client
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

    def generate_tweet username, send, client
      tweets = Array.new
      getTweetsForUser username, tweets, client

      if tweets.length > 0
        len = tweets.length
        puts "  #{len} tweet#{(len == 1) ? '' : 's'} found"
        text = generateTweetText tweets
        sendTweet username, text, send, client
      else
        puts "  No tweets found for #{username}"
      end
    end

    def generate_tweet_text tweets
      puts "  Generating a tweet"
      # This is where we'll use the NN and the recent tweets to generate
      # a tweet to that user
      "Some sample return"
    end

    def send_tweet username, text, send, client, in_reply_to = nil
      puts "  #{send ? 'Sending' : 'Would send'} '#{text}' to #{username}"
      if send
        client.update("@#{username} #{text}", :in_reply_to_status_id => in_reply_to)
      end
    end

    def collect_with_max_id(collection=[], max_id=nil, &block)
      response = yield(max_id)
      collection += response
      response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
    end

    def self.get_tweets_for_user username, tweets, client
      puts "  Collecting recent tweets"

      begin
        def client.get_all_tweets(user)
          collect_with_max_id do |max_id|
            options = {count: 200, include_rts: true}
            options[:max_id] = max_id unless max_id.nil?
            user_timeline(user, options)
          end
        end

        client.get_all_tweets(username).each do |tweet|
          text = tweet.text.gsub("|", " ").gsub("\n", " ").gsub("\r", " ")
          tweets.push({:id => tweet.id,
                       :text => text,
                       :text_abbr => abbreviate(text),
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
