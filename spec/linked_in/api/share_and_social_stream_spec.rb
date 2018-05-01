require "spec_helper"

describe LinkedIn::ShareAndSocialStream do
  let(:access_token) { "dummy_access_token" }
  let(:api) { LinkedIn::API.new(access_token) }

  def stub(url)
    stub_request(:get, url).to_return(body: '{}')
  end

  # no longer supported in v2?
  # it "should be able to view network_updates" do
  #   stub("https://api.linkedin.com/v1/people/~/network/updates?")
  #   expect(api.network_updates).to be_an_instance_of(LinkedIn::Mash)
  # end

  # it "should be able to view network_update's comments" do
  #   stub("https://api.linkedin.com/v1/people/~/network/updates/key=network_update_key/update-comments?")
  #   expect(api.share_comments("network_update_key")).to be_an_instance_of(LinkedIn::Mash)
  # end

  it "should be able to view comment's likes" do
    stub('https://api.linkedin.com/v2/socialActions/urn:li:comment:123/likes')
    expect(api.likes(urn: 'urn:li:comment:123')).to be_an_instance_of(LinkedIn::Mash)
  end

  it "should be able to share a new status" do
    stub_request(:post, 'https://api.linkedin.com/v2/shares').to_return(body: '', status: 201)
    response = api.share(comment: 'Testing, 1, 2, 3')
    expect(response.status).to eq 201
    expect(response.body).to eq ''
  end

  it "returns the shares for a person" do
    stub('https://api.linkedin.com/v2/shares?after=1234&count=35&owners=&q=owners')
    api.shares(:after => 1234, :count => 35)
  end

  # it "should be able to comment on network update" do
  #   stub_request(:post, "https://api.linkedin.com/v1/people/~/network/updates/key=SOMEKEY/update-comments?oauth2_access_token=#{access_token}").to_return(body: "", status: 201)
  #   response = api.update_comment('SOMEKEY', "Testing, 1, 2, 3")
  #   expect(response.body).to eq ""
  #   expect(response.status).to eq 201
  # end

  it "should be able to like a share" do
    stub_request(:post, 'https://api.linkedin.com/v2/socialActions/urn:li:organization:123/likes')
      .to_return(body: "", status: 201)
    response = api.like(urn: 'urn:li:organization:123', object: 'urn:li:share:456', actor: 'urn:li:person:789')
    expect(response.body).to eq ""
    expect(response.status).to eq 201
  end

  # it "should be able to unlike a network update" do
  #   stub_request(:put, "https://api.linkedin.com/v1/people/~/network/updates/key=SOMEKEY/is-liked?oauth2_access_token=#{access_token}").to_return(body: "", status: 201)
  #   response = api.unlike_share('SOMEKEY')
  #   expect(response.body).to eq ""
  #   expect(response.status).to eq 201
  # end

  context 'throttling' do
    # Not sure what LinkedIn does on a rate limit violation on v2? It's
    # not documented here:
    # https://developer.linkedin.com/docs/guide/v2/concepts/rate-limits
    xit 'throws the right exception' do
      stub_request(:post, "https://api.linkedin.com/v1/people/~/shares?format=json&oauth2_access_token=#{access_token}")
        .to_return(
          body: "{\n  \"errorCode\": 0,\n  \"message\": \"Throttle limit for calls to this resource is reached.\",\n  \"requestId\": \"M784AXE9MJ\",\n  \"status\": 403,\n  \"timestamp\": 1412871058321\n}",
          status: 403
        )

      err_msg = LinkedIn::ErrorMessages.throttled
      expect {
        api.share(:comment => 'Testing, 1, 2, 3')
      }.to raise_error(LinkedIn::AccessDeniedError, err_msg)

      error = nil
      begin
        api.add_share(:comment => "Testing, 1, 2, 3")
      rescue => e
        error = e
      end

      expect(error.data["status"]).to eq 403
    end
  end
end
