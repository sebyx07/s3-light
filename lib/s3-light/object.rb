# frozen_string_literal: true

module S3Light
  Object = Struct.new(:client, :bucket, :key, :input, :persisted) do
    def initialize(client, bucket, id, input, persisted = false)
      super(client, bucket, id, input, persisted)
    end

    def persisted?
      persisted
    end

    def inspect
      "#<#{self.class.name} @id=#{key} @bucket=#{bucket.name}>"
    end

    def save!
      raise S3Light::Error, 'Input is empty' if input.nil?

      self.client.with_connection do |connection|
        __save!(connection)
      end
      self.persisted = true

      self
    end

    def destroy!
      unless persisted
        raise S3Light::Error, 'Object does not exist'
      end

      self.client.with_connection do |connection|
        __destroy!(connection)
      rescue S3Light::Connection::HttpError => e
        raise e unless e.code == 404
      end

      self.persisted = false
      true
    end

    def acl
      return @acl if defined?(@acl)

      response = client.with_connection do |connection|
        connection.make_request(:get, "/#{bucket.name}/#{key}?acl=1")
      end

      @acl = response.xml.remove_namespaces!.xpath('//AccessControlList/Grant').each_with_object({}) do |grant, result|
        permission = grant.at_xpath('Permission').text
        grantee = grant.at_xpath('Grantee')

        grantee_type = grantee['type']

        identifier =
          case grantee_type
          when 'CanonicalUser'
            grantee.at_xpath('ID')&.text || 'CanonicalUser'
          when 'Group'
            grantee.at_xpath('URI')&.text
          else
            grantee.at_xpath('EmailAddress')&.text
          end

        result[identifier] = permission if identifier
      end
    end


    def acl=(new_acl)
      xml_body = build_acl_xml(new_acl)

      client.with_connection do |connection|
        connection.make_request(:put, "/#{bucket.name}/#{key}?acl=1", body: xml_body)
      end

      @acl = new_acl
    end

    def download(to: nil)
      raise S3Light::Error, 'Object does not exist' unless persisted

      to ||= "/tmp/#{SecureRandom.hex}-#{key}"

      self.client.with_connection do |connection|
        __download(to, connection)
      end
    end

    def open(mode = 'r', &block)
      raise S3Light::Error, 'Object does not exist' unless persisted
      download_path = download
      file = File.open(download_path, mode)
      yield file
      self.input = file
      file
    end

    def __save!(connection)
      connection.make_request(:put, "/#{bucket.name}/#{key}", body: input)
    end

    def __destroy!(connection)
      connection.make_request(:delete, "/#{bucket.name}/#{key}")
    end

    def __download(to, connection)
      connection.download_file("/#{bucket.name}/#{key}", to)
    end

    private
      def build_acl_xml(acl)
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.AccessControlPolicy {
            xml.AccessControlList {
              acl.each do |grantee, permission|
                xml.Grant {
                  xml.Grantee('xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:type' => 'CanonicalUser') {
                    xml.ID grantee
                    xml.DisplayName grantee
                  }
                  xml.Permission permission
                }
              end
            }
          }
        end

        builder.to_xml
      end
  end
end
