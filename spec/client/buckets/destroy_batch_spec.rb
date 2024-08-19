# frozen_string_literal: true

RSpec.describe 'S3Light::Client#buckets.destroy_batch' do
  let(:client) do
    S3Light::Client.new(
      access_key_id: 'adminadmin',
      secret_access_key: 'adminadmin',
      endpoint: 'http://localhost:9000',
    )
  end

  subject do
    client.buckets.destroy_batch(names: %w[bucket-1 bucket-2])
  end

  it 'destroys a batch of buckets', vcr: { cassette_name: 's3_client/destroy_batch' } do
    expect(subject).to be_a(Hash)
    expect(subject.keys).to match_array(%w[bucket-1 bucket-2])
    expect(subject.values).to all(be_truthy)
  end
end
