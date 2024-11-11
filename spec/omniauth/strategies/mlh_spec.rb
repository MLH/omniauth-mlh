require 'spec_helper'

RSpec.describe OmniAuth::Strategies::MLH do
  let(:app) { lambda { |_env| [200, {}, ['Hello.']] } }
  let(:access_token) { instance_double('AccessToken', options: {}) }

  subject { described_class.new(app, 'client_id', 'client_secret') }

  before do
    allow(subject).to receive(:access_token).and_return(access_token)
  end

  describe '#data' do
    context 'with v4 API response' do
      it 'correctly handles expandable fields' do
        allow(subject).to receive(:options).and_return(expand_fields: ['profile', 'education'])
        expect(access_token).to receive(:get)
          .with('https://api.mlh.com/v4/users/me?expand[]=profile&expand[]=education')
          .and_return(double(parsed: { 'data' => {} }))
        subject.data
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
        result = subject.data
        expect(result).to be_a(Hash)
        expect(result[:profile]).to eq({ age: 22, gender: 'Female' })
      end

      it 'handles empty profile data' do
        allow(access_token).to receive(:get)
          .with('https://api.mlh.com/v4/users/me')
          .and_return(double(parsed: { 'data' => {} }))
        expect(subject.data).to eq({})
      end
    end

    context 'with API error' do
      it 'returns empty hash on error' do
        allow(access_token).to receive(:get).and_raise(StandardError)
        expect(subject.data).to eq({})
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
      allow(subject).to receive(:data).and_return(user_data)
    end

    it 'includes all required v4 fields' do
      expect(subject.info).to include(
        first_name: 'Jane',
        last_name: 'Hacker',
        email: 'jane@example.com',
        roles: ['hacker']
      )
    end
  end
end
