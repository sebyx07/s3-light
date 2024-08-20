# frozen_string_literal: true

RSpec.describe 'destroy object' do
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

  let(:object) do
    bucket.objects.find_by(key: 'test.txt')
  end

  describe 'destroying objects' do
    it 'destroys an object', vcr: { cassette_name: 's3_client/objects/destroy_object' } do
      object.destroy!

      expect(object).not_to be_persisted
    end
  end
end
