# frozen_string_literal: true

module S3Light
  class Client
    class Buckets
      def initialize(client)
        @client = client
      end

      def all
        response = @client.connection.make_request(:get, '/')

        response.xml.remove_namespaces!.xpath('//Bucket').map do |bucket|
          S3Light::Bucket.new(@client, bucket.xpath('Name').text, true)
        end
      end

      def inspect
        "#<#{self.class.name}>:#{object_id}\n#{all.map(&:inspect).join("\n")}"
      end
    end
  end
end
