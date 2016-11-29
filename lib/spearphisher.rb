require 'twitter'
require 'commander'
require 'yaml'
require 'json'

module SpearPhisher
  def SpearPhisher.run
    program :name, 'spearphisher'
    program :version, SpearPhisher::VERSION
    program :description, 'Spear phishing on Twitter'

    command :collect do |c|
      c.syntax = 'spearphisher collect'
      c.description = 'Collects recent and popular tweets'
      c.action do |args, options|
        # Henchman::LaunchdHandler.start args
        puts "Hello World"
      end
    end
  end
end
#
# def main method, input_options
#   program :name, 'Henchman'
#     program :version, Henchman::VERSION
#     program :description, 'Cloud music syncing for iTunes on OS X'
#     command :start do |c|
#       c.syntax = 'henchman start'
#       c.description = 'Starts the henchman daemon'
#       c.action do |args, options|
#         Henchman::LaunchdHandler.start args
#       end
#     end
#
#   methods = ['collect', 'target']
#   groups = [:cybersecurity, :politics, :science, :sports]
#   options = {:hashtag => nil,
#              :count => 10,
#              :user => nil,
#              :send => false,
#              :group => :default,
#              :links => false}
#   if !methods.include? method
#     puts "Invalid option: #{method}"
#     puts "Valid commands are:\n  #{methods.join("\n  ")}"
#     return
#   end
#
#   # get the inputs
#   input_options.each do |opt_str|
#     opt_split = opt_str.split '='
#     begin
#       opt = opt_split[0].split('--')[1].to_sym
#       val = opt_split[1]
#
#       if !options.include? opt
#         puts "Invalid option #{opt}"
#       else
#         case opt
#         when :hashtag
#           options[:hashtag] = val.strip
#         when :user
#           options[:user] = val.strip
#         when :count
#           if /^[[:digit:]]*$/.match(val)
#             options[opt] = val.to_i
#           else
#             puts "Option '#{opt}' must be a valid number"
#             return
#           end
#         when :send
#           options[:send] = (val == 'true') ? true : false
#         when :group
#           if groups.include? val.to_sym
#             options[:group] = val.to_sym
#           else
#             puts "Invalid group '#{val}'. Options are\n  #{groups.join("\n  ")}"
#             return
#           end
#         when :links
#           options[:links] = (val == 'true') ? true : false
#         end
#       end
#     rescue StandardError => msg
#       puts "Invalid option #{opt_str} (Format --<option>=<value>)"
#     end
#   end
#   if method == 'target' &&
#      ((options[:hashtag].nil? && options[:user].nil?) ||
#      (!options[:hashtag].nil? && !options[:user].nil?))
#     puts "Must provide either a hashtag OR a user"
#     return
#   end
#
#   begin
#     print "Loading configuration... "
#     config_file = File.expand_path('config.yml')
#     config = YAML.load_file(config_file)
#     puts "success!"
#
#     # Using Application-only Authentication
#     print "Connecting to Twitter... "
#     client = Twitter::REST::Client.new do |app|
#       app.consumer_key        = config[:twitter][options[:group]][:consumer_key]
#       app.consumer_secret     = config[:twitter][options[:group]][:consumer_secret]
#       app.access_token        = config[:twitter][options[:group]][:access_token]
#       app.access_token_secret = config[:twitter][options[:group]][:access_token_secret]
#     end
#     puts "success!"
#   rescue StandardError => msg
#     puts "failed: #{msg}"
#     return
#   end
#
#   if method == 'collect'
#     collect client, options
#   elsif method == 'target'
#     target client, options
#   end
# end
#
# def target client, options
#   if options[:send]
#     puts "\nYou're about to send out live tweets."
#     while true
#       print "Are you sure you want to continue? [y/n] "
#       yn = STDIN.gets.chomp.downcase
#       case yn
#       when 'y'
#         break
#       when 'n'
#         return
#       else
#         puts "  Invalid response, enter 'y' or 'n'"
#       end
#     end
#   end
#
#
#   begin
#     if !options[:hashtag].nil?
#       if !(/^#[[:alnum:]]*$/.match(options[:hashtag]))
#         puts "Tag [#{options[:hashtag]}] must be a valid hashtag"
#         return
#       end
#
#       users = Array.new
#       puts "Searching for #{options[:count]} recent tweets with #{options[:hashtag]}"
#       tweets = client.search("#{options[:hashtag]} -rt", lang: "en", result_type: "recent").take(options[:count])
#       tweets.each do |tweet|
#         username = tweet.user.screen_name
#         if !(users.include?(username))
#           puts "\nUsername: #{username}\nOriginal Tweet: #{tweet.text}"
#           users.push(username)
#           generateTweet username, options[:send], client
#         end
#       end
#     elsif !options[:user].nil?
#       puts "\nUsername: #{options[:user]}"
#       generateTweet options[:user], options[:send], client
#     end
#   rescue Twitter::Error::TooManyRequests => msg
#     puts "Twitter::Error::TooManyRequests: #{msg}"
#     sleep_for = msg.rate_limit.reset_in + 10
#     puts "Wait at least #{sleep_for} second before re-running"
#     return
#   rescue Twitter::Error => msg
#     puts "#{msg.class}: #{msg}"
#     return
#   rescue Interrupt
#     puts "\nStopping"
#     return
#   rescue StandardError => msg
#     puts "Error: #{msg}"
#     return
#   end
#
# end
#
# def generateTweet username, send, client
#   tweets = Array.new
#   getTweetsForUser username, tweets, client
#
#   if tweets.length > 0
#     len = tweets.length
#     puts "  #{len} tweet#{(len == 1) ? '' : 's'} found"
#     text = generateTweetText tweets
#     sendTweet username, text, send, client
#   else
#     puts "  No tweets found for #{username}"
#   end
# end
#
# def generateTweetText tweets
#   puts "  Generating a tweet"
#   # This is where we'll use the NN and the recent tweets to generate
#   # a tweet to that user
#   "Some sample return"
# end
#
# def sendTweet username, text, send, client, in_reply_to = nil
#   puts "  #{send ? 'Sending' : 'Would send'} '#{text}' to #{username}"
#   if send
#     client.update("@#{username} #{text}", :in_reply_to_status_id => in_reply_to)
#   end
# end
#
# def collect_with_max_id(collection=[], max_id=nil, &block)
#   response = yield(max_id)
#   collection += response
#   response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
# end
#
# def getTweetsForUser username, tweets, client
#   puts "  Collecting recent tweets"
#
#   begin
#     def client.get_all_tweets(user)
#       collect_with_max_id do |max_id|
#         options = {count: 200, include_rts: true}
#         options[:max_id] = max_id unless max_id.nil?
#         user_timeline(user, options)
#       end
#     end
#
#     client.get_all_tweets(username).each do |tweet|
#       text = tweet.text.gsub("|", " ").gsub("\n", " ").gsub("\r", " ")
#       tweets.push({:id => tweet.id,
#                    :text => text,
#                    :text_abbr => abbreviate(text),
#                    :favorite_count => tweet.favorite_count,
#                    :retweet_count => tweet.retweet_count,
#                    :timestamp => tweet.created_at.to_i})
#     end
#   rescue Twitter::Error::NotFound => msg
#     puts "  Username #{username} not found"
#     return
#   end
# end
#
# def collect client, options
#
#   search = "-rt"
#   search << " filter:links" if options[:links]
#
#   keywords = Array.new
#   rslt_file = ""
#   if !options[:group].nil?
#     puts "Searching for group '#{options[:group]}'"
#     rslt_file = File.expand_path("tweets_#{options[:group]}.csv")
#     begin
#       fname = File.expand_path "#{options[:group]}_keywords.txt"
#       File.open(fname, "r") { |f| f.each_line { |line| keywords.push(line.strip.chomp) } }
#     rescue Errno::ENOENT => msg
#       puts "Failed to load file #{fname}"
#       return
#     end
#
#     keywords_str = keywords.join ' OR '
#     total_len = search.length + keywords_str.length + 1
#     if total_len > 500
#       puts "Search string is too long. Need to reduce by "\
#            "#{total_len-500} characters."
#       return
#     end
#     puts "Keywords are:"
#     puts "  #{keywords.join("\n  ")}"
#     search << " #{keywords_str}"
#   else
#     rslt_file = File.expand_path("tweets.csv")
#   end
#
#   cnt, rslts = load_rslts rslt_file
#
#   begin
#     while true
#       begin
#         puts "Querying Tweets - Count: #{cnt}"
#         tweets = client.search(search, lang: "en")
#         tweets.each do |tweet|
#           to = tweet.in_reply_to_screen_name
#           in_reply_to_id = tweet.in_reply_to_status_id
#           # next if to.nil? || in_reply_to_id.nil?
#
#           from = tweet.user.screen_name
#           # next if to == from
#           next if to.include?('|') || from.include?('|')
#
#           text = tweet.text.gsub("|", " ").gsub("\n", " ").gsub("\r", " ")
#           text_abbr = abbreviate text
#
#           if rslts[from].nil?
#             rslts[from] = {to => {:id => tweet.id,
#                                   :text => text,
#                                   :text_abbr => text_abbr,
#                                   :from_user_id => tweet.user.id,
#                                   :to_user_id => tweet.in_reply_to_user_id,
#                                   :in_reply_to_status_id => in_reply_to_id,
#                                   :favorite_count => tweet.favorite_count,
#                                   :retweet_count => tweet.retweet_count,
#                                   :timestamp => tweet.created_at.to_i}}
#             cnt += 1
#           elsif rslts[from][to].nil?
#             dup = rslts[from].any? { |key, val| text_abbr == val[:text_abbr] }
#             if !dup
#               rslts[from][to] = {:id => tweet.id,
#                                  :text => text,
#                                  :text_abbr => text_abbr,
#                                  :from_user_id => tweet.user.id,
#                                  :to_user_id => tweet.in_reply_to_user_id,
#                                  :in_reply_to_status_id => in_reply_to_id,
#                                  :favorite_count => tweet.favorite_count,
#                                  :retweet_count => tweet.retweet_count,
#                                  :timestamp => tweet.created_at.to_i}
#               cnt += 1
#             end
#           end
#         end
#         sleep 15
#       rescue Twitter::Error::TooManyRequests => msg
#         puts "Twitter::Error::TooManyRequests: #{msg}"
#         sleep_for = msg.rate_limit.reset_in + 10
#         sleeper_display sleep_for
#       rescue Twitter::Error => msg
#         puts "#{msg.class}: #{msg}"
#         sleep 30
#       rescue Interrupt
#         puts "\nStopping"
#         return
#       end
#     end
#   ensure
#     write_rslts rslts, rslt_file
#   end
# end
#
# def abbreviate text
#   # this regex removes @ mentions and links from the text
#   # in order to prevent 'duplicate' tweets (i.e. bulk tweets
#   # sent from one user to many others) from being collected
#   text.gsub(/(?<=^|\s)@(\S+)($|\s)/, "").gsub(/(?<=^|\s)http(\S+)($|\s)/, "")
# end
#
# def write_rslts rslts, rslt_file
#   puts "Writing File"
#   File.open(rslt_file, "w") do |file|
#     rslts.each do |from_username, to|
#       to.each do |to_username, info|
#         str =  "#{info[:id]}|"
#         str << "#{from_username}|"
#         str << "#{to_username}|"
#         str << "#{info[:from_user_id]}|"
#         str << "#{info[:to_user_id]}|"
#         str << "#{info[:in_reply_to_status_id]}|"
#         str << "#{info[:favorite_count]}|"
#         str << "#{info[:retweet_count]}|"
#         str << "#{info[:timestamp]}|"
#         str << "#{info[:text]}|"
#         str << "#{info[:text_abbr]}\n"
#         file.write(str)
#       end
#     end
#   end
# end
#
# def load_rslts rslt_file
#   puts "Loading File"
#   rslts = Hash.new
#   cnt = 0
#   begin
#     File.open(rslt_file, "r") do |f|
#       f.each_line do |line|
#         next if line[0] == "\n" || line.empty? || line.nil?
#         line.gsub!("\n", "")
#         s = line.split('|')
#         from = s[1]
#         to   = s[2]
#         if rslts[from].nil?
#           rslts[from] = {to => {:id => s[0],
#                                 :from_user_id => s[3],
#                                 :to_user_id => s[4],
#                                 :in_reply_to_status_id => s[5],
#                                 :favorite_count => s[6],
#                                 :retweet_count => s[7],
#                                 :timestamp => s[8],
#                                 :text => s[9],
#                                 :text_abbr => s[10]}}
#         else
#           rslts[from][to] = {:id => s[0],
#                              :from_user_id => s[3],
#                              :to_user_id => s[4],
#                              :in_reply_to_status_id => s[5],
#                              :favorite_count => s[6],
#                              :retweet_count => s[7],
#                              :timestamp => s[8],
#                              :text => s[9],
#                              :text_abbr => s[10]}
#         end
#         cnt += 1
#       end
#     end
#   rescue Errno::ENOENT => msg
#     # do nothing - file didn't exist
#   end
#
#   return cnt, rslts
# end
#
# def sleeper_display cnt
#   tmp_cnt = cnt
#   while tmp_cnt > 0
#     print "\rSleeping for #{cnt} (#{tmp_cnt})    "
#     tmp_cnt -= 1
#     sleep 1
#   end
#   puts "\rSleeping for #{cnt}                 "
# end
#
# def get_battery_percent
#   perc = `pmset -g batt`
#   perc = perc.split(' ')
#   perc.delete_if { |elem| !elem.include?('%') }
#   perc = perc[0].gsub('%', '').gsub(';', '').to_i
#   return perc
# end
#
# main ARGV[0], ARGV[1..-1]
