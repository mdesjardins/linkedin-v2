module LinkedIn
  # Ad Analytics API
  #
  # @see https://docs.microsoft.com/en-us/linkedin/marketing/integrations/ads-reporting/ads-reporting
  #
  # [(contribute here)](https://github.com/mdesjardins/linkedin-v2)
  class AdAnalytics < APIResource

    # options[:pivot] Pivot of results, by which each report data point is grouped. The following enum values are supported:
    # COMPANY - Group results by advertiser's company.
    # ACCOUNT - Group results by account.
    # SHARE - Group results by sponsored share.
    # CAMPAIGN - Group results by campaign.
    # CREATIVE - Group results by creative.
    # CAMPAIGN_GROUP - Group results by campaign group.
    # CONVERSION - Group results by conversion.
    # SERVING_LOCATION - Group results by serving location, onsite or offsite.
    # CARD_INDEX - Group results by the index of where a card appears in a carousel ad creative. Metrics are based on the index of the card at the time when the user's action (impression, click, etc.) happened on the creative (Carousel creatives only).
    # MEMBER_COMPANY_SIZE - Group results by member company size.
    # MEMBER_INDUSTRY - Group results by member industry.
    # MEMBER_SENIORITY - Group results by member seniority.
    # MEMBER_JOB_TITLE - Group results by member job title.
    # MEMBER_JOB_FUNCTION - Group results by member job function.
    # MEMBER_COUNTRY - Group results by member country.
    # MEMBER_REGION - Group results by member region.
    # MEMBER_COMPANY - Group results by member company.
    # 
    # options[:facet] 
    # shares - Match result by share facets. Defaults to empty.
    # campaigns - Match result by campaign facets. Defaults to empty.
    # creatives -	Match result by creative facets. Defaults to empty.
    # campaignGroups - Match result by campaign group facets. Defaults to empty.
    # accounts - Match result by sponsored ad account facets. Defaults to empty.
    # companies - Match result by company facets. Defaults to empty.
    #
    # options[:fields] (REQUIRED) Array of fields to return. Defaults to empty.
    #
    # options[:urns] Array of urns to match the facet on.
    def ad_analytics(options = {})
      pivot = options.delete(:pivot) || 'SHARE'
      facet = options.delete(:facet) || 'shares'
      granularity = options.delete(:granularity) || 'ALL'
      fields = options.delete(:fields) || []
      date_from = options.delete(:date_from) || 2.weeks.ago.to_date
      urns = options.delete(:urns) || []
      urns.map!{|urn| urn.is_a?(Numeric) ? id_to_urn(pivot.downcase, urn) : urn}
      urn_params = urns.each_with_index.map{|urn, i| "#{facet}[#{i}]=#{urn}"}.join('&')

      path = "/adAnalyticsV2?q=analytics&pivot=#{pivot}&#{date_to_params(date_from)}&timeGranularity=#{granularity}&fields=#{fields.join(',')}&#{urn_params}"
      get(path, options)
    end


    private ##############################################################

    def date_to_params(date)
      "dateRange.start.day=#{date.day}&dateRange.start.month=#{date.month}&dateRange.start.year=#{date.year}"
    end

  end
end
