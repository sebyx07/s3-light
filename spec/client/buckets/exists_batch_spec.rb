# frozen_string_literal: true

RSpec.describe 'S3Light::Client#buckets.exists_batch' do
  let(:client) do
    S3Light::Client.new(
      access_key_id: 'adminadmin',
      secret_access_key: 'adminadmin',
      endpoint: 'http://localhost:9000',
    )
  end

  subject do
    client.buckets.exists_batch?(names: %w[bucket-1 bucket-2])
  end

  it 'checks if a batch of buckets exists', vcr: { cassette_name: 's3_client/exists_batch' } do
    expect(subject).to be_a(Hash)
    expect(subject.keys).to match_array(%w[bucket-1 bucket-2])
    expect(subject.values).to all(be_truthy)
  end
end
