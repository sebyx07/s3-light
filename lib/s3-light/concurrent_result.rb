# frozen_string_literal: true

module S3Light
  class ConcurrentResult
    def initialize
      @hash = Concurrent::Hash.new
    end

    def add(key, value)
      @hash[key] = value
    end

    def to_h
      @hash
    end

    def inspect
      "#<#{self.class.name} @hash=#{@hash}>"
    end
  end
end
