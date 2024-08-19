# frozen_string_literal: true

module S3Light
  class Bucket
    attr_accessor :name

    def initialize(client, name, persisted)
      @client = client
      @name = name
      @persisted = persisted
    end

    def inspect
      "#<#{self.class.name}>:#{object_id} @name=#{@name} @persisted=#{@persisted}"
    end
  end
end
