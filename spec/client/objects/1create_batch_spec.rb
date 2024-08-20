# frozen_string_literal: true

RSpec.describe 'create_batch' do
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

  let(:io_items) do
    {
      'item-1' => StringIO.new('content-1'),
      'item-2' => 'content-2',
    }
  end
  subject do
    bucket.objects.create_batch(input: io_items)
  end

  it 'uploads', vcr: { cassette_name: 's3_client/objects/create_batch' } do
    expect(subject).to be_a(Hash)

    expect(subject.keys).to match_array(%w[item-1 item-2])
  end
end
