# frozen_string_literal: true

require 'http'
require 'pathname'
require 'stringio'
require 'digest'
require 'base64'
require 'time'
require 'openssl/hmac'
require 'nokogiri'

Dir.glob(File.join(File.dirname(__FILE__), 's3-light', '**', '*.rb')).each do |file|
  require file
end

module S3Light
  class << self
    def self.configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
