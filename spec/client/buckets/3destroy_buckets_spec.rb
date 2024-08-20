# frozen_string_literal: true

RSpec.describe 'S3Light::Client#buckets.destroy' do
  let(:client) do
    S3Light::Client.new(
      access_key_id: 'adminadmin',
      secret_access_key: 'adminadmin',
      endpoint: 'http://localhost:9000',
    )
  end

  subject do
    client.buckets.find_by(name: 'another-bucket').tap do |bucket|
      bucket.destroy!
    end
  end

  it 'destroys an existing bucket', vcr: { cassette_name: 's3_client/destroy_bucket' } do
    expect(subject).to be_a(S3Light::Bucket)
    expect(subject.name).to eq('another-bucket')
    expect(subject).not_to be_persisted
  end
end
