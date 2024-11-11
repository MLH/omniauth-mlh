# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OmniAuth::Strategies::MLH do
  let(:strategy) { described_class.new(app, 'client_id', 'client_secret') }

  let(:app) { ->(_env) { [200, {}, ['Hello.']] } }
  let(:access_token) { instance_double(OAuth2::AccessToken, options: {}) }

  before do
    allow(strategy).to receive(:access_token).and_return(access_token)
  end

  shared_context 'with oauth response' do |response_data|
    let(:oauth_response) do
      instance_double(OAuth2::Response,
                      body: response_data.to_json,
                      parsed: response_data)
    end
    before do
      allow(access_token).to receive(:get)
        .with('https://api.mlh.com/v4/users/me')
        .and_return(oauth_response)
    end
  end

  describe '#data' do
    context 'with expandable fields' do
      let(:response) do
        instance_double(OAuth2::Response, body: {}.to_json, parsed: {})
      end
      let(:expand_url) { 'https://api.mlh.com/v4/users/me?expand[]=profile&expand[]=education' }

      before do
        allow(strategy).to receive(:options).and_return(expand_fields: ['profile', 'education'])
        allow(access_token).to receive(:get).with(expand_url).and_return(response)
      end

      it 'constructs the correct URL with expand parameters' do
        strategy.data

        expect(access_token).to have_received(:get).with(expand_url)
      end

      it 'returns an empty hash for empty response' do
        expect(strategy.data).to eq({})
      end
    end

    context 'with v4 API nested profile data' do
      include_context 'with oauth response', {
        'id' => 'test-id',
        'first_name' => 'Jane',
        'profile' => {
          'age' => 22,
          'gender' => 'Female'
        }
      }

      it 'correctly parses nested profile data' do
        result = strategy.data

        expect(result).to be_a(Hash)
        expect(result[:profile]).to eq({ age: 22, gender: 'Female' })
      end
    end

    context 'with v4 API empty response' do
      include_context 'with oauth response', {}

      it 'returns an empty hash for empty data' do
        expect(strategy.data).to eq({})
      end
    end

    context 'with v4 API complex data structures' do
      include_context 'with oauth response', {
        'id' => 'test-id',
        'education' => [{
          'school' => {
            'name' => 'Test University',
            'location' => 'Test City'
          },
          'graduation_year' => 2024
        }],
        'social_profiles' => [
          { 'platform' => 'github', 'url' => 'https://github.com' },
          'https://twitter.com'
        ],
        'professional_experience' => [{
          'company' => 'Tech Corp',
          'positions' => [
            { 'title' => 'Engineer', 'years' => [2022, 2023] }
          ]
        }]
      }

      it 'correctly processes complex nested structures' do
        result = strategy.data

        expect(result).to be_a(Hash)
        expect(result[:education].first[:school]).to eq({ name: 'Test University', location: 'Test City' })
        expect(result[:social_profiles]).to eq([{ platform: 'github', url: 'https://github.com' }, 'https://twitter.com'])
        expect(result[:professional_experience].first[:positions].first[:years]).to eq([2022, 2023])
      end
    end

    context 'with v4 API nil and empty values' do
      include_context 'with oauth response', {
        'id' => 'test-id',
        'first_name' => 'Jane',
        'last_name' => nil,
        'profile' => {
          'age' => 22,
          'gender' => nil,
          'location' => {
            'city' => nil,
            'country' => 'USA'
          }
        },
        'education' => nil,
        'social_profiles' => {
          'github' => {},
          'linkedin' => {}
        }
      }

      it 'handles nil values correctly' do
        result = strategy.data

        expect(result[:last_name]).to be_nil
        expect(result[:profile][:gender]).to be_nil
        expect(result[:profile][:location]).to eq({ city: nil, country: 'USA' })
        expect(result[:education]).to be_nil
      end

      it 'handles empty hash structures' do
        result = strategy.data

        expect(result[:social_profiles]).to eq({ github: {}, linkedin: {} })
      end
    end

    context 'with API error' do
      it 'returns empty hash on error' do
        allow(access_token).to receive(:get).and_raise(StandardError)

        expect(strategy.data).to eq({})
      end
    end
  end

  describe '#uid' do
    context 'with valid data' do
      it 'returns the id from the data hash' do
        allow(strategy).to receive(:data).and_return({ id: 'test-123' })
        expect(strategy.uid).to eq('test-123')
      end
    end

    context 'with missing id' do
      it 'returns nil when id is not present' do
        allow(strategy).to receive(:data).and_return({})
        expect(strategy.uid).to be_nil
      end
    end
  end

  describe '#info' do
    let(:user_data) do
      {
        first_name: 'Jane',
        last_name: 'Hacker',
        email: 'jane@example.com',
        roles: ['hacker']
      }
    end

    before do
      allow(strategy).to receive(:data).and_return(user_data)
    end

    it 'includes basic user information' do
      expect(strategy.info).to include(
        first_name: 'Jane',
        last_name: 'Hacker',
        email: 'jane@example.com'
      )
    end

    it 'includes user roles' do
      expect(strategy.info[:roles]).to eq(['hacker'])
    end
  end
end
