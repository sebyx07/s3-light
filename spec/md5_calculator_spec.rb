# frozen_string_literal: true

RSpec.describe S3Light::Md5Calculator do
  context 'when input is a string' do
    it 'returns the MD5 hash of the string' do
      md5 = described_class.new('Hello, world!').md5
      expect(md5).to eq('6cd3556deb0da54bca060b4c39479839')
    end
  end

  context 'when input is an IO object' do
    it 'returns the MD5 hash of the IO object' do
      io = StringIO.new('Hello, world!')
      md5 = described_class.new(io).md5
      expect(md5).to eq('6cd3556deb0da54bca060b4c39479839')
    end
  end

  context 'when input is a Pathname object' do
    it 'returns the MD5 hash of the file at the path' do
      file_path = Pathname.new('spec/md5_calculator_spec.rb')
      md5 = described_class.new(file_path).md5
      expect(md5).not_to be_nil
    end
  end
end
