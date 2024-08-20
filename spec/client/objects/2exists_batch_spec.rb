# frozen_string_literal: true

RSpec.describe 'exists_batch' do
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

  let(:keys) do
    %w[item-1 item-2]
  end

  subject do
    bucket.objects.exists_batch?(keys: keys)
  end

  it 'checks if a batch of objects exists', vcr: { cassette_name: 's3_client/objects/exists_batch' } do
    expect(subject).to be_a(Hash)
    expect(subject.keys).to match_array(keys)
    expect(subject.values).to all(be_truthy)
  end
end
