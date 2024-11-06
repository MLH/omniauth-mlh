# frozen_string_literal: true

require 'omniauth-oauth2'
require 'ostruct'

module OmniAuth
  module Strategies
    class MLH < OmniAuth::Strategies::OAuth2
      option :name, :mlh

      option :client_options, {
        site: 'https://my.mlh.io',
        authorize_url: 'oauth/authorize',
        token_url: 'oauth/token'
      }

      # Default scope includes user:read:profile and offline_access for refresh tokens
      option :scope, 'user:read:profile offline_access'

      # Support for expandable fields in the API
      option :fields, []

      uid { raw_info['id'] }

      info do
        prune!({
          'email' => raw_info.dig('email'),
          'first_name' => raw_info.dig('first_name'),
          'last_name' => raw_info.dig('last_name'),
          'created_at' => raw_info.dig('created_at'),
          'updated_at' => raw_info.dig('updated_at'),
          'roles' => raw_info.dig('roles'),
          'phone_number' => raw_info.dig('phone_number'),
          'demographics' => {
            'gender' => raw_info.dig('demographics', 'gender'),
            'date_of_birth' => raw_info.dig('demographics', 'date_of_birth')
          },
          'education' => {
            'level' => raw_info.dig('education', 'level'),
            'major' => raw_info.dig('education', 'major'),
            'school' => raw_info.dig('education', 'school')
          },
          'employment' => {
            'type' => raw_info.dig('employment', 'type'),
            'company' => raw_info.dig('employment', 'company'),
            'title' => raw_info.dig('employment', 'title')
          }
        })
      end

      credentials do
        hash = { 'token' => access_token.token }
        hash['refresh_token'] = access_token.refresh_token if access_token.refresh_token
        hash['expires_at'] = access_token.expires_at if access_token.expires_at
        hash['expires'] = access_token.expires?
        hash
      end

      def raw_info
        @raw_info ||= begin
          path = '/v4/users/me'
          path += "?fields=#{options.fields.join(',')}" if options.fields.any?

          response = access_token.get(path)
          raise OmniAuth::Error.new(response.error) unless response.success?

          response.parsed
        rescue StandardError => e
          raise OmniAuth::Error.new("Failed to get user info: #{e.message}")
        end
      end

      private

      def prune!(hash)
        hash.delete_if do |_, value|
          prune!(value) if value.is_a?(Hash)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end
    end
  end
end

OmniAuth.config.add_camelization 'mlh', 'MLH'
OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true
