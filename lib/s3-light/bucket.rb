# frozen_string_literal: true

module S3Light
  Bucket = Struct.new(:client, :name, :persisted) do
    def initialize(client, name, persisted = false)
      super(client, name, persisted)
    end

    def save!
      if persisted
        raise 'Bucket already exists'
      end

      if name.nil? || name.empty?
        raise 'Bucket name is required'
      end

      self.client.with_connection do |connection|
        __save!(connection)
      end

      self.persisted = true
      self
    end

    def destroy
      unless persisted
        raise 'Bucket does not exist'
      end

      self.client.with_connection do |connection|
        __destroy!(connection)
      end

      self.persisted = false
      true
    end

    def objects
      @objects ||= S3Light::Client::ObjectsList.new(client, self)
    end

    def __destroy!(connection)
      connection.make_request(:delete, "/#{name}")
    end

    def __save!(connection)
      connection.make_request(:put, "/#{name}")
    end

    def persisted?
      persisted
    end

    def inspect
      "#<#{self.class.name} @name=#{name} @persisted=#{persisted}>"
    end
  end
end
