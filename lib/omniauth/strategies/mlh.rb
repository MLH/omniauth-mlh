# frozen_string_literal: true

require 'omniauth-oauth2'
require 'ostruct'

module OmniAuth
  module Strategies
    class MLH < OmniAuth::Strategies::OAuth2 # :nodoc:
      option :name, :mlh

      option :client_options, {
        site: 'https://my.mlh.io',
        authorize_url: 'oauth/authorize',
        token_url: 'https://api.mlh.com/v4/oauth/token'
      }

      option :auth_token_params, {
        mode: :body
      }

      option :fields, [] # Allow configurable field expansion

      uid { raw_info['id'] }

      info do
        {
          id: raw_info['id'],
          email: raw_info['email'],
          first_name: raw_info['first_name'],
          last_name: raw_info['last_name'],
          created_at: raw_info['created_at'],
          updated_at: raw_info['updated_at'],
          roles: raw_info['roles'],
          phone_number: raw_info['phone_number']
        }
      end

      extra do
        {
          'raw_info' => raw_info,
          'profile' => raw_info['profile'],
          'address' => raw_info['address'],
          'social_profiles' => raw_info['social_profiles'],
          'professional_experience' => raw_info['professional_experience'],
          'education' => raw_info['education'],
          'identifiers' => raw_info['identifiers']
        }
      end

      def raw_info
        @raw_info ||= begin
          access_token.get(
            "https://api.mlh.com/v4/users/me#{build_fields_param}",
            headers: { 'Authorization' => "Bearer #{access_token.token}" }
          ).parsed
        rescue StandardError
          {}
        end
      end

      private

      def build_fields_param
        return '' unless options.fields.any?

        fields = Array(options.fields).map { |field| "expand[]=#{field}" }
        "?#{fields.join('&')}"
      end
    end
  end
end

OmniAuth.config.add_camelization 'mlh', 'MLH'
OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true
