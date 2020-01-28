require "oauth2"

require "linked_in/errors"
require "linked_in/raise_error"
require "linked_in/version"
require "linked_in/configuration"

# Responsible for all authentication
# LinkedIn::OAuth2 inherits from OAuth2::Client
require "linked_in/oauth2"

# Coerces LinkedIn JSON to a nice Ruby hash
# LinkedIn::Mash inherits from Hashie::Mash
require "hashie"
require "linked_in/mash"

# Wraps a LinkedIn-specifc API connection
# LinkedIn::Connection inherits from Faraday::Connection
require "faraday"
require "linked_in/connection"

# Data object to wrap API access token
require "linked_in/access_token"

# Endpoints inherit from APIResource
require "linked_in/api_resource"

# All of the endpoints
require "linked_in/jobs"
require "linked_in/people"
require "linked_in/search"
# require "linked_in/groups" not supported by v2 API?
require "linked_in/organizations"
require "linked_in/communications"
require "linked_in/share_and_social_stream"
require 'linked_in/media' # To be deprecated 01.30.2020
require "linked_in/assets"

# The primary API object that makes requests.
# It composes in all of the endpoints
require "linked_in/api"

module LinkedIn
  @config = Configuration.new

  class << self
    attr_accessor :config
  end

  def self.configure
    yield self.config
  end
end
