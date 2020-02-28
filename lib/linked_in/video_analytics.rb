module LinkedIn
  # Video Analytics API
  #
  # @see https://docs.microsoft.com/en-us/linkedin/marketing/integrations/community-management/shares/video-analytics-api
  #
  # [(contribute here)](https://github.com/mdesjardins/linkedin-v2)
  class VideoAnalytics < APIResource

    # Retrieve Analytics Data for a Video Entity.
    def video_analytics(options = {})
      urn = options.delete(:urn)
      type = options.delete(:type) || 'VIDEO_VIEW'
      aggregation = options.delete(:aggregation) || 'ALL'
      path = "/videoAnalytics?q=entity&entity=#{urn}&type=#{type}&aggregation=#{aggregation}"
      get(path, options)
    end

  end
end
