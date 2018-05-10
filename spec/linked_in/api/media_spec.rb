require 'spec_helper'

describe LinkedIn::Media do
  let(:access_token) { 'dummy_access_token' }
  let(:api) { LinkedIn::API.new(access_token) }
  let(:base_uri) { double('uri', request_uri: 'http://example.org/elvis.png') }
  let(:media) { double('media', size: 2048, base_uri: base_uri).as_null_object }

  before do
    allow_any_instance_of(LinkedIn::Media).to receive(:open).and_return(media)
  end

  it "should be able to upload media" do
    result = '{"location": "urn:li:richMediaSummary:PNG-IMG-54f022ae8b3f4d479e925b4df68e19"}'
    stub_request(:post, 'https://api.linkedin.com/media/upload').to_return(body: result)
    expect(api.upload(source_url: "#{File.dirname(__FILE__)}/../../fixtures/elvis.jpg"))
      .to eq("location" => "urn:li:richMediaSummary:PNG-IMG-54f022ae8b3f4d479e925b4df68e19")
  end
end
