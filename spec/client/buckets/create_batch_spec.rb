# frozen_string_literal: true

RSpec.describe 'S3Light::Client#buckets.create_batch' do
  let(:client) do
    S3Light::Client.new(
      access_key_id: 'adminadmin',
      secret_access_key: 'adminadmin',
      endpoint: 'http://localhost:9000',
    )
  end

  subject do
    client.buckets.create_batch(names: %w[bucket-1 bucket-2])
  end

  it 'creates a batch of new buckets', vcr: { cassette_name: 's3_client/create_batch' } do
    expect(subject).to be_a(Hash)
    expect(subject.keys).to match_array(%w[bucket-1 bucket-2])
    expect(subject.values).to all(be_a(S3Light::Bucket))
    expect(subject.values.map(&:name)).to match_array(%w[bucket-1 bucket-2])
    expect(subject.values).to all(be_persisted)
  end
end
