# frozen_string_literal: true

module S3Light
  class Connection
    class Body
      def initialize(body)
        @body = body
        validate_body_type!
      end

      def size
        @size ||=
          if @body.is_a?(String)
            @body.bytesize
          elsif @body.respond_to?(:size)
            @body.size
          elsif @body.nil?
            0
          else
            raise RequestError, 'cannot determine size of body'
          end
      end

      def each(&block)
        return enum_for(:each) unless block_given?

        if @body.is_a?(String)
          yield @body
        elsif @body.respond_to?(:read)
          yield_io(&block)
        elsif @body.is_a?(Enumerable)
          @body.each(&block)
        end
      end

      def to_s
        case @body
        when String
          @body
        when StringIO, IO
          @body.rewind
          @body.read.tap { @body.rewind }
        when Enumerable
          @body.to_a.join
        else
          ''
        end
      end

      private
        def yield_io
          buffer_size = S3Light.configuration.io_buffer_size
          while (chunk = @body.read(buffer_size))
            yield chunk
          end
          @body.rewind
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
