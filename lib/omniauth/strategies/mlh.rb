require 'omniauth-oauth2'
require 'ostruct'

module OmniAuth
  module Strategies
    class MLH < OmniAuth::Strategies::OAuth2
      option :name, :mlh

      option :client_options, {
        :site            => 'https://my.mlh.io',
        :authorize_path  => '/oauth/authorize',
        :token_path      => '/oauth/token'
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
          :shirt_size,
          :dietary_restrictions,
          :special_needs,
          :date_of_birth,
          :gender,
          :phone_number,
          :scopes,
          :school
        )
      end

      def data
        @data ||= access_token.get('/api/v2/user.json').parsed.deep_symbolize_keys[:data] rescue {}
      end
    end
  end
end

OmniAuth.config.add_camelization 'mlh', 'MLH'
