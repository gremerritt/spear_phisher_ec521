require 'twitter'

module SpearPhisher

  def self.setup_client group
    begin
      print "Loading configuration... "
      config_file = File.expand_path('config.yml')
      config = YAML.load_file(config_file)
      puts "success!"

      # Using Application-only Authentication
      print "Connecting to Twitter... "
      @client = Twitter::REST::Client.new do |app|
        app.consumer_key        = config[:twitter][options[:group]][:consumer_key]
        app.consumer_secret     = config[:twitter][options[:group]][:consumer_secret]
        app.access_token        = config[:twitter][options[:group]][:access_token]
        app.access_token_secret = config[:twitter][options[:group]][:access_token_secret]
      end
      puts "success!"
    rescue StandardError => msg
      puts "failed: #{msg}"
      return
    end
  end
end
