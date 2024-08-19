# frozen_string_literal: true

module S3Light
  class Connection
    class Body
      def initialize(body)
        @body = body
        validate_body_type!
        @size = calculate_size
        @io = to_io
      end

      attr_reader :size

      def read(length = nil, outbuf = nil)
        @io.read(length, outbuf)
      end

      def rewind
        @io.rewind
      end

      private
        def to_io
          case @body
          when String
            StringIO.new(@body)
          when StringIO, IO
            @body
          when Enumerable
            StringIO.new(@body.to_a.join)
          when nil
            StringIO.new('')
          else
            raise RequestError, "body of wrong type: #{@body.class}"
          end
        end

        def calculate_size
          case @body
          when String
            @body.bytesize
          when StringIO, IO
            @body.size
          when Enumerable
            @body.to_a.join.bytesize
          when nil
            0
          else
            raise RequestError, 'cannot determine size of body'
          end
        end

        def validate_body_type!
          return if @body.is_a?(String)
          return if @body.respond_to?(:read)
          return if @body.is_a?(Enumerable)
          return if @body.nil?

          raise RequestError, "body of wrong type: #{@body.class}"
        end
    end
  end
end
