# frozen_string_literal: true

require 'spec_helper'
require 'oauth2'

describe OmniAuth::MLH do
  subject(:omniauth_mlh) do
    # The instance variable @options is being used to pass options to the subject of the shared examples
    OmniAuth::Strategies::MLH.new(nil, @options || {}) # rubocop:disable RSpec/InstanceVariable
  end

  it_behaves_like 'an oauth2 strategy'

  describe '#client' do
    it 'has correct MyMLH site' do
      expect(omniauth_mlh.client.site).to eq('https://my.mlh.io')
    end

    it 'has correct authorize url' do
      expect(omniauth_mlh.client.options[:authorize_url]).to eq('oauth/authorize')
    end

    it 'has correct token url' do
      expect(omniauth_mlh.client.options[:token_url]).to eq('oauth/token')
    end

    it 'has correct site for API endpoints' do
      expect(omniauth_mlh.options.client_options[:site]).to eq('https://my.mlh.io')
    end

    it 'runs the setup block if passed one' do
      counter = ''
      @options = { setup: proc { |_env| counter = 'ok' } }
      omniauth_mlh.setup_phase
      expect(counter).to eq('ok')
    end
  end

  describe '#callback_path' do
    it 'has the correct callback path' do
      expect(omniauth_mlh.callback_path).to eq('/auth/mlh/callback')
    end
  end

  describe '#authorize_params' do
    it 'includes default scopes' do
      expect(omniauth_mlh.authorize_params[:scope]).to include('public user:read:profile')
    end

    it 'preserves custom scopes while adding required ones' do
      @options = { scope: 'user:read:email' }
      expect(omniauth_mlh.authorize_params[:scope]).to include('user:read:email')
      expect(omniauth_mlh.authorize_params[:scope]).to include('public user:read:profile')
    end
  end

  describe '#raw_info' do
    let(:client) { OAuth2::Client.new('id', 'secret', site: 'https://my.mlh.io') }
    let(:auth_code) { OAuth2::Strategy::AuthCode.new(client) }
    let(:token) { OAuth2::AccessToken.new(client, 'token') }
    let(:response) { instance_double(OAuth2::Response, parsed: parsed_response) }
    let(:parsed_response) do
      {
        'user' => {
          'id' => '123',
          'email' => 'user@example.com',
          'first_name' => 'John',
          'last_name' => 'Doe',
          'demographics' => { 'gender' => 'male' },
          'education' => { 'school' => 'University' },
          'created_at' => '2023-01-01',
          'updated_at' => '2023-01-02'
        }
      }
    end

    before do
      @options = { client_id: 'id', client_secret: 'secret' }
      allow(OAuth2::AccessToken).to receive(:new).and_return(token)
      allow(token).to receive(:get).and_return(response)
    end

    it 'requests the correct API endpoint' do
      omniauth_mlh.raw_info
      expect(token).to have_received(:get).with('https://my.mlh.io/v4/users/123')
    end

    it 'returns symbolized response data' do
      info = omniauth_mlh.raw_info
      expect(info[:user][:email]).to eq('user@example.com')
      expect(info[:user][:demographics][:gender]).to eq('male')
    end

    context 'when the request fails' do
      before do
        allow(token).to receive(:get).and_raise(StandardError)
      end

      it 'returns an empty hash' do
        expect(omniauth_mlh.raw_info).to eq({})
      end
    end
  end

  describe '#data' do
    let(:client) { OAuth2::Client.new('id', 'secret', site: 'https://my.mlh.io') }
    let(:auth_code) { OAuth2::Strategy::AuthCode.new(client) }
    let(:token) { OAuth2::AccessToken.new(client, 'token') }
    let(:response) { instance_double(OAuth2::Response, parsed: { 'id' => '123' }) }

    before do
      @options = { client_id: 'id', client_secret: 'secret' }
      allow(OAuth2::AccessToken).to receive(:new).and_return(token)
      allow(token).to receive(:get).and_return(response)
    end

    it 'requests the correct API endpoint' do
      omniauth_mlh.data
      expect(token).to have_received(:get).with('/api/v4/me')
    end

    context 'when the request fails' do
      before do
        allow(token).to receive(:get).and_raise(StandardError)
      end

      it 'returns an empty hash' do
        expect(omniauth_mlh.data).to eq({})
      end
    end
  end
end
