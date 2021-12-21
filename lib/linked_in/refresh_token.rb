module LinkedIn
    # Refresh Token API
    #
    # @see https://docs.microsoft.com/en-us/linkedin/shared/authentication/programmatic-refresh-tokens
    #
    class RefreshToken < APIResource
  
      def refresh_token(options = {})
        path = "/accessToken"
        get(path, options)
      end
  
    end
  end