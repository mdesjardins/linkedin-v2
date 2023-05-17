require "spec_helper"

describe LinkedIn::Media do
  let(:access_token) { "dummy_access_token" }
  let(:api) { LinkedIn::API.new(access_token) }
  let(:base_uri) { double("uri", request_uri: "http://example.org/elvis.png") }
  let(:media) { double("media", size: 2048, base_uri: base_uri).as_null_object }
  let(:type) { "person" }
  let(:urn) { "12345678" }
  let(:upload_url) { "https://api.linkedin.com/mediaUpload/foobar" }
  let(:upload_register_response) {
    '{
      "value": {
          "uploadMechanism": {
              "com.linkedin.digitalmedia.uploading.MediaUploadHttpRequest": {
                  "headers": {
                      "media-type-family": "STILLIMAGE"
                  },
                  "uploadUrl": "' + upload_url + '"
              }
          },
          "mediaArtifact": "urn:li:digitalmediaMediaArtifact:(urn:li:digitalmediaAsset:C5522AQHn46pwH96hxQ,urn:li:digitalmediaMediaArtifactClass:feedshare-uploadedImage)",
          "asset": "urn:li:digitalmediaAsset:C5522AQHn46pwH96hxQ"
      }
    }'
  }

  before do
    allow_any_instance_of(LinkedIn::Media).to receive(:open).and_return(media)
  end

  it "should get an upload url" do
    stub_request(:post, "https://api.linkedin.com/v2/assets?action=registerUpload").to_return(body: upload_register_response)
    expect(api.register_upload(type: type, urn: urn)).to eq(LinkedIn::Mash.from_json(upload_register_response))
  end

  it "should be able to upload media" do
    stub_request(:post, "https://api.linkedin.com/v2/assets?action=registerUpload").to_return(body: upload_register_response)
    stub_request(:put, upload_url).to_return(status: 201, body: '{"asset": "urn:li:digitalmediaAsset:C5522AQHn46pwH96hxQ"}')
    expect(api.upload(source_url: "#{File.dirname(__FILE__)}/../../fixtures/elvis.jpg"))
      .to eq("urn:li:digitalmediaAsset:C5522AQHn46pwH96hxQ")
  end
end
