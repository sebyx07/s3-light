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

      def create_batch(input:, concurrency: 10)
        result = ConcurrentResult.new

        thread_poll = @client.build_thread_poll(concurrency)
        current_thread = Thread.current

        input.each do |key, input|
          thread_poll.with_connection do |connection|
            object = S3Light::Object.new(@client, @bucket, key, input, true)

            object.__save!(connection)

            result.add(key, object)
          rescue Exception => e
            thread_poll.kill
            current_thread.raise(e)
          end
        end

        thread_poll.wait_to_finish

        result.to_h
      ensure
        thread_poll.close
      end

      def destroy_batch(keys:, concurrency: 10)
        result = ConcurrentResult.new

        thread_poll = @client.build_thread_poll(concurrency)
        current_thread = Thread.current

        keys.each do |key|
          thread_poll.with_connection do |connection|
            object = S3Light::Object.new(@client, @bucket, key, nil, true)

            object.__destroy!(connection)

            result.add(key, true)
          rescue S3Light::Connection::HttpError => e
            if e.code == 404
              result.add(key, true)
            else
              thread_poll.kill
              current_thread.raise(e)
            end
          rescue Exception => e
            thread_poll.kill
            current_thread.raise(e)
          end
        end

        thread_poll.wait_to_finish

        result.to_h
      ensure
        thread_poll.close
      end

      def exists_batch?(keys:, concurrency: 10)
        result = ConcurrentResult.new

        thread_poll = @client.build_thread_poll(concurrency)
        current_thread = Thread.current

        keys.each do |key|
          thread_poll.with_connection do |connection|
            result.add(key, connection.make_request(:head, "/#{@bucket.name}/#{key}"))

          rescue S3Light::Connection::HttpError => e
            if e.code == 404
              result.add(key, false)
            else
              thread_poll.kill
              current_thread.raise(e)
            end
          rescue Exception => e
            thread_poll.kill
            current_thread.raise(e)
          end
        end

        thread_poll.wait_to_finish

        result.to_h
      ensure
        thread_poll.close
      end

      def find_by_batch(keys:, concurrency: 10)
        result = ConcurrentResult.new

        thread_poll = @client.build_thread_poll(concurrency)
        current_thread = Thread.current

        keys.each do |key|
          thread_poll.with_connection do |connection|
            connection.make_request(:head, "/#{@bucket.name}/#{key}")

            result.add(key, S3Light::Object.new(@client, @bucket, key, nil, true))
          rescue S3Light::Connection::HttpError => e
            if e.code == 404
              result.add(key, nil)
            else
              thread_poll.kill
              current_thread.raise(e)
            end
          rescue Exception => e
            thread_poll.kill
            current_thread.raise(e)
          end
        end

        thread_poll.wait_to_finish

        result.to_h
      ensure
        thread_poll.close
      end

      def download_batch(keys:, to: '/tmp', concurrency: 10)
        raise S3Light::Error, 'Invalid download path' unless File.directory?(to)
        to_path = Pathname.new(to)

        result = ConcurrentResult.new

        thread_poll = @client.build_thread_poll(concurrency)
        current_thread = Thread.current

        keys.each do |key|
          thread_poll.with_connection do |connection|
            download_path = to_path.join("#{SecureRandom.hex}-#{key}").to_s
            connection.download_file("/#{@bucket.name}/#{key}", download_path)

            result.add(key, download_path)
          rescue S3Light::Connection::HttpError => e
            if e.code == 404
              result.add(key, nil)
            else
              thread_poll.kill
              current_thread.raise(e)
            end
          rescue Exception => e
            thread_poll.kill
            current_thread.raise(e)
          end
        end

        thread_poll.wait_to_finish

        result.to_h
      ensure
        thread_poll&.close
      end
    end
  end
end
