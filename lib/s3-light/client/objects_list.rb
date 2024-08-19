# frozen_string_literal: true

module S3Light
  class Client
    class ObjectsList
      def initialize(client, bucket)
        @client = client
        @bucket = bucket
      end

      def all
        response = @client.connection.make_request(:get, "/#{@bucket.name}")

        response.xml.remove_namespaces!.xpath('//Contents').map do |object|
          S3Light::Object.new(@client, @bucket, object.xpath('Key').text, nil, true)
        end
      end

      def new(key:, input:)
        S3Light::Object.new(@client, @bucket, key, input, false)
      end
    end
  end
end
