# frozen_string_literal: true

RSpec.describe 'Download object' do
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

  it 'downloads an object', vcr: { cassette_name: 's3_client/objects/download_object' } do
    download_path = object.download

    expect(File.exist?(download_path)).to be_truthy

    expect(File.read(download_path)).to eq('File content')
  ensure
    File.delete(download_path) if File.exist?(download_path)
  end
end
