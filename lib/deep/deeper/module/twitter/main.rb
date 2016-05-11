# encoding: UTF-8
# require 'Twitter'
class SiteHtml

  # Pour envoyer un tweet
  # @usage :
  #   site.require_module 'twitter'
  #   site.tweet "Le message à twitter"
  #
  def tweet message
    require 'twitter'
    Tweet::send message
  end
  alias :twitte :tweet

  class Tweet
    class << self

      def client
        @client ||= begin
          require './data/secret/data_twitter'
          Twitter::REST::Client.new do |config|
            config.consumer_key        = DATA_TWITTER[:consumer_key]
            config.consumer_secret     = DATA_TWITTER[:consumer_secret]
            config.access_token        = DATA_TWITTER[:access_token]
            config.access_token_secret = DATA_TWITTER[:access_token_secret]
          end
        end
      end

      # Pour envoyer un tweet
      # @usage :
      #   site.require_module 'twitter'
      #   site.tweet "Le message à twitter"
      def send message
        client.update(message)
      end

    end #/<<self

  end #/Tweet
end #/SiteHtml
