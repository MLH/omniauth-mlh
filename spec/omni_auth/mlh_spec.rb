# frozen_string_literal: true

require 'spec_helper'
require 'oauth2'

describe OmniAuth::MLH do
  subject(:omniauth_mlh) do
    app = lambda { |_env| [200, {}, ['Hello']] }
    strategy = OmniAuth::Strategies::MLH.new(app, @options || {}) # rubocop:disable RSpec/InstanceVariable
    strategy.instance_variable_set(:@access_token, access_token) if defined?(access_token)
    strategy
  end

  it_behaves_like 'an oauth2 strategy'

  describe '#client' do
    it 'has correct MyMLH site' do
      expect(omniauth_mlh.client.site).to eq('https://api.mlh.com/v4')
    end

    it 'has correct authorize url' do
      expect(omniauth_mlh.client.options[:authorize_url]).to eq('https://my.mlh.io/oauth/authorize')
    end

    it 'has correct token url' do
      expect(omniauth_mlh.client.options[:token_url]).to eq('https://api.mlh.com/v4/oauth/token')
    end

    it 'has correct API site' do
      expect(omniauth_mlh.options.client_options[:api_site]).to eq('https://api.mlh.com')
    end

    it 'runs the setup block if passed one' do
      counter = ''
      @options = { setup: proc { |_env| counter = 'ok' } }
      omniauth_mlh.setup_phase
      expect(counter).to eq('ok')
    end
  end

  describe '#auth_token_params' do
    it 'has correct auth scheme' do
      expect(omniauth_mlh.options.auth_token_params[:auth_scheme]).to eq(:basic_auth)
    end
  end

  describe '#callback_phase' do
    let(:request) { double('Request', params: { 'code' => 'valid_code', 'state' => 'valid_state' }, scheme: 'https', url: 'https://example.com', script_name: '', path_info: '/auth/mlh/callback', env: { 'HTTPS' => 'on', 'rack.url_scheme' => 'https' }, query_string: 'code=valid_code&state=valid_state') }
    let(:client) { instance_double(OAuth2::Client) }
    let(:auth_code) { instance_double(OAuth2::Strategy::AuthCode) }
    let(:token) { instance_double(OAuth2::AccessToken) }

    before do
      allow(omniauth_mlh).to receive(:request).and_return(request)
      allow(omniauth_mlh).to receive(:client).and_return(client)
      allow(client).to receive(:auth_code).and_return(auth_code)
      allow(token).to receive(:token).and_return('valid_token')
      allow(token).to receive(:expires?).and_return(true)
      allow(token).to receive(:expired?).and_return(false)
      allow(token).to receive(:expires_at).and_return(1234567890)
      allow(token).to receive(:refresh_token).and_return('refresh_token')
      # Add API response mock
      api_response = {
        'data' => {
          'id' => '123',
          'email' => 'user@example.com',
          'first_name' => 'John',
          'last_name' => 'Doe',
          'school' => {
            'name' => 'Test University',
            'id' => '456'
          },
          'level_of_study' => 'Undergraduate',
          'major' => 'Computer Science',
          'date_of_birth' => '1990-01-01',
          'gender' => 'Prefer not to say',
          'phone_number' => '+1234567890',
          'profession_type' => 'Student',
          'company' => {
            'name' => 'Tech Corp',
            'title' => 'Intern'
          },
          'created_at' => '2024-01-01T00:00:00Z',
          'updated_at' => '2024-01-02T00:00:00Z'
        }
      }
      allow(token).to receive(:get)
        .with('https://api.mlh.com/v4/users/me')
        .and_return(instance_double(OAuth2::Response, parsed: api_response))
      # Add CSRF state validation setup
      allow(request).to receive(:params).and_return({
        'code' => 'valid_code',
        'state' => 'valid_state'
      })
      allow(omniauth_mlh).to receive(:session).and_return({ 'omniauth.state' => 'valid_state' })
    end

    context 'when token exchange is successful' do
      before do
        allow(auth_code).to receive(:get_token)
          .with('valid_code', hash_including(redirect_uri: omniauth_mlh.callback_url), hash_including(:auth_scheme))
          .and_return(token)
      end

      it 'exchanges authorization code for access token' do
        expect(auth_code).to receive(:get_token)
          .with('valid_code', hash_including(redirect_uri: omniauth_mlh.callback_url), hash_including(:auth_scheme))
        allow(omniauth_mlh).to receive(:env).and_return({})
        omniauth_mlh.callback_phase
      end
    end

    context 'when token exchange fails' do
      before do
        allow(auth_code).to receive(:get_token)
          .and_raise(OAuth2::Error.new(double('Response', parsed: {}, body: '', status: 401)))
      end

      it 'fails with invalid_credentials' do
        expect(omniauth_mlh).to receive(:fail!).with(:invalid_credentials, instance_of(OAuth2::Error))
        omniauth_mlh.callback_phase
      end
    end
  end

  describe '#callback_path' do
    it 'has the correct callback path' do
      expect(omniauth_mlh.callback_path).to eq('/auth/mlh/callback')
    end
  end

  describe '#authorize_params' do
    it 'includes default scopes' do
      expect(omniauth_mlh.authorize_params[:scope]).to eq('public user:read:profile user:read:email')
    end

    it 'allows overriding default scopes' do
      @options = { authorize_params: { scope: 'custom_scope' } }
      expect(omniauth_mlh.authorize_params[:scope]).to eq('custom_scope')
    end
  end

  describe '#data' do
    let(:access_token) { instance_double(OAuth2::AccessToken) }
    let(:api_response) do
      {
        'data' => {
          'id' => '123',
          'email' => 'user@example.com',
          'first_name' => 'John',
          'last_name' => 'Doe',
          'school' => {
            'name' => 'Test University',
            'id' => '456'
          },
          'level_of_study' => 'Undergraduate',
          'major' => 'Computer Science',
          'date_of_birth' => '1990-01-01',
          'gender' => 'Prefer not to say',
          'phone_number' => '+1234567890',
          'profession_type' => 'Student',
          'company' => {
            'name' => 'Tech Corp',
            'title' => 'Intern'
          },
          'created_at' => '2024-01-01T00:00:00Z',
          'updated_at' => '2024-01-02T00:00:00Z'
        }
      }
    end

    let(:response) { instance_double(OAuth2::Response, parsed: api_response) }

    before do
      allow(access_token).to receive(:get)
        .with('https://api.mlh.com/v4/users/me')
        .and_return(response)
    end

    it 'fetches user data from v4 API endpoint' do
      omniauth_mlh.data
      expect(access_token).to have_received(:get).with('https://api.mlh.com/v4/users/me')
    end

    it 'returns parsed user data' do
      expect(omniauth_mlh.data).to eq(api_response.deep_symbolize_keys[:data])
    end

    it 'returns empty hash on error' do
      allow(access_token).to receive(:get).and_raise(StandardError)
      expect(omniauth_mlh.data).to eq({})
    end
  end
end
