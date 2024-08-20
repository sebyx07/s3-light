# frozen_string_literal: true

RSpec.describe 'check if object exists' do
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

  it 'returns true', vcr: { cassette_name: 's3_client/objects/object_exists' } do
    expect(bucket.objects.exists?(key: 'large_file.txt')).to be_truthy
  end

  it 'returns false', vcr: { cassette_name: 's3_client/objects/object_not_exists' } do
    expect(bucket.objects.exists?(key: 'large_fildwae.txt')).to be_falsey
  end
end
