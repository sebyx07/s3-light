# frozen_string_literal: true

module S3Light
  class Client
    class ObjectsList
      def initialize(client, bucket)
        @client = client
        @bucket = bucket
      end

      def all
        response = @client.with_connection do |connection|
          connection.make_request(:get, "/#{@bucket.name}")
        end

        response.xml.remove_namespaces!.xpath('//Contents').map do |object|
          S3Light::Object.new(@client, @bucket, object.xpath('Key').text, nil, true)
        end
      end

      def find_by(key:)
        @client.with_connection do |connection|
          connection.make_request(:head, "/#{@bucket.name}/#{key}")
        end

        S3Light::Object.new(@client, @bucket, key, nil, true)

      rescue S3Light::Connection::HttpError => e
        return nil if e.code == 404

        raise e
      end

      def exists?(key:)
        @client.with_connection do |connection|
          connection.make_request(:head, "/#{@bucket.name}/#{key}")
        end

        true
      rescue S3Light::Connection::HttpError => e
        return false if e.code == 404

        raise e
      end

      def new(key:, input: nil)
        S3Light::Object.new(@client, @bucket, key, input, false)
      end
    end
  end
end
