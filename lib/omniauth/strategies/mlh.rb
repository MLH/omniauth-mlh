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
        auth_scheme: :request_body # Change from basic auth to request body
      }

      # Support expandable fields through options
      option :expand_fields, []

      uid { data[:id] }

      info do
        {
          # Basic fields
          id: data[:id],
          created_at: data[:created_at],
          updated_at: data[:updated_at],
          first_name: data[:first_name],
          last_name: data[:last_name],
          email: data[:email],
          phone_number: data[:phone_number],
          roles: data[:roles],

          # Expandable fields
          profile: data[:profile],
          address: data[:address],
          social_profiles: data[:social_profiles],
          professional_experience: data[:professional_experience],
          education: data[:education],
          identifiers: data[:identifiers]
        }
      end

      def data
        @data ||= fetch_and_process_data.compact
      rescue StandardError
        {}
      end

      private

      def fetch_and_process_data
        response = access_token.get(build_api_url)
        data = JSON.parse(response.body, symbolize_names: true)
        return {} unless data.is_a?(Hash)

        symbolize_nested_arrays(data)
      end

      def build_api_url
        url = 'https://api.mlh.com/v4/users/me'
        expand_fields = options[:expand_fields] || []
        return url if expand_fields.empty?

        expand_query = expand_fields.map { |f| "expand[]=#{f}" }.join('&')
        "#{url}?#{expand_query}"
      end

      def symbolize_nested_arrays(hash)
        hash.transform_values do |value|
          case value
          when Hash
            symbolize_nested_arrays(value)
          when Array
            value.map { |item| item.is_a?(Hash) ? symbolize_nested_arrays(item) : item }
          else
            value
          end
        end
      end
    end
  end
end

OmniAuth.config.add_camelization 'mlh', 'MLH'
OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true
