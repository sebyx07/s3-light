# frozen_string_literal: true

module S3Light
  class Client
    attr_reader :access_key_id, :secret_access_key, :region, :ssl_context, :endpoint
    def initialize(endpoint: nil, access_key_id:, secret_access_key:, region: 'us-east-1', ssl_context: nil)
      @access_key_id = access_key_id
      @secret_access_key = secret_access_key
      @region = region
      @ssl_context = ssl_context
      @endpoint = endpoint || amazon_default_endpoint
    end

    def buckets
      @buckets ||= BucketsList.new(self)
    end

    def connection
      return @connection if @connection

      @connection = Connection.new(
        endpoint: @endpoint, access_key_id: @access_key_id, secret_access_key: @secret_access_key,
        ssl_context: @ssl_context
      )
    end

    def with_connection(&block)
      self.class.main_connections_manager.yield_connection(self, &block)
    end

    def build_thread_poll(concurrency)
      S3Light::ConnectionsManager::Threaded.new(self, concurrency)
    end

    class << self
      def main_connections_manager
        @main_connections_manager ||= ConnectionsManager::Main.new
      end

      def close_all_connections
        main_connections_manager.close_all_connections
      end
    end

    private
      def amazon_default_endpoint
        "https://s3.#{@region}.amazonaws.com"
      end
  end
end

at_exit do
  S3Light::Client.close_all_connections
end
