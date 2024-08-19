# frozen_string_literal: true

RSpec.describe 'create S3Light::Object' do
  let(:client) do
    S3Light::Client.new(
      access_key_id: 'adminadmin',
      secret_access_key: 'adminadmin',
      endpoint: 'http://localhost:9000',
    )
  end

  let(:bucket) do
    client.buckets.find_by(name: 'test')
  end

  describe 'creating objects' do
    it 'creates a new object with string content', vcr: { cassette_name: 's3_client/objects/create_object_string' } do
      object = bucket.objects.new(key: 'test.txt', input: 'Hello, World!').save!

      expect(object).to be_a(S3Light::Object)
      expect(object).to be_persisted
      expect(object.key).to eq('test.txt')
    end

    it 'creates a new object with file content', vcr: { cassette_name: 's3_client/objects/create_object_file' } do
      Tempfile.create(%w[test .txt]) do |file|
        file.write('File content')
        file.rewind

        object = bucket.objects.new(key: 'test_file.txt', input: file).save!

        expect(object).to be_a(S3Light::Object)
        expect(object).to be_persisted
        expect(object.key).to eq('test_file.txt')
      end
    end

    it 'creates a new object with StringIO content', vcr: { cassette_name: 's3_client/objects/create_object_stringio' } do
      stringio = StringIO.new('StringIO content')
      object = bucket.objects.new(key: 'stringio.txt', input: stringio).save!

      expect(object).to be_a(S3Light::Object)
      expect(object).to be_persisted
      expect(object.key).to eq('stringio.txt')
    end

    it 'handles large file uploads', vcr: { cassette_name: 's3_client/objects/create_object_large_file' } do
      Tempfile.create(%w[large .txt]) do |file|
        file.write('0' * 10_000_000) # 10MB file
        file.rewind

        object = bucket.objects.new(key: 'large_file.txt', input: file).save!

        expect(object).to be_a(S3Light::Object)
        expect(object).to be_persisted
        expect(object.key).to eq('large_file.txt')
      end
    end
  end
end
