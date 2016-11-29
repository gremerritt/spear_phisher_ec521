require 'client'

module SpearPhisher

  class Collecter

    def self.start options
      raise "Invalid group" if !SpearPhisher.groups.include? options.group

      @client = SpearPhisher.setup_client options.group

      search = "-rt"
      search << " filter:links" if options.links == 'true'

      keywords = Array.new
      rslt_file = ""
      if options.group != 'default'
        puts "Searching for group '#{options.group}'"
        rslt_file = File.expand_path("tweets_#{options.group}.csv")
        begin
          fname = File.expand_path "lib/keywords/#{options.group}.txt"
          File.open(fname, "r") { |f| f.each_line { |line| keywords.push(line.strip.chomp) } }
        rescue Errno::ENOENT => msg
          puts "Failed to load file #{fname}"
          return
        end

        keywords_str = keywords.join ' OR '
        total_len = search.length + keywords_str.length + 1
        if total_len > 500
          puts "Search string is too long. Need to reduce by "\
               "#{total_len-500} characters."
          return
        end
        puts "Keywords are:"
        puts "  #{keywords.join("\n  ")}"
        search << " #{keywords_str}"
      else
        rslt_file = File.expand_path("tweets.csv")
      end

      cnt, rslts = load_rslts rslt_file

      begin
        while true
          begin
            puts "Querying Tweets - Count: #{cnt}"
            tweets = @client.search(search, lang: "en")
            tweets.each do |tweet|
              to = tweet.in_reply_to_screen_name
              in_reply_to_id = tweet.in_reply_to_status_id
              # next if to.nil? || in_reply_to_id.nil?

              from = tweet.user.screen_name
              # next if to == from
              next if to.include?('|') || from.include?('|')

              text = tweet.text.gsub("|", " ").gsub("\n", " ").gsub("\r", " ")
              text_abbr = SpearPhisher.abbreviate text

              if rslts[from].nil?
                rslts[from] = {to => format_tweet(tweet, text, text_abbr, in_reply_to_id)}
                cnt += 1
              elsif rslts[from][to].nil?
                dup = rslts[from].any? { |key, val| text_abbr == val[:text_abbr] }
                if !dup
                  rslts[from][to] = format_tweet tweet, text, text_abbr, in_reply_to_id
                  cnt += 1
                end
              end
            end
            sleep 15
          rescue Twitter::Error::TooManyRequests => msg
            puts "Twitter::Error::TooManyRequests: #{msg}"
            sleep_for = msg.rate_limit.reset_in + 10
            sleeper_display sleep_for
          rescue Twitter::Error => msg
            puts "#{msg.class}: #{msg}"
            sleep 30
          rescue Interrupt
            puts "\nStopping"
            return
          end
        end
      ensure
        write_rslts rslts, rslt_file
      end
    end

    def self.format_tweet tweet, text, text_abbr, in_reply_to_id
      {:id => tweet.id,
       :text => text,
       :text_abbr => text_abbr,
       :from_user_id => tweet.user.id,
       :to_user_id => tweet.in_reply_to_user_id,
       :in_reply_to_status_id => in_reply_to_id,
       :favorite_count => tweet.favorite_count,
       :retweet_count => tweet.retweet_count,
       :timestamp => tweet.created_at.to_i}
    end

    def self.load_helper arr
      {:id => arr[0],
       :from_user_id => arr[3],
       :to_user_id => arr[4],
       :in_reply_to_status_id => arr[5],
       :favorite_count => arr[6],
       :retweet_count => arr[7],
       :timestamp => arr[8],
       :text => arr[9],
       :text_abbr => arr[10]}
    end

    def self.write_helper from, to, info
      str =  "#{info[:id]}|"
      str << "#{from}|"
      str << "#{to}|"
      str << "#{info[:from_user_id]}|"
      str << "#{info[:to_user_id]}|"
      str << "#{info[:in_reply_to_status_id]}|"
      str << "#{info[:favorite_count]}|"
      str << "#{info[:retweet_count]}|"
      str << "#{info[:timestamp]}|"
      str << "#{info[:text]}|"
      str << "#{info[:text_abbr]}\n"
    end

    def self.write_rslts rslts, rslt_file
      puts "Writing File"
      File.open(rslt_file, "w") do |file|
        rslts.each do |from, to|
          to.each do |to, info|
            file.write write_helper(from, to, info)
          end
        end
      end
    end

    def self.load_rslts rslt_file
      puts "Loading File"
      rslts = Hash.new
      cnt = 0

      begin
        File.open(rslt_file, "r") do |f|
          f.each_line do |line|
            next if line[0] == "\n" || line.empty? || line.nil?
            line.gsub!("\n", "")
            tweet = line.split('|')
            from = tweet[1]
            to   = tweet[2]
            if rslts[from].nil?
              rslts[from] = {to => load_helper(tweet)}
            else
              rslts[from][to] = load_helper tweet
            end
            cnt += 1
          end
        end
      rescue Errno::ENOENT => msg
        # do nothing - file didn't exist
      end

      return cnt, rslts
    end

    def self.sleeper_display cnt
      tmp_cnt = cnt
      while tmp_cnt > 0
        print "\rSleeping for #{cnt} (#{tmp_cnt})    "
        tmp_cnt -= 1
        sleep 1
      end
      puts "\rSleeping for #{cnt}                 "
    end

  end

end
