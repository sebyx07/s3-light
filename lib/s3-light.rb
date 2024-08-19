# frozen_string_literal: true

Dir.glob(File.join(File.dirname(__FILE__), 's3-light', '**', '*.rb')).each do |file|
  require file
end

module S3Light
end
