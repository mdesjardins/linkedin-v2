require 'mime/types'

module LinkedIn
  DEFAULT_TIMEOUT_SECONDS = 300

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

    # Uploads rich media content to LinkedIn from a supplied URL.
    #
    # @see https://developer.linkedin.com/docs/guide/v2/shares/rich-media-shares#upload
    #
    # @options options [String] :source_url, the URL to the content to be uploaded.
    # @options options [Numeric] :timeout, optional timeout value in seconds, defaults to 300.
    # @return [LinkedIn::Mash]
    #
    def upload(options = {})
      source_url = options.delete(:source_url)
      timeout = options.delete(:timeout) || DEFAULT_TIMEOUT_SECONDS
      media_upload_endpoint = LinkedIn.config.api + '/media/upload'

      response =
        @connection.post(media_upload_endpoint, file: file(source_url)) do |req|
          req.headers['Accept'] = 'application/json'
          req.options.timeout = timeout
          req.options.open_timeout = timeout
        end
      Mash.from_json(response.body)
    end

    private

    def upload_filename(media)
      File.basename(media.base_uri.request_uri)
    end

    def extension(media)
      upload_filename(media).split('.').last
    end

    def content_type(media)
      ::MIME::Types.type_for(extension(media)).first.content_type
    end

    def file(source_url)
      media = open(source_url, 'rb')
      io = StringIO.new(media.read)
      Faraday::UploadIO.new(io, content_type(media), upload_filename(media))
    end
  end
end
