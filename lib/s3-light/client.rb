# frozen_string_literal: true

module S3Light
  class Client
    def initialize(endpoint: nil, access_key_id:, secret_access_key:, region: 'us-east-1', port: 443, ssl_context: nil)
      @access_key_id = access_key_id
      @secret_access_key = secret_access_key
      @region = region
      @port = port
      @ssl_context = ssl_context
      @endpoint = endpoint || amazon_default_endpoint
    end

    private
      def make_request(method, path, headers: {}, body: nil)
        # uri = URI.join(@endpoint, path)
        # request = Net::HTTP.const_get(method.capitalize).new(uri)
        # request.body = body
        # request['Authorization'] = authorization_header(method, uri, headers)
        # request['Date'] = Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
        # headers.each { |k, v| request[k] = v }
        # http = Net::HTTP.new(uri.host, uri.port)
        # http.use_ssl = @use_ssl
        # http.request(request)
      end


      def amazon_default_endpoint
        "https://s3.#{@region}.amazonaws.com"
      end
  end
end
