# frozen_string_literal: true

module S3Light
  module ConnectionsManager
    class Threaded
      def initialize(client, concurrency)
        @client = client
        @thread_pool = Concurrent::FixedThreadPool.new(concurrency)
        @connections = Concurrent::Array.new
      end

      def with_connection
        @thread_pool.post do
          existing_connection = Thread.current[:connection]
          yield existing_connection if existing_connection

          new_connection = create_new_connection
          @connections << new_connection
          Thread.current[:connection] = new_connection

          yield new_connection
        end
      end

      def close
        @connections.each(&:close)
        @connections = Concurrent::Array.new
      end

      def wait_to_finish
        @thread_pool.shutdown
        @thread_pool.wait_for_termination
      end

      private
        def create_new_connection
          Connection.new(
            endpoint: @client.endpoint, access_key_id: @client.access_key_id, secret_access_key: @client.secret_access_key,
            ssl_context: @client.ssl_context
          )
        end
    end
  end
end
