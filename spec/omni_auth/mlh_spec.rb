# frozen_string_literal: true

require 'spec_helper'
require 'oauth2'
require 'rack'

describe OmniAuth::MLH do
  let(:app) { ->(_env) { [200, {}, ['Hello']] } }
  let(:options) { {} }
  let(:strategy) { OmniAuth::Strategies::MLH.new(app, options) }

  it_behaves_like 'an oauth2 strategy'

  describe '#client' do
    it 'has correct MyMLH site' do
      expect(strategy.client.site).to eq('https://api.mlh.com/v4')
    end

    it 'has correct authorize url' do
      expect(strategy.client.options[:authorize_url]).to eq('https://my.mlh.io/oauth/authorize')
    end

    it 'has correct token url' do
      expect(strategy.client.options[:token_url]).to eq('https://api.mlh.com/v4/oauth/token')
    end

    it 'has correct API site' do
      expect(strategy.options.client_options[:api_site]).to eq('https://api.mlh.com')
    end

    it 'runs the setup block if passed one' do
      counter = ''
      strategy = OmniAuth::Strategies::MLH.new(app, setup: proc { |_env| counter = 'ok' })
      strategy.setup_phase
      expect(counter).to eq('ok')
    end
  end

  describe '#auth_token_params' do
    it 'has correct auth scheme' do
      expect(strategy.options.auth_token_params[:auth_scheme]).to eq(:basic_auth)
    end
  end

  describe '#callback_phase' do
    let(:app) { ->(_env) { [200, {}, ['Hello']] } }
    let(:options) { {} }
    let(:strategy) { OmniAuth::Strategies::MLH.new(app, options) }
    let(:request) do
      instance_double(Rack::Request,
                      params: { 'code' => 'valid_code', 'state' => 'valid_state' },
                      scheme: 'https',
                      url: 'https://example.com',
                      script_name: '',
                      path_info: '/auth/mlh/callback',
                      env: { 'HTTPS' => 'on', 'rack.url_scheme' => 'https' },
                      query_string: 'code=valid_code&state=valid_state')
    end
    let(:auth_code) { instance_double(OAuth2::Strategy::AuthCode) }
    let(:token) { instance_double(OAuth2::AccessToken) }
    let(:api_response) do
      {
        'data' => {
          'id' => '123',
          'email' => 'user@example.com',
          'first_name' => 'John',
          'last_name' => 'Doe',
          'school' => { 'name' => 'Test University', 'id' => '456' },
          'level_of_study' => 'Undergraduate',
          'major' => 'Computer Science',
          'date_of_birth' => '1990-01-01',
          'gender' => 'Prefer not to say',
          'phone_number' => '+1234567890',
          'profession_type' => 'Student',
          'company' => { 'name' => 'Tech Corp', 'title' => 'Intern' },
          'created_at' => '2024-01-01T00:00:00Z',
          'updated_at' => '2024-01-02T00:00:00Z'
        }
      }
    end

    before do
      allow(strategy.client).to receive(:auth_code).and_return(auth_code)
      allow(token).to receive_messages(
        token: 'valid_token',
        expires?: true,
        expired?: false,
        expires_at: 1_234_567_890,
        refresh_token: 'refresh_token'
      )
      allow(token).to receive(:get)
        .with('https://api.mlh.com/v4/users/me')
        .and_return(instance_double(OAuth2::Response, parsed: api_response))

      strategy.instance_variable_set(:@env, {})
      strategy.instance_variable_set(:@request, request)
      strategy.instance_variable_set(:@session, { 'omniauth.state' => 'valid_state' })
    end

    context 'when token exchange is successful' do
      before do
        allow(auth_code).to receive(:get_token)
          .with('valid_code', hash_including(redirect_uri: strategy.callback_url), hash_including(:auth_scheme))
          .and_return(token)
      end

      it 'exchanges authorization code for access token' do
        strategy.callback_phase
        expect(auth_code).to have_received(:get_token)
          .with('valid_code', hash_including(redirect_uri: strategy.callback_url), hash_including(:auth_scheme))
      end
    end

    context 'when token exchange fails' do
      let(:error_response) { instance_double(OAuth2::Response, parsed: {}, body: '', status: 401) }

      before do
        allow(auth_code).to receive(:get_token)
          .and_raise(OAuth2::Error.new(error_response))
        allow(strategy).to receive(:fail!)
      end

      it 'fails with invalid_credentials' do
        strategy.callback_phase
        expect(strategy).to have_received(:fail!)
          .with(:invalid_credentials, instance_of(OAuth2::Error))
      end
    end
  end

  describe '#callback_path' do
    it 'has the correct callback path' do
      expect(strategy.callback_path).to eq('/auth/mlh/callback')
    end
  end

  describe '#authorize_params' do
    it 'includes default scopes' do
      expect(strategy.authorize_params[:scope]).to eq('public user:read:profile user:read:email')
    end

    it 'allows overriding default scopes' do
      custom_strategy = OmniAuth::Strategies::MLH.new(app, authorize_params: { scope: 'custom_scope' })
      expect(custom_strategy.authorize_params[:scope]).to eq('custom_scope')
    end
  end

  describe '#data' do
    let(:app) { ->(_env) { [200, {}, ['Hello']] } }
    let(:options) { {} }
    let(:strategy) { OmniAuth::Strategies::MLH.new(app, options) }
    let(:access_token) { instance_double(OAuth2::AccessToken) }
    let(:api_response) do
      {
        'data' => {
          'id' => '123',
          'email' => 'user@example.com',
          'first_name' => 'John',
          'last_name' => 'Doe',
          'school' => { 'name' => 'Test University', 'id' => '456' },
          'level_of_study' => 'Undergraduate',
          'major' => 'Computer Science',
          'date_of_birth' => '1990-01-01',
          'gender' => 'Prefer not to say',
          'phone_number' => '+1234567890',
          'profession_type' => 'Student',
          'company' => { 'name' => 'Tech Corp', 'title' => 'Intern' },
          'created_at' => '2024-01-01T00:00:00Z',
          'updated_at' => '2024-01-02T00:00:00Z'
        }
      }
    end
    let(:response) { instance_double(OAuth2::Response, parsed: api_response) }

    before do
      strategy.instance_variable_set(:@access_token, access_token)
      allow(access_token).to receive(:get)
        .with('https://api.mlh.com/v4/users/me')
        .and_return(response)
    end

    it 'fetches user data from v4 API endpoint' do
      strategy.data
      expect(access_token).to have_received(:get).with('https://api.mlh.com/v4/users/me')
    end

    it 'returns parsed user data' do
      expect(strategy.data).to eq(api_response.deep_symbolize_keys[:data])
    end

    it 'returns empty hash on error' do
      allow(access_token).to receive(:get).and_raise(StandardError)
      expect(strategy.data).to eq({})
    end
  end
end
