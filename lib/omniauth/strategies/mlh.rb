require 'omniauth-oauth2'
require 'ostruct'

module OmniAuth
  module Strategies
    class MLH < OmniAuth::Strategies::OAuth2
      option :name, :mlh

      option :client_options, {
        :site            => 'https://my.mlh.io',
        :authorize_url   => 'oauth/authorize',
        :token_url       => 'oauth/token'
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
        @data ||= access_token.get('/api/v3/user.json').parsed.deep_symbolize_keys[:data] rescue {}
      end
    end
  end
end

OmniAuth.config.add_camelization 'mlh', 'MLH'
OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true
