module LinkedIn
  # Ad Accounts API
  #
  # @see https://docs.microsoft.com/en-us/linkedin/marketing/integrations/ads/account-structure/create-and-manage-accounts
  #
  # [(contribute here)](https://github.com/mdesjardins/linkedin-v2)
  class AdAccounts < APIResource

    def ad_accounts(options = {})
      path = "/adAccountsV2"
      get(path, options)
    end

  end
end
