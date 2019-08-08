module LinkedIn
  # Ad Analytics API
  #
  # @see https://docs.microsoft.com/en-us/linkedin/marketing/integrations/ads-reporting/ads-reporting
  #
  # [(contribute here)](https://github.com/mdesjardins/linkedin-v2)
  class AdAnalytics < APIResource

    PIVOT_TO_PARAM = {
        'SHARE' => 'shares',
        'CAMPAIGN' => 'campaigns',
        'CREATIVE' => 'creatives',
        'CAMPAIGN_GROUP' => 'campaignGroups',
        'ACCOUNT' => 'accounts',
        'COMPANY' => 'companies'
    }.freeze

    def ad_analytics(options = {})
      pivot = options.delete(:pivot) || 'SHARE'
      granularity = options.delete(:granularity) || 'ALL'
      date_from = options.delete(:date_from) || 2.weeks.ago.to_date
      urns = options.delete(:urns) || []
      urns.map!{|urn| urn.is_a?(Numeric) ? id_to_urn(pivot.downcase, urn) : urn}
      urn_params = urns.each_with_index.map{|urn, i| "#{PIVOT_TO_PARAM[pivot]}[#{i}]=#{urn}"}.join('&')

      path = "/adAnalyticsV2?q=analytics&pivot=#{pivot}&#{date_to_params(date_from)}&timeGranularity=#{granularity}&#{urn_params}"
      get(path, options)
    end


    private ##############################################################

    def date_to_params(date)
      "dateRange.start.day=#{date.day}&dateRange.start.month=#{date.month}&dateRange.start.year=#{date.year}"
    end

  end
end
