# frozen_string_literal: true

RSpec.describe 'S3Light::Client#buckets.new' do
  let(:client) do
    S3Light::Client.new(
      access_key_id: 'adminadmin',
      secret_access_key: 'adminadmin',
      endpoint: 'http://localhost:9000',
    )
  end

  subject do
    client.buckets.new(name: 'another-bucket').save
  end

  it 'creates a new bucket', vcr: { cassette_name: 's3_client/create_bucket' } do
    expect(subject).to be_a(S3Light::Bucket)
    expect(subject.name).to eq('another-bucket')
    expect(subject).to be_persisted
  end
end
