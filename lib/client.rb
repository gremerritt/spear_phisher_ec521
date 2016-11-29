require 'twitter'

module SpearPhisher

  def SpearPhisher.setup_client group
    begin
      print "Loading configuration... "
      config_file = File.expand_path('config.yml')
      config = YAML.load_file(config_file)
      puts "success!"
    rescue StandardError => msg
      raise "failed. Make sure 'config.yml' exists in the current directory."
    end

    begin
      # Using Application-only Authentication
      print "Connecting to Twitter... "
      client = Twitter::REST::Client.new do |app|
        app.consumer_key        = config[:twitter][group][:consumer_key]
        app.consumer_secret     = config[:twitter][group][:consumer_secret]
        app.access_token        = config[:twitter][group][:access_token]
        app.access_token_secret = config[:twitter][group][:access_token_secret]
      end
      puts "success!"
      return client
    rescue StandardError => msg
      raise "failed. #{msg}"
    end
  end

end
