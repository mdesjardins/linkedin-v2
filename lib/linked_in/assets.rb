require 'mime/types'
require 'open-uri'

module LinkedIn
  DEFAULT_TIMEOUT_SECONDS = 300
  DEFAULT_POLL_SLEEP_SECONDS = 10

  CONTENT_TYPE = "application/json"
  UPLOAD_MECHANISM = "com.linkedin.digitalmedia.uploading.MediaUploadHttpRequest"

  # Assets APIs
  #
  # @see https://docs.microsoft.com/en-us/linkedin/marketing/integrations/community-management/shares/vector-asset-api
  #
  # [(contribute here)](https://github.com/mdesjardins/linkedin-v2)
  class Assets < APIResource
    class UploadFailed < StandardError; end
    class UploadTimeout < UploadFailed; end
    class UploadIncomplete < UploadFailed; end
    class UploadClientError < UploadFailed; end

    # Upload images and videos to LinkedIn from a supplied URL.
    #
    # @see https://docs.microsoft.com/en-us/linkedin/marketing/integrations/community-management/shares/vector-asset-api#upload-the-image
    #
    # @options options [String] :owner, the owner entity id.
    # @options options [String] :source_url, the URL to the content to be uploaded.
    # @options options [Numeric] :timeout, optional timeout value in seconds, defaults to 300.
    # @options options [Numeric] :poll_sleep_seconds, optional poll sleep value in seconds, defaults to 10.
    # @return [String], the asset entity
    #
    def upload(options = {})
      asset_entity, upload_url = register_upload(options)

      source_url = options.delete(:source_url)
      timeout = options.delete(:timeout) || DEFAULT_TIMEOUT_SECONDS
      poll_sleep_seconds = options.delete(:poll_sleep_seconds) || DEFAULT_POLL_SLEEP_SECONDS

      media_upload_endpoint = upload_url

      media = open(source_url, 'rb')
      content_type = content_type(media)

      upload_resp = @connection.put(media_upload_endpoint) do |req|
        req.headers['Content-Type'] = content_type
        req.headers['Content-Length'] = media.size.to_s
        req.body = Faraday::UploadIO.new(media, content_type)
        req.options.timeout = timeout
        req.options.open_timeout = timeout
      end

      raise UploadFailed unless upload_resp.success?

      poll_for_completion(asset_entity: asset_entity, poll_sleep_seconds: poll_sleep_seconds)

      asset_entity
    end

    def upload_status(asset_entity:)
      asset_id = asset_entity.split(":").last
      upload_status_endpoint = LinkedIn.config.api + LinkedIn.config.api_version + "/assets/#{asset_id}"
      Mash.from_json(@connection.get(upload_status_endpoint).body)
    end

    private

    def upload_filename(media)
      File.basename(media.base_uri.request_uri)
    end

    def extension(media)
      upload_filename(media).split('.').last
    end

    def content_type(media)
      ::MIME::Types.type_for(extension(media)).first&.content_type || get_content_type_from_file(media)
    end

    def get_content_type_from_file(media)
      `file --brief --mime-type - < #{Shellwords.shellescape(media.path)}`.strip
    end

    def register_upload(options = {})
      owner = options.delete(:owner)
      register_upload_endpoint = LinkedIn.config.api_version + '/assets?action=registerUpload'

      register_upload_body = {
        registerUploadRequest: {
          owner: owner,
          recipes: [ "urn:li:digitalmediaRecipe:feedshare-image" ],
          serviceRelationships: [
              {
                identifier: "urn:li:userGeneratedContent",
                relationshipType: "OWNER"
              }
          ]
        }
      }.to_json

      response = @connection.post(register_upload_endpoint, register_upload_body) do |req|
        req.headers["Content-Type"] = CONTENT_TYPE
        req.headers["Accept"] = CONTENT_TYPE
      end

      resp = Mash.from_json(response.body)
      asset_entity = resp.value.asset
      upload_url = resp.value.uploadMechanism[UPLOAD_MECHANISM].upload_url

      [asset_entity, upload_url]
    end

    def poll_for_completion(asset_entity:, poll_sleep_seconds:)
      sleep poll_sleep_seconds

      Timeout.timeout(DEFAULT_TIMEOUT_SECONDS, UploadTimeout) do
        loop do
          upload_status = upload_status(asset_entity: asset_entity).recipes[0].status

          case upload_status
          when "WAITING_UPLOAD"
            sleep poll_sleep_seconds
          when "PROCESSING"
            sleep poll_sleep_seconds
          when "INCOMPLETE"
            raise UploadIncomplete
          when "CLIENT_ERROR"
            raise UploadClientError
          when "AVAILABLE"
            break
          end
        end
      end
    end
  end
end
