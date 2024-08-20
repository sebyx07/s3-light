# frozen_string_literal: true

module S3Light
  class Connection
    class HttpError < StandardError
      attr_reader :response

      def initialize(response)
        @response = response
        super("HTTP Error: #{response.code} - #{response.body}")
      end

      def code
        @response.code
      end
    end
    attr_reader :endpoint

    def initialize(endpoint:, access_key_id:, secret_access_key:, ssl_context:)
      @endpoint = URI(endpoint)
      @access_key_id = access_key_id
      @secret_access_key = secret_access_key
      @ssl_context = ssl_context
      @opened = false
    end

    def persistent_connection
      return @persistent_connection if @persistent_connection

      @persistent_connection = HTTP.persistent(@endpoint).headers(
        'User-Agent' => "S3Light/#{S3Light::VERSION}",
        'Host' => @endpoint.host
      )
      ObjectSpace.define_finalizer(self, self.class.close_connection(@persistent_connection))

      @persistent_connection
    end

    def make_request(method, path, headers: {}, body: nil)
      @opened = true
      full_path = URI.join(@endpoint, path).to_s
      request_time = Time.now.utc
      body = body.is_a?(Body) ? body : Body.new(body)

      headers = build_headers(method, full_path, headers, body, request_time)

      response = stream_request(method, full_path, headers, body)

      handle_response(response)
    end

    def download_file(path, output_path)
      @opened = true
      full_path = URI.join(@endpoint, path).to_s
      request_time = Time.now.utc

      headers = build_headers('GET', full_path, {}, Body.new(nil), request_time)

      File.open(output_path, 'wb') do |file|
        response = persistent_connection.headers(headers).get(full_path, ssl_context: @ssl_context)
        raise HttpError.new(response) if response.code > 399

        response.body.each do |chunk|
          file.write(chunk)
        end
      end

      output_path
    end

    def close
      @persistent_connection&.close
      @opened = false
    end

    def ==(other_connection)
      @endpoint == other_connection.endpoint
    end

    def inspect
      "#<#{self.class.name} @endpoint=#{@endpoint} @opened=#{@opened}>"
    end

    def self.close_connection(connection)
      proc do
        connection.close
      end
    end

    private
      def stream_request(method, full_path, headers, body)
        if body.size > 0
          headers['Content-Length'] = body.size.to_s
        end

        persistent_connection.headers(headers).request(
          method,
          full_path,
          ssl_context: @ssl_context,
          body: body
        )
      end

      def build_headers(method, path, headers, body, request_time)
        canonical_headers = {
          'host' => @endpoint.host,
          'x-amz-date' => request_time.strftime('%Y%m%dT%H%M%SZ'),
          'x-amz-content-sha256' => 'UNSIGNED-PAYLOAD'
        }

        canonical_headers['content-length'] = body.size.to_s if body.size > 0

        signed_headers = canonical_headers.keys.sort.join(';')

        auth_header = authorization_header(
          method,
          path,
          canonical_headers,
          signed_headers,
          body,
          request_time
        )

        headers.merge(canonical_headers).merge('Authorization' => auth_header)
      end

      def authorization_header(method, path, canonical_headers, signed_headers, body, request_time)
        algorithm = 'AWS4-HMAC-SHA256'
        credential_scope = credential_scope(request_time)
        string_to_sign = string_to_sign(method, path, canonical_headers, signed_headers, body, request_time)
        signature = signature(string_to_sign, request_time)

        "#{algorithm} Credential=#{@access_key_id}/#{credential_scope}, SignedHeaders=#{signed_headers}, Signature=#{signature}"
      end

      def credential_scope(request_time)
        date = request_time.strftime('%Y%m%d')
        region = @endpoint.host.split('.')[1] || 'us-east-1'
        "#{date}/#{region}/s3/aws4_request"
      end

      def string_to_sign(method, path, canonical_headers, signed_headers, body, request_time)
        uri = URI(path)
        canonical_request = [
          method.to_s.upcase,
          uri.path,
          uri.query || '',
          canonical_headers.sort.map { |k, v| "#{k}:#{v.strip}" }.join("\n") + "\n",
          signed_headers,
          'UNSIGNED-PAYLOAD'
        ].join("\n")

        [
          'AWS4-HMAC-SHA256',
          request_time.strftime('%Y%m%dT%H%M%SZ'),
          credential_scope(request_time),
          Digest::SHA256.hexdigest(canonical_request)
        ].join("\n")
      end

      def signature(string_to_sign, request_time)
        date = request_time.strftime('%Y%m%d')
        region = @endpoint.host.split('.')[1] || 'us-east-1'
        service = 's3'

        k_date = hmac("AWS4#{@secret_access_key}", date)
        k_region = hmac(k_date, region)
        k_service = hmac(k_region, service)
        k_signing = hmac(k_service, 'aws4_request')

        OpenSSL::HMAC.hexdigest('sha256', k_signing, string_to_sign)
      end

      def hmac(key, value)
        OpenSSL::HMAC.digest('sha256', key, value)
      end

      def handle_response(response)
        case response.code
        when 200..299
          Connection::Response.new(response)
        else
          raise HttpError.new(response)
        end
      end

      def chunked?(headers)
        headers['Transfer-Encoding'] == 'chunked'
      end
  end
end
