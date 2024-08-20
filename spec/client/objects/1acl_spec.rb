# frozen_string_literal: true

RSpec.describe 'acl' do
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

  it 'handle acl', vcr: { cassette_name: 's3_client/objects/acl' } do
    expect(object.acl).to eq({ 'CanonicalUser' => 'FULL_CONTROL' })
  end
end
