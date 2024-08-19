# frozen_string_literal: true

module S3Light
  class Md5Calculator
    def initialize(input)
      @input = input
    end

    def md5
      @md5 ||=
        case @input
        when String
          Digest::MD5.hexdigest(@input)
        when IO, StringIO
          compute_md5_for_io
        when Pathname
          compute_md5_for_file_path
        else
          raise ArgumentError, "Unsupported input type: #{@input.class}"
        end
    end

    def inspect
      "#<#{self.class.name}>"
    end

    private
      def compute_md5_for_io
        Digest::MD5.new.tap do |md5|
          io_buffer_size = S3Light.configuration.io_buffer_size
          while chunk = @input.read(io_buffer_size)
            md5 << chunk
          end
          @input.rewind
        end.hexdigest
      end

      def compute_md5_for_file_path
        Digest::MD5.new.tap do |md5|
          io_buffer_size = S3Light.configuration.io_buffer_size
          File.open(@input, 'rb') do |file|
            while chunk = file.read(io_buffer_size)
              md5 << chunk
            end
          end
        end.hexdigest
      end
  end
end
