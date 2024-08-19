# frozen_string_literal: true

module S3Light
  class Connection
    class Response
      def initialize(http_response)
        @http_response = http_response
      end

      def xml
        return @xml if defined? @xml

        @xml = Nokogiri::XML(@http_response.body.to_s)
      end

      def code
        @http_response.code
      end

      def body
        @http_response.body
      end
    end
  end
end
