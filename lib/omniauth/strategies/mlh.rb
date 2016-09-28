require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class MLH < OmniAuth::Strategies::OAuth2
      option :name, :mlh

      option :client_options, {
        :site => 'https://my.mlh.io',
        :authorize_path  => '/oauth/authorize',
        :token_path => '/oauth/token'
      }

      uid { raw_info['data']['id'] }

      info do
        {
          :email                => raw_info['data']['email'],
          :created_at           => raw_info['data']['created_at'],
          :updated_at           => raw_info['data']['updated_at'],
          :first_name           => raw_info['data']['first_name'],
          :last_name            => raw_info['data']['last_name'],
          :level_of_study       => raw_info['data']['level_of_study'],
          :major                => raw_info['data']['major'],
          :shirt_size           => raw_info['data']['shirt_size'],
          :dietary_restrictions => raw_info['data']['dietary_restrictions'],
          :special_needs        => raw_info['data']['special_needs'],
          :date_of_birth        => raw_info['data']['date_of_birth'],
          :gender               => raw_info['data']['gender'],
          :phone_number         => raw_info['data']['phone_number'],
          :scopes               => raw_info['data']['scopes'],
          :school               => {
                                  :id =>   raw_info['data']['school']['id'],
                                  :name => raw_info['data']['school']['name'],
                                }
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/api/v2/user.json').parsed
      end
    end
  end
end

OmniAuth.config.add_camelization 'mlh', 'MLH'
