require "spec_helper"

describe LinkedIn::Organizations do
  let(:access_token) {"dummy_access_token"}
  let(:api) {LinkedIn::API.new(access_token)}

  def stub(url)
    url += "oauth2_access_token=#{access_token}"
    stub_request(:get, url).to_return(body: '{}')
  end

  it "should be able to view an organization profile" do
    stub("https://api.linkedin.com/v2/organizations/1586?")
    expect(api.organization(id: 1586)).to be_an_instance_of(LinkedIn::Mash)
  end

  it "should be able to view an organization by vanity name" do
    stub("https://api.linkedin.com/v2/organizationss?q=vanityName&vanityName=acme")
    expect(api.company(vanity_name: "acme")).to be_an_instance_of(LinkedIn::Mash)
  end

  it "should be able to view an organization by e-mail domain" do
    stub("https://api.linkedin.com/v2/organizations?q=emailDomain&emailDoman=acme.com")
    expect(api.company(domain: "acme.com")).to be_an_instance_of(LinkedIn::Mash)
  end

  it "should load correct organization data" do
    VCR.use_cassette("organization data") do
      data = api.company(id: 1586, fields: %w[id name])
      expect(data.id).to eq 1586
      expect(data.name).to eq "Amazon"
    end
  end

  it "should load historical page statistics" do
    stub("https://api.linkedin.com/v2/organizationPageStatistics?q=organization&organization=urn:li:organization:123456")
    expect(
      api.organization_page_statistics(id: 123456)
    ).to be_an_instance_of(LinkedIn::Mash)
  end

  it "should load historical follow statistics" do
    stub("https://api.linkedin.com/v2/organizationalEntityFollowerStatistics?q=organizationalEntity&organizationalEntity=urn:li:organization:123456")
    expect(
      api.organization_follower_statistics(id: 123456)
    ).to be_an_instance_of(LinkedIn::Mash)
  end

  it "should load historical share statistics" do
    stub("https://api.linkedin.com/v2/organizationalEntityShareStatistics?q=organizationalEntity&organizationalEntity=urn:li:organization:123456")
    expect(
      api.organization_follower_statistics(id: 123456)
    ).to be_an_instance_of(LinkedIn::Mash)
  end
end
