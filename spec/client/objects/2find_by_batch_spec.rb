# frozen_string_literal: true

RSpec.describe 'find_by_batch' do
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
    bucket.objects.find_by_batch(keys: keys)
  end

  it 'checks if a batch of objects exists', vcr: { cassette_name: 's3_client/objects/find_by_batch' } do
    expect(subject).to be_a(Hash)
    expect(subject.keys).to match_array(keys)
    expect(subject.values).to all(be_a(S3Light::Object))
  end

  context "some don't exist" do
    let(:keys) do
      %w[item-1 item-3]
    end

    it 'checks if a batch of objects exists', vcr: { cassette_name: 's3_client/objects/find_by_batch_some_missing' } do
      expect(subject).to be_a(Hash)
      expect(subject.keys).to match_array(%w[item-1 item-3])
      expect(subject['item-1']).to be_a(S3Light::Object)
      expect(subject['item-3']).to be_nil
    end
  end
end
