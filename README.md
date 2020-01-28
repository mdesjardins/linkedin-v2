# LinkedIn v2

## WARNING: DANGER WILL ROBINSON

This is very much a work in progress. Currently only the shares/social stream,
organization, and assets upload related endpoints have been verified to work.
Having said that, those endpoints are using this gem in a production application,
so they're reliable enough. :)

Many endpoints still need to be written, and as I don't have the requisite partner
status w/ LinkedIn, I can't develop against the jobs API. Many of the specs still
fail. _Caveat emptor_

## NOW BACK TO YOUR REGULARLY SCHEDULED PROGRAMMING

Ruby wrapper for v2 if the [LinkedIn API](http://developer.linkedin.com). This gem is entirely
based on emorikawa's excellent [linkedin-oauth2](https://github.com/emorikawa/linkedin-oauth2)
gem.

If you are using OAuth 1.0, see [hexgnu/linkedin](https://github.com/hexgnu/linkedin)
If you are using OAuth 2.0 and the v1 LinkedIn API, see [emorikawa/linkedin-oauth2](https://github.com/emorikawa/linkedin-oauth2), on which this gem is based.

# Installation

In Bundler:

```ruby
gem "linkedin-v2", "~> 0.1.0"
```

Otherwise:

    [sudo|rvm] gem install linkedin-v2

# Usage

**[Step 1:](#step-1-register-your-application)** [Register](https://www.linkedin.com/secure/developer) your
application with LinkedIn. They will give you a **Client ID** (aka API
Key) and a **Client Secret** (aka Secret Key)

**[Step 2:](#step-2-getting-an-access-token)** Use your **Client ID** and **Client Secret** to obtain an **Access Token** from some user.

**[Step 3:](#step-3-using-linkedins-api)** Use an **Access Token** to query the API.

```ruby
api = LinkedIn::API.new(access_token)
me = api.profile
```

## Step 1: Register your Application

You first need to create and register an application with LinkedIn
[here](https://www.linkedin.com/secure/developer).

You will not be able to use any part of the API without registering first.

Once you have registered you will need to take note of a few key items on
your Application Details page.

1. **API Key** - We refer to this as your client id or `client_id`
1. **Secret Key** - We refer to this as your client secret or
   `client_secret`
1. **Default Scope** - This is the set of permissions you request from
   users when they connect to your app. If you want to set this on a
   request-by-request basis, you can use the `scope` option with the
   `auth_code_url` method.
1. **OAuth 2.0 Redirect URLs** - For security reasons, the url you enter
   in this box must exactly match the `redirect_uri` you use in this gem.

You do NOT need **OAuth User Token** nor **OAuth User Secret**. That is
for OAuth 1.0. This gem is for OAuth 2.0.

## Step 2: Getting An Access Token

All LinkedIn API requests must be made in the context of an access token.
The access token encodes what LinkedIn information your AwesomeApp® can
gather on behalf of "John Doe".

There are a few different ways to get an access token from a user.

1. You can use [LinkedIn's Javascript API](https://developer.linkedin.com/documents/javascript-api-reference-0) to authenticate on the front-end and then pass the access token to the backend via [this procedure](https://developer.linkedin.com/documents/exchange-jsapi-tokens-rest-api-oauth-tokens).

1. If you use OmniAuth, I would recommend looking at [decioferreira/omniauth-linkedin-oauth2](https://github.com/decioferreira/omniauth-linkedin-oauth2) to help automate authentication.

1. You can do it manually using this linkedin-oauth2 gem and the steps
   below.

Here is how to get an access token using this linkedin-oauth2 gem:

### Step 2A: Configuration

You will need to configure the following items:

1. Your **client id** (aka API Key)
1. Your **client secret** (aka Secret Key)
1. Your **redirect uri**. On LinkedIn's website you must input a list of
   valid redirect URIs. If you use the same one each time, you can set it
   in the `LinkedIn.configure` block. If your redirect uris change
   depending on business logic, you can pass it into the `auth_code_url`
   method.

```ruby
# It's best practice to keep secret credentials out of source code.
# You can, of course, hardcode dev keys or directly pass them in as the
# first two arguments of LinkedIn::OAuth2.new
LinkedIn.configure do |config|
  config.client_id     = ENV["LINKEDIN_CLIENT_ID"]
  config.client_secret = ENV["LINKEDIN_CLIENT_SECRET"]

  # This must exactly match the redirect URI you set on your application's
  # settings page. If your redirect_uri is dynamic, pass it into
  # `auth_code_url` instead.
  config.redirect_uri  = "https://getawesomeapp.io/linkedin/oauth2"
end
```

### Step 2B: Get Auth Code URL

```ruby
oauth = LinkedIn::OAuth2.new

url = oauth.auth_code_url
```

### Step 2C: User Sign In

You must now load url from Step 2B in a browser. It will pull up the
LinkedIn sign in box. Once LinkedIn user credentials are entered, the box
will close and redirect to your redirect url, passing along with it the
**OAuth code** as the `code` GET param.

Be sure to read the extended documentation around the LinkedIn::OAuth2
module for more options you can set.

**Note:** The **OAuth code** only lasts for ~20 seconds!

### Step 2D: Get Access Token

```ruby
code = "THE_OAUTH_CODE_LINKEDIN_GAVE_ME"

access_token = oauth.get_access_token(code)
```

Now that you have an access token, you can use it to query the API.

The `LinkedIn::OAuth2` inherits from [intreda/oauth2](https://github.com/intridea/oauth2)'s `OAuth2::Client` class. See that gem's [documentation](https://github.com/intridea/oauth2/blob/master/lib/oauth2/client.rb) for more usage examples.

## Step 3: Using LinkedIn's API

Once you have an access token, you can query LinkedIn's API.

Your access token encodes the permissions you're allowed to have. See Step
2 and [this LinkedIn document](https://developer.linkedin.com/documents/authentication#granting) for how to change the permissions. See each section's documentation on LinkedIn for more information on what permissions get you access to.

### People

## TBD

### Organizations

Detailed overviews of Organizations

See https://developer.linkedin.com/docs/guide/v2/organizations

```ruby
# Organization info
api.organization(name: "google")
api.organization(id: 12345)
api.organization(urn: 'urn:li:organization:12345')
```

### Jobs

## DON'T HAVE ACCESS. :(

````

### Share and Social Stream

View and update content on social streams

See https://developer.linkedin.com/docs/guide/v2/shares

```ruby
# Your news feed
api.shares

api.share(content: "hi")

# For a particular feed item
api.comments(urn: "urn:li:article:12345")
api.likes(urn: "urn:li:article:12345")

api.like(urn: "urn:li:activity:12345")
api.unlike(urn: "urn:li:activity:12345")
````

### Communications

## TBD

# Documentation

On [RubyDoc here](http://rubydoc.info/github/mdesjardins/linkedin-v2/frames/file/README.md)

Read the source for [LinkedIn::API](https://github.com/mdesjardins/linkedin-v2/blob/master/lib/linked_in/api.rb) and [LinkedIn::OAuth2](https://github.com/mdesjardins/linkedin-v2/blob/master/lib/linked_in/oauth2.rb)

# Contributing

Please see [CONTRIBUTING.md](https://github.com/mdesjardins/linkedin-v2/blob/master/CONTRIBUTING.md) for details.

# Credits

Huge, huge props to Evan Morikawa for writing the v1 version of this gem. This gem is
pretty much all of that work, but gutted and replaced with v2 endpoints.

- [Evan Morikawa](https://twitter.com/eom) ([emorikawa](https://github.com/emorikawa))
- [Matt Kirk](http://matthewkirk.com) ([hexgnu](https://github.com/hexgnu))
- [Wynn Netherland](http://wynnetherland.com) ([pengwynn](https://github.com/pengwynn))
- Josh Kalderimis ([joshk](https://github.com/joshk))
- Erik Michaels-Ober ([sferik](https://github.com/sferik))
- And Many More [Contributors](https://github.com/emorikawa/linkedin-oauth2/graphs/contributors)

# License

Copyright :copyright: 2018-present [Mike Desjardins](https://twitter.com/mdesjardins) 2014-2018 [Evan Morikawa](https://twitter.com/e0m) 2013-2014 [Matt Kirk](http://matthewkirk.com/) 2009-11 [Wynn Netherland](http://wynnnetherland.com/) and [contributors](https://github.com/emorikawa/linkedin-oauth2/graphs/contributors). It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file. See [LICENSE](https://github.com/emorikawa/linkedin-oauth2/blob/master/LICENSE) for details.
