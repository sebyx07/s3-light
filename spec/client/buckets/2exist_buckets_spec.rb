# frozen_string_literal: true

RSpec.describe 'S3Light::Client#buckets.exists?' do
  let(:client) do
    S3Light::Client.new(
      access_key_id: 'adminadmin',
      secret_access_key: 'adminadmin',
      endpoint: 'http://localhost:9000',
    )
  end

  subject do
    client.buckets.exists?(name: 'test')
  end

  it 'returns true if the bucket exists', vcr: { cassette_name: 's3_client/exists_bucket' } do
    expect(subject).to be_truthy
  end
end
