# frozen_string_literal: true

# This is an executable file allowing a user to use the command line interface
# to pass in a callback host url and a subscription key
# and get back a generated user id and API key

require 'faraday'
require 'json'
require 'securerandom'

require 'momoapi-ruby/config'
require 'momoapi-ruby/errors'
require 'momoapi-ruby'

module Momoapi
  class CLI
    def initialize(option)
      @uuid = SecureRandom.uuid
      @host = option[:host]
      @key = option[:key]
      create_sandbox_user
    end

    # Create an API user in the sandbox target environment
    def create_sandbox_user
      body = { "providerCallbackHost": @host }
      @url = 'https://ericssonbasicapi2.azure-api.net/v1_0/apiuser'
      response = Faraday.post(@url) do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['X-Reference-Id'] = @uuid
        req.headers['Ocp-Apim-Subscription-Key'] = @key
        req.body = body.to_json
      end

      unless response.status == 201
        raise Momoapi::Error.new(response.body, response.status)
      end

      generate_api_key
    end

    # Generate an API key in the sandbox target environment
    def generate_api_key
      @url = 'https://ericssonbasicapi2.azure-api.net/v1_0/apiuser/' +
             @uuid + '/apikey'
      response = Faraday.post(@url) do |req|
        req.headers['Ocp-Apim-Subscription-Key'] = @key
      end

      unless response.status == 201
        raise Momoapi::Error.new(response.body, response.status)
      end

      key = JSON.parse(response.body)
      puts "\n User ID: #{@uuid} \n API key: #{key['apiKey']} \n\n"
    end
  end
end
