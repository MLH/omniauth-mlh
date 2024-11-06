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
      expect(omniauth_mlh.authorize_params[:scope]).to eq('public user:read:profile user:read:email')
    end

    it 'allows overriding default scopes' do
      @options = { authorize_params: { scope: 'custom_scope' } }
      expect(omniauth_mlh.authorize_params[:scope]).to eq('custom_scope')
    end
  end

  describe '#data' do
    let(:access_token) { double('AccessToken') }
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

    before do
      allow(omniauth_mlh).to receive(:access_token).and_return(access_token)
      allow(access_token).to receive(:get)
        .with('https://api.mlh.com/v4/users/me')
        .and_return(double('Response', parsed: api_response))
    end

    it 'fetches user data from v4 API endpoint' do
      expect(access_token).to receive(:get).with('https://api.mlh.com/v4/users/me')
      omniauth_mlh.data
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
