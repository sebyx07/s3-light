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

      def create_batch(names:, concurrency: 10)
        names.to_h do |name|
          [name, new(name: name).save!]
        end
      end

      def destroy_batch(names:, concurrency: 10)
        names.to_h do |name|
          S3Light::Bucket.new(@client, name).__destroy!
          [name, true]
        end
      end

      def exists_batch?(names:, concurrency: 10)
        names.to_h do |name|
          [name, exists?(name: name)]
        end
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
