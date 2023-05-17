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
  # @see https://docs.microsoft.com/en-us/linkedin/marketing/integrations/community-management/shares/vector-asset-api?tabs=http#upload-the-image
  #
  # @options options [String] :source_url, the URL to the content to be uploaded.
  # @options options [String] :type, the type of URN to use (person or organization).
  # @options options [String] :urn, the URN of the entity uploading.
  # @options options [Numeric] :timeout, optional timeout value in seconds, defaults to 300.
  # @options options [String] :disposition_filename, the name of the file to be uploaded. Defaults to the basename of the URL filename.
  # @return [LinkedIn::Mash]
  #
  def upload(options = {})
    source_url = options.delete(:source_url)
    timeout = options.delete(:timeout) || DEFAULT_TIMEOUT_SECONDS
    type = options.delete(:type)
    urn = options.delete(:urn)

    responseHash = register_upload(type: type, urn: urn)
    media_upload_endpoint = responseHash.dig("value", "upload_mechanism", "com.linkedin.digitalmedia.uploading.media_upload_http_request", "upload_url")
    asset_urn = responseHash.dig("value", "asset")

    response =
      @connection.put(media_upload_endpoint, file: file(source_url, options)) do |req|
        req.headers['Accept'] = 'application/json'
        req.options.timeout = timeout
        req.options.open_timeout = timeout
      end
    if response.status == 201
      asset_urn
    else
      raise InvalidRequest.new(response.message)
    end
  end

    # Registers a media upload with LinkedIn providing the upload URL and asset ID.
    #
    # @see https://docs.microsoft.com/en-us/linkedin/marketing/integrations/community-management/shares/vector-asset-api?tabs=http
    #
    # @options options [String] :type, the type of URN to use (person or organization).
    # @options options [String] :urn, the URN of the entity uploading.
    #
    def register_upload(options = {})
      register_upload_endpoint = '/assets?action=registerUpload'
      type = options.delete(:type)
      urn = options.delete(:urn)

      registerRequest = {
          registerUploadRequest: {
            owner: "urn:li:#{type}:#{urn}",
            recipes: [
                "urn:li:digitalmediaRecipe:feedshare-image"
            ],
            serviceRelationships: [
                {
                  identifier: "urn:li:userGeneratedContent",
                  relationshipType: "OWNER"
                }
            ],
            supportedUploadMechanism: [
                "SYNCHRONOUS_UPLOAD"
            ]
          }
      }

      registerUploadResponse = post(register_upload_endpoint, MultiJson.dump(registerRequest))
      Mash.from_json(registerUploadResponse.body)
    end

    def upload_filename(media)
      File.basename(media.base_uri.request_uri)
    end

    def extension(media)
      upload_filename(media).split('.').last
    end

    def content_type(media)
      ::MIME::Types.type_for(extension(media)).first.content_type
    end

    def file(source_url, options)
      media = open(source_url, 'rb')
      io = StringIO.new(media.read)
      filename = options.delete(:disposition_filename) || upload_filename(media)
      Faraday::UploadIO.new(io, content_type(media), filename)
    end
  end
end
