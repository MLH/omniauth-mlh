# frozen_string_literal: true

require 'omniauth-oauth2'
require 'ostruct'
require 'active_support/core_ext/hash'

module OmniAuth
  module Strategies
    class MLH < OmniAuth::Strategies::OAuth2 # :nodoc:
      option :name, :mlh

      option :client_options, {
        site: 'https://my.mlh.io',
        authorize_url: 'oauth/authorize',
        token_url: 'oauth/token',
        api_site: 'https://api.mlh.com'
      }

      option :authorize_params, {
        scope: 'public user:read:profile'
      }

      uid { data[:id] }

      info do
        {
          email: raw_info.dig(:user, :email),
          first_name: raw_info.dig(:user, :first_name),
          last_name: raw_info.dig(:user, :last_name),
          created_at: raw_info.dig(:user, :created_at),
          updated_at: raw_info.dig(:user, :updated_at),
          demographics: raw_info.dig(:user, :demographics),
          education: raw_info.dig(:user, :education),
          employment: raw_info.dig(:user, :employment),
          event_preferences: raw_info.dig(:user, :event_preferences),
          address: raw_info.dig(:user, :address),
          phone_number: raw_info.dig(:user, :phone_number),
          social_profiles: raw_info.dig(:user, :social_profiles)
        }
      end

      def raw_info
        @raw_info ||= begin
          response = access_token.get("#{options.client_options.api_site}/v4/users/#{uid}").parsed
          normalize_response(response)
        rescue StandardError
          {}
        end
      end

      private

      def normalize_response(response)
        return {} unless response.is_a?(Hash)

        response.key?('user') ? response.deep_symbolize_keys : { user: response }.deep_symbolize_keys
      end

      def data
        @data ||= begin
          response = access_token.get('/api/v4/me').parsed
          extract_user_data(response)
        rescue StandardError
          {}
        end
      end

      def authorize_params
        super.tap do |params|
          merge_default_scopes(params) unless skip_default_scopes?
        end
      end

      def extract_user_data(response)
        return {} unless response.is_a?(Hash)

        user_data = response['user'] || response
        user_data.deep_symbolize_keys
      end

      def skip_default_scopes?
        options[:authorize_options]&.include?('scope')
      end

      def merge_default_scopes(params)
        scope = params['scope'] || params[:scope]
        params[:scope] = build_scope_string(scope)
      end

      def build_scope_string(scope)
        default_scopes = 'public user:read:profile'
        return default_scopes if scope.nil? || scope.empty?
        return scope if scope.include?(default_scopes)

        "#{scope} #{default_scopes}"
      end
    end
  end
end

OmniAuth.config.add_camelization 'mlh', 'MLH'
OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true
