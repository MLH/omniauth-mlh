# frozen_string_literal: true

require 'omniauth-oauth2'
require 'ostruct'

module OmniAuth
  module Strategies
    # MLH OAuth2 Strategy
    #
    # @example Basic Usage
    #   use OmniAuth::Builder do
    #     provider :mlh, ENV['MLH_KEY'], ENV['MLH_SECRET']
    #   end
    #
    # @example With Expandable Fields
    #   use OmniAuth::Builder do
    #     provider :mlh, ENV['MLH_KEY'], ENV['MLH_SECRET'],
    #              expand_fields: ['education', 'professional_experience']
    #   end
    #
    # @example With Refresh Tokens (offline access)
    #   use OmniAuth::Builder do
    #     provider :mlh, ENV['MLH_KEY'], ENV['MLH_SECRET'],
    #              scope: 'user:read:profile offline_access'
    #   end
    #
    # When offline_access scope is requested, the strategy will include
    # refresh_token in the credentials hash if provided by the server.
    class MLH < OmniAuth::Strategies::OAuth2 # :nodoc:
      option :name, :mlh

      option :client_options, {
        site: 'https://my.mlh.io',
        authorize_url: 'oauth/authorize',
        token_url: 'oauth/token',
        auth_scheme: :request_body  # Change from basic auth to request body
      }

      # Support expandable fields through options
      option :expand_fields, []

      uid { data[:id] }

      info do
        prune_hash(data.slice(
          :email,          # from user:read:email
          :first_name,     # from user:read:profile
          :last_name,      # from user:read:profile
          :demographics,   # from user:read:demographics
          :education,      # from user:read:education
          :phone_number,   # from user:read:phone
          :address,        # from user:read:address
          :birthday,       # from user:read:birthday
          :employment,     # from user:read:employment
          :event_preferences, # from user:read:event_preferences
          :social_profiles   # from user:read:social_profiles
        ))
      end

      def data
        @data ||= begin
          # Support expandable fields through options
          expand_query = options[:expand_fields].map { |f| "expand[]=#{f}" }.join('&')
          url = "https://api.mlh.com/v4/users/me"
          url += "?#{expand_query}" unless options[:expand_fields].empty?

          access_token.get(url).parsed.deep_symbolize_keys[:data]
        rescue StandardError
          {}
        end
      end

      private

      def prune_hash(hash)
        hash.reject { |_, v| v.nil? }
      end
    end
  end
end

OmniAuth.config.add_camelization 'mlh', 'MLH'
OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true
