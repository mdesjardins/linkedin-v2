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
require 'linked_in/media'
require 'linked_in/ugc_posts'
require 'linked_in/video_analytics'
require 'linked_in/ad_accounts'
require 'linked_in/ad_analytics'
require 'linked_in/standardized_data'
require 'linked_in/refresh_token'

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

module Faraday
  module FlatParamsEncoder
    def self.encode(params)
      return nil if params == nil

      if !params.is_a?(Array)
        if !params.respond_to?(:to_hash)
          raise TypeError,
                "Can't convert #{params.class} into Hash."
        end
        params = params.to_hash
        params = params.map do |key, value|
          key = key.to_s if key.kind_of?(Symbol)
          [key, value]
        end
        # Useful default for OAuth and caching.
        # Only to be used for non-Array inputs. Arrays should preserve order.
        params.sort!
      end

      # The params have form [['key1', 'value1'], ['key2', 'value2']].
      buffer = ''
      params.each do |key, value|
        encoded_key = escape(key)
        value = value.to_s if value == true || value == false
        if value == nil
          buffer << "#{encoded_key}&"
        elsif value.kind_of?(Array)
          value.each do |sub_value|
            encoded_value = escape(sub_value)
            buffer << "#{encoded_key}=#{encoded_value}&"
          end
        else
          if value.to_s.include?('List')
            # List param must be encoded separately
            urns = value.gsub('List(','').gsub(')','').split(',')
            encoded_value = "List(#{urns.map{|u| escape(u)}.join(',')})"
          else
            encoded_value = escape(value)
          end
          buffer << "#{encoded_key}=#{encoded_value}&"
        end
      end
      return buffer.chop
    end
  end
end