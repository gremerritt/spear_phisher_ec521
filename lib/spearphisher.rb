require 'spearphisher/version'
require 'collect'
require 'target'
require 'twitter'
require 'commander/import'

module SpearPhisher

  def SpearPhisher.run
    program :name, 'spearphisher'
    program :version, SpearPhisher::VERSION
    program :description, 'Spear phishing on Twitter'

    @groups = `ls lib/keywords/`.split("\n").map{ |e| e.gsub(".txt", "") }
    @groups.push 'default'

    command :collect do |c|
      c.syntax = 'spearphisher collect'
      c.option "--group [#{@groups.join '/'}]", String, 'Group to collect tweets for, based on keywords'
      c.option '--links [true/false]', String, 'Collect only tweets that include links'
      c.description = 'Collects recent and popular tweets'
      c.action do |args, options|
        options.default \
          :group => 'default',
          :links  => 'false'
        SpearPhisher::Collecter.start options
      end
    end

    command :target do |c|
      c.syntax = 'spearphisher target'
      c.option "--group [#{@groups.join '/'}]", String, 'Group to collect tweets for, based on keywords'
      c.option '--send [true/false]', String, 'Collect only tweets that include links'
      c.option '--hashtag [#<text>]', String, 'Hashtag to search for'
      c.option '--user [username]', String, 'User to target'
      c.option '--count [#]', Integer, 'Number of users to target'
      c.description = 'Draft or send generated tweets'
      c.action do |args, options|
        options.default \
          :group => 'default',
          :send  => 'false',
          :hashtag => nil,
          :user => nil,
          :count => 10
        SpearPhisher::Targeter.start options
      end
    end
  end

  def SpearPhisher.groups
    @groups
  end

  def SpearPhisher.abbreviate text
    # this regex removes @ mentions and links from the text
    # in order to prevent 'duplicate' tweets (i.e. bulk tweets
    # sent from one user to many others) from being collected
    text.gsub(/(?<=^|\s)@(\S+)($|\s)/, "").gsub(/(?<=^|\s)http(\S+)($|\s)/, "")
  end

end
