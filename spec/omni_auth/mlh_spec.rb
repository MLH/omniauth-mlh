# frozen_string_literal: true

require 'spec_helper'

describe OmniAuth::MLH do
  subject(:omniauth_mlh) do
    OmniAuth::Strategies::MLH.new(nil, @options || {}) # rubocop:disable RSpec/InstanceVariable
  end

  let(:access_token) do
    double('AccessToken',
           token: 'token',
           refresh_token: 'refresh_token',
           expires_at: 1234567890,
           expires?: true,
           get: response)
  end

  let(:response) do
    double('Response',
           success?: true,
           parsed: {
             'id' => '12345',
             'email' => 'user@example.com',
             'first_name' => 'John',
             'last_name' => 'Doe',
             'demographics' => {
               'gender' => 'male',
               'date_of_birth' => '1990-01-01'
             }
           })
  end

  before do
    allow(subject).to receive(:access_token).and_return(access_token)
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

    it 'runs the setup block if passed one' do
      counter = ''
      @options = { setup: proc { |_env| counter = 'ok' } }
      omniauth_mlh.setup_phase
      expect(counter).to eq('ok')
    end
  end

  describe 'default options' do
    it 'has default scope' do
      expect(subject.options.scope).to eq('user:read:profile offline_access')
    end

    it 'has empty fields array by default' do
      expect(subject.options.fields).to eq([])
    end
  end

  describe '#raw_info' do
    let(:mock_response) do
      {
        'id' => '12345',
        'email' => 'user@example.com',
        'first_name' => 'John',
        'last_name' => 'Doe',
        'demographics' => {
          'gender' => 'male',
          'date_of_birth' => '1990-01-01'
        },
        'education' => {
          'level' => 'undergraduate',
          'major' => 'Computer Science'
        }
      }
    end

    context 'when successful' do
      before do
        allow(access_token).to receive(:get)
          .with('/v4/users/me')
          .and_return(double('Response', success?: true, parsed: mock_response))
      end

      it 'returns parsed response' do
        expect(subject.raw_info).to eq(mock_response)
      end
    end

    context 'with expandable fields' do
      before do
        @options = { fields: ['email', 'demographics'] }
        allow(access_token).to receive(:get)
          .with('/v4/users/me?fields=email,demographics')
          .and_return(double('Response', success?: true, parsed: mock_response))
      end

      it 'includes fields in request' do
        expect(subject.raw_info).to eq(mock_response)
      end
    end

    context 'when request fails' do
      before do
        allow(access_token).to receive(:get)
          .with('/v4/users/me')
          .and_return(double('Response', success?: false, error: 'Invalid token'))
      end

      it 'raises error' do
        expect { subject.raw_info }.to raise_error(OmniAuth::Error, 'Invalid token')
      end
    end
  end

  describe '#info' do
    let(:mock_info) do
      {
        'id' => '12345',
        'email' => 'user@example.com',
        'first_name' => 'John',
        'last_name' => 'Doe',
        'created_at' => '2024-01-01T00:00:00Z',
        'updated_at' => '2024-01-02T00:00:00Z',
        'demographics' => {
          'gender' => 'male',
          'date_of_birth' => '1990-01-01',
          'country' => 'US'
        },
        'education' => {
          'level' => 'undergraduate',
          'major' => 'Computer Science',
          'school' => 'Test University',
          'graduation_year' => 2025
        },
        'employment' => {
          'type' => 'student',
          'company' => 'Test Corp',
          'title' => 'Intern',
          'start_date' => '2024-01-01'
        }
      }
    end

    before do
      allow(subject).to receive(:raw_info).and_return(mock_info)
    end

    it 'returns complete info hash with v4 structure' do
      info = subject.info
      expect(info).to include(
        'email' => 'user@example.com',
        'first_name' => 'John',
        'last_name' => 'Doe'
      )
      expect(info['demographics']).to include(
        'gender' => 'male',
        'date_of_birth' => '1990-01-01',
        'country' => 'US'
      )
      expect(info['education']).to include(
        'level' => 'undergraduate',
        'major' => 'Computer Science',
        'school' => 'Test University'
      )
      expect(info['employment']).to include(
        'type' => 'student',
        'company' => 'Test Corp',
        'title' => 'Intern'
      )
    end

    context 'when fields are missing' do
      let(:mock_info) { {} }

      it 'returns empty hash for missing data' do
        expect(subject.info).to eq({})
      end
    end

    context 'with partial data' do
      let(:mock_info) do
        {
          'email' => 'user@example.com',
          'demographics' => nil,
          'education' => {}
        }
      end

      it 'includes only present data' do
        info = subject.info
        expect(info['email']).to eq('user@example.com')
        expect(info).not_to have_key('demographics')
        expect(info).not_to have_key('education')
      end
    end
  end

  describe '#credentials' do

    it 'returns all credentials' do
      expect(subject.credentials).to eq({
        'token' => 'token',
        'refresh_token' => 'refresh_token',
        'expires_at' => 1234567890,
        'expires' => true
      })
    end
  end

  describe '#callback_path' do
    it 'has the correct callback path' do
      expect(omniauth_mlh.callback_path).to eq('/auth/mlh/callback')
    end
  end
end
