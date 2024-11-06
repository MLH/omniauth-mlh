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
          puts "Raw response: #{response.inspect}"  # Debug output
          if response.is_a?(Hash)
            # Handle string keys in response
            if response.key?('user')
              result = response.deep_symbolize_keys
              puts "Response with user key: #{result.inspect}"  # Debug output
              result
            else
              result = { user: response }.deep_symbolize_keys
              puts "Response wrapped in user key: #{result.inspect}"  # Debug output
              result
            end
          else
            {}
          end
        rescue StandardError => e
          puts "Error in raw_info: #{e.message}"  # Debug output
          {}
        end
      end

      def data
        @data ||= begin
          # First request to get user ID
          response = access_token.get('/api/v4/me').parsed
          if response.is_a?(Hash)
            # Extract user ID from response
            response = response['user'] || response
            response.deep_symbolize_keys
          else
            {}
          end
        rescue StandardError
          {}
        end
      end

      def authorize_params
        super.tap do |params|
          # Only set default scopes if no scope is provided at all
          default_scopes = 'public user:read:profile'
          # Don't modify scope if it's coming from authorize_options
          unless options[:authorize_options]&.include?('scope')
            scope = params['scope'] || params[:scope]
            if scope.nil? || scope.empty?
              params[:scope] = default_scopes
            elsif !scope.include?(default_scopes)
              params[:scope] = "#{scope} #{default_scopes}"
            end
          end
        end
      end
    end
  end
end

OmniAuth.config.add_camelization 'mlh', 'MLH'
OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true
