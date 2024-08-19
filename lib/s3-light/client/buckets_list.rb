# frozen_string_literal: true

module S3Light
  class Client
    class BucketsList
      def initialize(client)
        @client = client
      end

      def all
        response = @client.connection.make_request(:get, '/')

        response.xml.remove_namespaces!.xpath('//Bucket').map do |bucket|
          S3Light::Bucket.new(@client, bucket.xpath('Name').text, true)
        end
      end

      def exists?(name:)
        response = @client.connection.make_request(:head, "/#{name}")

        response.code == 200
      end

      def find_by(name:)
        all.find { |bucket| bucket.name == name }
      end

      def new(name: nil)
        S3Light::Bucket.new(@client, name, false)
      end

      def inspect
        "#<#{self.class.name} @buckets=#{all.size}>"
      end
    end
  end
end
