require 'digest'
require 'cgi'

################################################################################
# A simple tool to generate recordit URIs
#
# Usage:
#
# require 'recordit/url_builder'
#
# url_builder = Recordit::URLBuilder.new(
#   "f33dd06d1cd1fb6e94504c767e5ccd9d0f7cd039",     # your client ID
#   "6d85ffe45dbc37f6e47bc443f6079dc26f61b3df"      # your secret
# )
#
# url_builder.generate({
#     fps: 12,
#     encode: :none,
#     action_url: "http://example.com/123",
#     callback: "http://example.com/api/123",
#     start_message: "This is the initial message",
#     end_message: "This is the end message",
#     width: 1280,
#     height: 720
# })
#
# # => recordit:f33dd06d1cd1fb6e94504c767e5ccd9d0f7cd039-565fcfbfe0c2e0c59be5
# 9df7b3b73d42f564e6cc?fps=12&encode=none&action_url=http%3A%2F%2Fexample.com%
# 2F123&callback=http%3A%2F%2Fexample.com%2Fapi%2F123&start_message=This%20is%
# 20the%20initial%20message&end_message=This%20is%20the%20end%20message&width=
# 1280&height=720
################################################################################
module Recordit

  PROTOCOL = "recordit"

  class URLBuilder

    # Initialize the builder with the client ID and secret.
    def initialize(client_id, secret)
      @client_id = client_id
      @secret = secret
      @hasher = Digest::SHA1.new
    end

    # Main API entry point, receives a hash containing the parameters
    # to encode in the URL, returns actual URL.
    def generate(params_hash)
      query_string = queryfy(params_hash)
      authenticity_token = sign_request(query_string)

      "#{PROTOCOL}:#{@client_id}-#{authenticity_token}#{query_string}"
    end

    protected

    # Hashes the query string
    def sign_request(query_string)
      @hasher.hexdigest(@secret + query_string)
    end

    # Given the params hash, converts it to a url encoded query string.
    def queryfy(params_hash)
      query_array = params_hash.map do |key, value|
        "#{escape(key)}=#{escape(value)}"
      end
      "?#{query_array.join("&")}"
    end

    # Escapes the url, and converts CGI's + to a proper percent encoded string
    def escape(param)
      CGI.escape(param.to_s).gsub("+", "%20")
    end
  end
end
