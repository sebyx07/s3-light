# frozen_string_literal: true

RSpec.describe 'S3Light::Client#buckets.all' do
  let(:client) do
    S3Light::Client.new(
      access_key_id: 'adminadmin',
      secret_access_key: 'adminadmin',
      endpoint: 'http://localhost:9000',
    )
  end

  subject do
    client.buckets.all
  end

  it 'returns a list of buckets', vcr: { cassette_name: 's3_client/list_buckets' } do
    expect(subject).to be_an(Array)
    expect(subject.size).to eq(1)
    expect(subject.first).to be_a(S3Light::Bucket)
  end
end
