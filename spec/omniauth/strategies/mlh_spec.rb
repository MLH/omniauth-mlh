# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OmniAuth::Strategies::MLH do
  let(:strategy) { described_class.new(app, 'client_id', 'client_secret') }

  let(:app) { ->(_env) { [200, {}, ['Hello.']] } }
  let(:access_token) { instance_double(OAuth2::AccessToken, options: {}) }

  before do
    allow(strategy).to receive(:access_token).and_return(access_token)
  end

  describe '#data' do
    context 'with v4 API response' do
      it 'correctly handles expandable fields' do
        allow(strategy).to receive(:options).and_return(expand_fields: ['profile', 'education'])
        expect(access_token).to receive(:get)
          .with('https://api.mlh.com/v4/users/me?expand[]=profile&expand[]=education')
          .and_return(double(parsed: { 'data' => {} }))
        strategy.data
      end

      it 'correctly parses nested profile data' do
        # Create response data that will be processed by deep_symbolize_keys
        raw_response = {
          'data' => {
            'id' => 'test-id',
            'first_name' => 'Jane',
            'profile' => {
              'age' => 22,
              'gender' => 'Female'
            }
          }
        }

        # Create a response object that will be processed by the strategy
        oauth_response = double('Response')
        allow(oauth_response).to receive(:parsed).and_return(raw_response)

        # Mock the access token to return our response
        allow(access_token).to receive(:get)
          .with('https://api.mlh.com/v4/users/me')
          .and_return(oauth_response)

        # Test the processed result
        result = strategy.data
        expect(result).to be_a(Hash)
        expect(result[:profile]).to eq({ age: 22, gender: 'Female' })
      end

      it 'handles empty profile data' do
        allow(access_token).to receive(:get)
          .with('https://api.mlh.com/v4/users/me')
          .and_return(double(parsed: { 'data' => {} }))
        expect(strategy.data).to eq({})
      end

      it 'correctly handles complex nested arrays and hashes' do
        raw_response = {
          'data' => {
            'id' => 'test-id',
            'education' => [
              {
                'school' => {
                  'name' => 'Test University',
                  'location' => 'Test City'
                },
                'graduation_year' => 2024
              }
            ],
            'social_profiles' => [
              { 'platform' => 'github', 'url' => 'https://github.com' },
              'https://twitter.com' # Mixed array with hash and string
            ],
            'professional_experience' => [
              {
                'company' => 'Tech Corp',
                'positions' => [
                  { 'title' => 'Engineer', 'years' => [2022, 2023] }
                ]
              }
            ]
          }
        }

        oauth_response = double('Response')
        allow(oauth_response).to receive(:parsed).and_return(raw_response)
        allow(access_token).to receive(:get)
          .with('https://api.mlh.com/v4/users/me')
          .and_return(oauth_response)

        result = strategy.data
        expect(result).to be_a(Hash)
        expect(result[:education].first[:school]).to eq({ name: 'Test University', location: 'Test City' })
        expect(result[:social_profiles]).to eq([{ platform: 'github', url: 'https://github.com' }, 'https://twitter.com'])
        expect(result[:professional_experience].first[:positions].first[:years]).to eq([2022, 2023])
      end

      it 'correctly handles hash pruning with nil values' do
        raw_response = {
          'data' => {
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
            'education' => nil
          }
        }

        oauth_response = double('Response')
        allow(oauth_response).to receive(:parsed).and_return(raw_response)
        allow(access_token).to receive(:get)
          .with('https://api.mlh.com/v4/users/me')
          .and_return(oauth_response)

        result = strategy.data
        expect(result).to be_a(Hash)
        expect(result[:last_name]).to be_nil
        expect(result[:profile][:gender]).to be_nil
        expect(result[:profile][:location]).to eq({ city: nil, country: 'USA' })
        expect(result[:education]).to be_nil
      end

      it 'correctly handles completely empty hashes' do
        raw_response = {
          'data' => {
            'id' => 'test-id',
            'profile' => {},
            'education' => {
              'schools' => {},
              'degrees' => []
            },
            'social_profiles' => {
              'github' => {},
              'linkedin' => {}
            }
          }
        }

        oauth_response = double('Response')
        allow(oauth_response).to receive(:parsed).and_return(raw_response)
        allow(access_token).to receive(:get)
          .with('https://api.mlh.com/v4/users/me')
          .and_return(oauth_response)

        result = strategy.data
        expect(result).to be_a(Hash)
        expect(result[:profile]).to eq({})
        expect(result[:education]).to eq({ schools: {}, degrees: [] })
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
      before do
        allow(strategy).to receive(:data).and_return({ id: 'test-123' })
      end

      it 'returns the id from the data hash' do
        expect(strategy.uid).to eq('test-123')
      end
    end

    context 'with missing id' do
      before do
        allow(strategy).to receive(:data).and_return({})
      end

      it 'returns nil when id is not present' do
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

    it 'includes all required v4 fields' do
      expect(strategy.info).to include(
        first_name: 'Jane',
        last_name: 'Hacker',
        email: 'jane@example.com',
        roles: ['hacker']
      )
    end
  end
end
