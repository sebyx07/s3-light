# frozen_string_literal: true

module S3Light
  class Configuration
    attr_accessor :io_buffer_size

    def initialize
      @io_buffer_size = 16 * (1024 * 1024)
    end
  end
end
