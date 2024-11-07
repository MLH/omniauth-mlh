# frozen_string_literal: true

require 'omniauth-oauth2'
require 'ostruct'

module OmniAuth
  module Strategies
    class MLH < OmniAuth::Strategies::OAuth2 # :nodoc:
      option :name, :mlh

      option :client_options, {
        site: 'https://api.mlh.com/v4',
        authorize_url: 'https://my.mlh.io/oauth/authorize',
        token_url: 'https://api.mlh.com/v4/oauth/token',
        api_site: 'https://api.mlh.com' # New API endpoint
      }

      option :authorize_options, [:scope]
      option :authorize_params, {
        scope: 'public user:read:profile user:read:email' # Default scopes for v4
      }

      option :auth_token_params, {
        auth_scheme: :basic_auth # Most OAuth2 providers prefer basic auth for token exchange
      }

      uid { data[:id] }

      info do
        data.slice(
          :email,
          :created_at,
          :updated_at,
          :first_name,
          :last_name,
          :level_of_study,
          :major,
          :date_of_birth,
          :gender,
          :phone_number,
          :profession_type,
          :company_name,
          :company_title,
          :scopes,
          :school
        )
      end

      def data
        @data ||= begin
          api_site = options.client_options[:api_site]
          response = access_token.get("#{api_site}/v4/users/me").parsed
          response.deep_symbolize_keys[:data]
        rescue StandardError
          {}
        end
      end
    end
  end
end

OmniAuth.config.add_camelization 'mlh', 'MLH'
OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true
