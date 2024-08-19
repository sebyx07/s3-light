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
      client.connection.make_request(:put, "/#{bucket.name}/#{key}", body: input)
      self.persisted = true

      self
    end
  end
end
