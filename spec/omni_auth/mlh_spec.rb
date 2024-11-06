# frozen_string_literal: true

require 'spec_helper'

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
    let(:access_token) { instance_double('AccessToken', get: response) }
    let(:response) { instance_double('Response', parsed: parsed_response) }
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
      allow(omniauth_mlh).to receive(:access_token).and_return(access_token)
      allow(omniauth_mlh).to receive(:uid).and_return('123')
    end

    it 'requests the correct API endpoint' do
      expect(access_token).to receive(:get).with('https://api.mlh.com/v4/users/123')
      omniauth_mlh.raw_info
    end

    it 'returns symbolized response data' do
      info = omniauth_mlh.raw_info
      expect(info[:user][:email]).to eq('user@example.com')
      expect(info[:user][:demographics][:gender]).to eq('male')
    end

    context 'when the request fails' do
      before do
        allow(access_token).to receive(:get).and_raise(StandardError)
      end

      it 'returns an empty hash' do
        expect(omniauth_mlh.raw_info).to eq({})
      end
    end
  end

  describe '#data' do
    let(:access_token) { instance_double('AccessToken', get: response) }
    let(:response) { instance_double('Response', parsed: { 'id' => '123' }) }

    before do
      allow(omniauth_mlh).to receive(:access_token).and_return(access_token)
    end

    it 'requests the correct API endpoint' do
      expect(access_token).to receive(:get).with('/api/v4/me')
      omniauth_mlh.data
    end

    context 'when the request fails' do
      before do
        allow(access_token).to receive(:get).and_raise(StandardError)
      end

      it 'returns an empty hash' do
        expect(omniauth_mlh.data).to eq({})
      end
    end
  end
end
