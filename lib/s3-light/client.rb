# frozen_string_literal: true

module S3Light
  class Client
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

    def with_connection(concurrency: 0)
      yield connection
    end

    private
      def amazon_default_endpoint
        "https://s3.#{@region}.amazonaws.com"
      end
  end
end
