# frozen_string_literal: true

module S3Light
  class Client
    class BucketsList
      def initialize(client)
        @client = client
      end

      def all
        response = @client.with_connection do |connection|
          connection.make_request(:get, '/')
        end

        response.xml.remove_namespaces!.xpath('//Bucket').map do |bucket|
          S3Light::Bucket.new(@client, bucket.xpath('Name').text, true)
        end
      end

      def exists?(name:)
        response = @client.with_connection do |connection|
          connection.make_request(:head, "/#{name}")
        end

        response.code == 200
      end

      def create_batch(names:, concurrency: 10)
        result = ConcurrentResult.new

        thread_poll = @client.build_thread_poll(concurrency)

        names.each do |name|
          thread_poll.with_connection do |connection|
            bucket = S3Light::Bucket.new(@client, name, true)
            bucket.__save!(connection)
            result.add(name, bucket)
          end
        end

        thread_poll.wait_to_finish

        result.to_h
      ensure
        thread_poll.close
      end

      def destroy_batch(names:, concurrency: 10)
        result = ConcurrentResult.new
        thread_poll = @client.build_thread_poll(concurrency)

        names.each do |name|
          thread_poll.with_connection do |connection|
            new(name: name).__destroy!(connection)
            result.add(name, true)
          end
        end

        thread_poll.wait_to_finish

        result.to_h
      ensure
        thread_poll.close
      end

      def exists_batch?(names:, concurrency: 10)
        result = ConcurrentResult.new
        thread_poll = @client.build_thread_poll(concurrency)

        names.each do |name|
          thread_poll.with_connection do |connection|
            result.add(name, connection.make_request(:head, "/#{name}"))
          end
        end

        thread_poll.wait_to_finish

        result.to_h
      ensure
        thread_poll.close
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
