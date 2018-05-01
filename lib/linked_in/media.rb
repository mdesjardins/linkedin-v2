module LinkedIn
  # Rich Media APIs
  #
  # @see https://developer.linkedin.com/docs/guide/v2/shares/rich-media-shares
  #
  # [(contribute here)](https://github.com/mdesjardins/linkedin-v2)
  class Media < APIResource
    def summary(options = {})
      path = "/richMediaSummariesV2/#{options.delete(:id)}"
      get(path, options)
    end
  end
end
