require 'twitter'
require 'yaml'
require 'json'

def main method, tag, num
  opts = ['collect', 'target']
  if !opts.include? method
    puts "Invalid option: #{method}"
    puts "Valid commands are:\n  #{opts.join("\n  ")}"
    return
  end

  begin
    print "Loading configuration... "
    config_file = File.expand_path('config.yml')
    config = YAML.load_file(config_file)
    puts "success!"

    # Using Application-only Authentication
    print "Connecting to Twitter... "
    client = Twitter::REST::Client.new do |app|
      app.consumer_key    = config[:twitter][:consumer_key]
      app.consumer_secret = config[:twitter][:consumer_secret]
    end
    puts "success!"
  rescue StandardError => msg
    puts "failed: #{msg}"
    return
  end

  if method == 'collect'
    collect client
  elsif method == 'target'
    target client, tag, num
  end
end

def target client, tag, num
  if tag.nil? || tag.empty?
    puts "Must provide a tag to search for"
    puts "If you provided a hashtag on the command line,"
    puts "make sure that it is quote-wrapped"
    return
  end
  tag = tag.strip
  # make sure it's a hashtag
  if !(/^#[[:alnum:]]*$/.match(tag))
    puts "Tag [#{tag}] must be a valid hashtag"
    return
  end

  if !(num.nil?) && !(/^[[:digit:]]*$/.match(num))
    puts "Invalid number of users to generate phishing attacks to (#{num})"
    return
  end
  num ||= 10
  num = num.to_i

  users = Hash.new
  begin
    puts "Searching for #{num} recent tweets with #{tag}"
    tweets = client.search("#{tag} -rt", lang: "en", result_type: "recent").take(num)
    tweets.each do |tweet|
      username = tweet.user.screen_name
      users[username] = Array.new if !(users.include?(username))
    end

    users.each do |username, tweets|
      getTweetsForUser username, tweets, client
    end

    # puts JSON.pretty_generate(users)
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

def collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield(max_id)
  collection += response
  response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
end

def getTweetsForUser username, tweets, client
  puts "Collecting Tweets for user #{username}"

  def client.get_all_tweets(user)
    collect_with_max_id do |max_id|
      options = {count: 200, include_rts: true}
      options[:max_id] = max_id unless max_id.nil?
      user_timeline(user, options)
    end
  end

  # cnt = 0
  client.get_all_tweets(username).each do |tweet|
    text = tweet.text.gsub("|", " ").gsub("\n", " ").gsub("\r", " ")
    tweets.push({:id => tweet.id,
                 :text => text,
                 :text_abbr => abbreviate(text),
                 :favorite_count => tweet.favorite_count,
                 :retweet_count => tweet.retweet_count,
                 :timestamp => tweet.created_at.to_i})
    # cnt += 1
    # break if cnt == 3
  end
end

def collect client
  rslt_file = File.expand_path('tweets.csv')
  cnt, rslts = load_rslts rslt_file

  begin
    while true
      begin
        puts "Querying Tweets - Count: #{cnt}"
        tweets = client.search("filter:links -rt", lang: "en")
        tweets.each do |tweet|
          to = tweet.in_reply_to_screen_name
          in_reply_to_id = tweet.in_reply_to_status_id
          next if to.nil? || in_reply_to_id.nil?

          from = tweet.user.screen_name
          next if to == from
          next if to.include?('|') || from.include?('|')

          text = tweet.text.gsub("|", " ").gsub("\n", " ").gsub("\r", " ")
          text_abbr = abbreviate text

          if rslts[from].nil?
            rslts[from] = {to => {:id => tweet.id,
                                  :text => text,
                                  :text_abbr => text_abbr,
                                  :from_user_id => tweet.user.id,
                                  :to_user_id => tweet.in_reply_to_user_id,
                                  :in_reply_to_status_id => in_reply_to_id,
                                  :favorite_count => tweet.favorite_count,
                                  :retweet_count => tweet.retweet_count,
                                  :timestamp => tweet.created_at.to_i}}
            cnt += 1
          elsif rslts[from][to].nil?
            dup = rslts[from].any? { |key, val| text_abbr == val[:text_abbr] }
            if !dup
              rslts[from][to] = {:id => tweet.id,
                                 :text => text,
                                 :text_abbr => text_abbr,
                                 :from_user_id => tweet.user.id,
                                 :to_user_id => tweet.in_reply_to_user_id,
                                 :in_reply_to_status_id => in_reply_to_id,
                                 :favorite_count => tweet.favorite_count,
                                 :retweet_count => tweet.retweet_count,
                                 :timestamp => tweet.created_at.to_i}
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

def abbreviate text
  # this regex removes @ mentions and links from the text
  # in order to prevent 'duplicate' tweets (i.e. bulk tweets
  # sent from one user to many others) from being collected
  text.gsub(/(?<=^|\s)@(\S+)($|\s)/, "").gsub(/(?<=^|\s)http(\S+)($|\s)/, "")
end

def write_rslts rslts, rslt_file
  puts "Writing File"
  File.open(rslt_file, "w") do |file|
    rslts.each do |from_username, to|
      to.each do |to_username, info|
        str =  "#{info[:id]}|"
        str << "#{from_username}|"
        str << "#{to_username}|"
        str << "#{info[:from_user_id]}|"
        str << "#{info[:to_user_id]}|"
        str << "#{info[:in_reply_to_status_id]}|"
        str << "#{info[:favorite_count]}|"
        str << "#{info[:retweet_count]}|"
        str << "#{info[:timestamp]}|"
        str << "#{info[:text]}|"
        str << "#{info[:text_abbr]}\n"
        file.write(str)
      end
    end
  end
end

def load_rslts rslt_file
  puts "Loading File"
  rslts = Hash.new
  cnt = 0
  begin
    File.open(rslt_file, "r") do |f|
      f.each_line do |line|
        next if line[0] == "\n" || line.empty? || line.nil?
        line.gsub!("\n", "")
        s = line.split('|')
        from = s[1]
        to   = s[2]
        if rslts[from].nil?
          rslts[from] = {to => {:id => s[0],
                                :from_user_id => s[3],
                                :to_user_id => s[4],
                                :in_reply_to_status_id => s[5],
                                :favorite_count => s[6],
                                :retweet_count => s[7],
                                :timestamp => s[8],
                                :text => s[9],
                                :text_abbr => s[10]}}
        else
          rslts[from][to] = {:id => s[0],
                             :from_user_id => s[3],
                             :to_user_id => s[4],
                             :in_reply_to_status_id => s[5],
                             :favorite_count => s[6],
                             :retweet_count => s[7],
                             :timestamp => s[8],
                             :text => s[9],
                             :text_abbr => s[10]}
        end
        cnt += 1
      end
    end
  rescue Errno::ENOENT => msg
    # do nothing - file didn't exist
  end

  return cnt, rslts
end

def sleeper_display cnt
  tmp_cnt = cnt
  while tmp_cnt > 0
    print "\rSleeping for #{cnt} (#{tmp_cnt})    "
    tmp_cnt -= 1
    sleep 1
  end
  puts "\rSleeping for #{cnt}                 "
end

def get_battery_percent
  perc = `pmset -g batt`
  perc = perc.split(' ')
  perc.delete_if { |elem| !elem.include?('%') }
  perc = perc[0].gsub('%', '').gsub(';', '').to_i
  return perc
end

main ARGV[0], ARGV[1], ARGV[2]
