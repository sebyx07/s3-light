# frozen_string_literal: true

module S3Light
  Object = Struct.new(:client, :bucket, :key, :input, :persisted) do
    def initialize(client, bucket, id, input, persisted = false)
      super(client, bucket, id, input, persisted)
    end

    def persisted?
      persisted
    end

    def inspect
      "#<#{self.class.name} @id=#{key} @bucket=#{bucket.name}>"
    end

    def save!
      raise S3Light::Error, 'Input is empty' if input.nil?

      self.client.with_connection do |connection|
        __save!(connection)
      end
      self.persisted = true

      self
    end

    def destroy!
      unless persisted
        raise S3Light::Error, 'Object does not exist'
      end

      self.client.with_connection do |connection|
        __destroy!(connection)
      end

      self.persisted = false
      true
    end

    def download(to: nil)
      raise S3Light::Error, 'Object does not exist' unless persisted

      to ||= "/tmp/#{SecureRandom.hex}-#{key}"

      self.client.with_connection do |connection|
        __download(to, connection)
      end
    end

    def open(mode = 'r', &block)
      raise S3Light::Error, 'Object does not exist' unless persisted
      download_path = download
      file = File.open(download_path, mode)
      yield file
      self.input = file
      file
    end

    def __save!(connection)
      connection.make_request(:put, "/#{bucket.name}/#{key}", body: input)
    end

    def __destroy!(connection)
      connection.make_request(:delete, "/#{bucket.name}/#{key}")
    end

    def __download(to, connection)
      connection.download_file("/#{bucket.name}/#{key}", to)
    end
  end
end
