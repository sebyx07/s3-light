# frozen_string_literal: true

RSpec.describe 'Open object' do
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

  let(:object) do
    bucket.objects.find_by(key: 'test_file.txt')
  end

  it 'opens an object', vcr: { cassette_name: 's3_client/objects/open_object' } do
    temp_file = object.open 'r+' do |file|
      expect(file.read).to eq('File content')
      file.write('New content')
    end

    object.save!
  ensure
    File.delete(temp_file.path) if File.exist?(temp_file.path)
  end
end
