# frozen_string_literal: true

module S3Light
  module ConnectionsManager
    class Main
      def initialize
        @connections = {}
      end

      def yield_connection(client, &block)
        client_connection = nil
        @connections.each do |existing_client, connection|
          if client.endpoint == existing_client.endpoint
            client_connection = connection
            break
          end
        end

        client_connection ||= create_new_connection(client)
        @connections[client] = client_connection

        block.call(client_connection)
      end

      def close_all_connections
        return if @connections.empty?
        @connections.each do |_, connection|
          connection.close
        end

        @connections = {}
      end

      private
        def create_new_connection(client)
          Connection.new(
            endpoint: client.endpoint, access_key_id: client.access_key_id, secret_access_key: client.secret_access_key,
            ssl_context: client.ssl_context
          )
        end
    end
  end
end
