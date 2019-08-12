module LinkedIn
  # Ad Accounts API
  #
  # @see https://docs.microsoft.com/en-us/linkedin/marketing/integrations/ads/account-structure/create-and-manage-accounts
  #
  # [(contribute here)](https://github.com/mdesjardins/linkedin-v2)
  class AdAccounts < APIResource

    def ad_accounts(options = {})
      path = "/adAccountsV2?q=search"
      get(path, options)
    end

    def ad_campaigns(options = {})
      ad_account = options.delete(:ad_account)
      path = "adCampaignsV2?q=search&search.account.values[0]=#{ad_account}"
      get(path, options)
    end

    def ad_creatives(options = {})
      status = options.delete(:status) || 'ACTIVE'
      path = "/adCreativesV2?q=search&search.status.values[0]=#{status}"
      get(path, options)
    end

  end
end
