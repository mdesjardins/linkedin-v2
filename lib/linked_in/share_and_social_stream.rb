module LinkedIn
  # Share and Social Stream APIs
  #
  # @see https://developer.linkedin.com/docs/guide/v2/shares
  # @see https://developer.linkedin.com/docs/guide/v2/shares/share-api
  # @see https://developer.linkedin.com/docs/guide/v2/shares/network-update-social-actions
  #
  # LinkedIn's v2 API adherence to the documentation is shaky at best. Several of
  # the calls simply don't work if you, e.g., pass the URN in as a path element
  # for a resource - you have to use the ids=[URN] format w/ a single URN. Or
  # sometimes passing in an "actor" parameter in the request body simply doesn't
  # work, and you have to pass it in as a URL parameter. What you see in this
  # file is the result of trial-and-error getting these endpoints to work, and the
  # inconsistency is usually a result of either misunderstanding the docs or the
  # API not working as advertised. It's also a bit unclear when the API wants
  # an activity URN vs, e.g., an article URN. Caveat emptor.
  #
  # [(contribute here)](https://github.com/mdesjardins/linkedin-v2)
  class ShareAndSocialStream < APIResource

    # Retrieve shares from a person, organization, or organizationBrand.
    #
    # Permissions:
    #   1.) For personal shares, you may only retrieve shares for the authorized members.
    #   2.) For organization shares, you may only retrieve shares for organizations for which the
    #       authorized member is an administrator.
    #
    # @see https://developer.linkedin.com/docs/guide/v2/shares/share-api#retrieve
    #
    # @options options [String] :owner, the URN for whom we are fetching shares.
    # @return [LinkedIn::Mash]
    #
    def shares(options = {})
      urn = options.delete(:urn)
      path = "/shares?q=owners&owners=#{urn}"
      get(path, options)
    end

    # Retrieve Share by ID
    #
    # https://docs.microsoft.com/en-us/linkedin/marketing/integrations/community-management/shares/share-api#look-up-share-by-id
    #
    def get_share(options = {})
      id = options.delete(:id)
      path = "/shares/#{id}"
      get(path, options)
    end

    # Create one share from a person, organization, or organizationBrand.
    #
    # Permissions:
    #  1.) For personal shares, you may only post shares as the authorized member.
    #  2.) For organization shares, you may only post shares as an organization for which the
    #      authorized member is an administrator.
    #
    # @see https://developer.linkedin.com/docs/guide/v2/shares/share-api#post
    #
    # @option options [String] :owner, the URN of the entity posting the share.
    # @return [LinkedIn::Mash]
    #
    def share(options = {})
      path = '/shares'
      defaults = {
        distribution: {
          linkedInDistributionTarget: {
            visibleToGuest: true
          }
        }
      }
      post(path, MultiJson.dump(defaults.merge(options)), 'Content-Type' => 'application/json')
    end

    # Retrieve a Summary of Social Actions
    #
    # https://docs.microsoft.com/en-us/linkedin/marketing/integrations/community-management/shares/network-update-social-actions#retrieve-a-summary-of-social-actions
    #
    def get_social_actions share_urns
      path = '/socialActions'
      get(path, ids: share_urns)
    end

    # Retrieves the likes for a specific post.
    #
    # @see https://developer.linkedin.com/docs/guide/v2/shares/network-update-social-actions#retrieve
    #
    # @option options [String] :urn, the URN of the relevant share, UGC post, or comment
    # @return [LinkedIn::Mash]
    #
    def likes(options = {})
      urn = options.delete(:urn)
      path = "/socialActions/#{urn}/likes"
      get(path, options)
    end

    # Likes a specific share or comment.
    #
    # @see https://developer.linkedin.com/docs/guide/v2/shares/network-update-social-actions#retrieve.
    # @option options [String] :object, specifies the URN of the entity to which the like belongs.
    # This object should be a sub-entity of the top-level share indicated in the request URL, and
    # should be represented as an URN either of format urn:li:share:{id}
    # @option options [String] :urn, specifies activity being un-liked (e.g., urn:li:activity::123)
    # @option options [String] :actor, specifies the entity performing the action. It should be
    # represented by a urn:li:person:{id} or urn:li:organization:{id} URN.
    #
    def like(options = {})
      urn = options.delete(:urn)
      path = "/socialActions/#{urn}/likes"
      post(path, MultiJson.dump(options), 'Content-Type' => 'application/json')
    end

    # Un-likes a previously liked share or comment.
    #
    # @see https://developer.linkedin.com/docs/guide/v2/shares/network-update-social-actions#retrieve.
    # @option options [String] :urn, specifies activity being un-liked (e.g., urn:li:activity:123)
    # @option options [String] :actor, specifies the entity performing the action. It should b    # represented by a urn:li:person:{id} or urn:li:organization:{id} URN.
    #
    def unlike(options = {})
      urn = options.delete(:urn)
      actor = options.delete(:actor)
      path = "/socialActions/#{urn}/likes/#{actor}?actor=#{CGI::escape(actor)}"
      delete(path, MultiJson.dump(options), 'Content-Type' => 'application/json') #options)
    end

    # Retrieves the comments for a specific post.
    #
    # @see https://developer.linkedin.com/docs/guide/v2/shares/network-update-social-actions#retrieve
    # @option options [String] :urn, specifies activity queried for comments (e.g.,
    # urn:li:article:123)
    #
    def comments(options = {})
      urn = options.delete(:urn)
      path = "/socialActions/#{urn}/comments"
      get(path, options)
    end

    # Adds a comment to a specific post.
    #
    # Permissions:
    #
    # @see https://developer.linkedin.com/docs/guide/v2/shares/network-update-social-actions#retrieve
    #
    # @option options [String] :urn, specifies activity queried for comments (e.g.,
    # urn:li:article:123)
    # @option options [String] :parent_comment, specifies the urn of the parent comment
    # @option options [String] :actor, specifies the entity performing the action. It should b    # represented by a urn:li:person:{id} or urn:li:organization:{id} URN.
    # @option options [String] :message, the text content of the comment.
    #
    def comment(options = {})
      urn = options.delete(:urn)
      actor = options.delete(:actor)
      message = options.delete(:message)
      parent_comment = options.delete(:parent_comment)

      body = {
        actor: actor,
        message: { text: message }
      }
      body.merge!(parentComment: parent_comment) if parent_comment

      path = "/socialActions/#{urn}/comments"
      post(path, MultiJson.dump(body), 'Content-Type' => 'application/json')
    end

    # Migrate from Update Keys to Share URNs
    #
    # https://docs.microsoft.com/en-us/linkedin/marketing/integrations/community-management/shares/share-api#migrate-from-update-keys-to-share-urns
    #
    def migrate_update_keys update_keys
      path = '/activities'
      get(path, ids: update_keys)
    end
  end
end
