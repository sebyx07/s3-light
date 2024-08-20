# frozen_string_literal: true

RSpec.describe 'destroy_batch' do
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
    bucket.objects.destroy_batch(keys: keys)
  end

  it 'downloads a batch of objects', vcr: { cassette_name: 's3_client/objects/destroy_batch' } do
    expect(subject).to be_a(Hash)
    expect(subject.keys).to match_array(keys)

    expect(subject.values).to all(be_truthy)
  end
end
