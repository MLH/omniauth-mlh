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
      expect(omniauth_mlh.client.options[:token_url]).to eq('https://api.mlh.com/v4/oauth/token')
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

  describe '#raw_info' do
    let(:access_token) { instance_double('AccessToken', get: response, token: 'test_token') }
    before do
      allow(omniauth_mlh).to receive(:access_token).and_return(access_token)
    end

    context 'when the API call succeeds' do
      let(:response) { instance_double('Response', parsed: { 'id' => '123' }) }

      it 'returns the parsed response' do
        expect(omniauth_mlh.raw_info).to eq({ 'id' => '123' })
      end
    end

    context 'when the API call fails' do
      let(:response) { instance_double('Response') }
      before do
        allow(response).to receive(:parsed).and_raise(StandardError)
      end

      it 'returns an empty hash' do
        expect(omniauth_mlh.raw_info).to eq({})
      end
    end
  end

  describe '#build_fields_param' do
    context 'when no fields are specified' do
      it 'returns an empty string' do
        expect(omniauth_mlh.send(:build_fields_param)).to eq('')
      end
    end

    context 'when fields are specified' do
      before do
        @options = { fields: ['education', 'experience'] }
      end

      it 'returns correctly formatted query string' do
        expect(omniauth_mlh.send(:build_fields_param)).to eq('?expand[]=education&expand[]=experience')
      end
    end

    context 'when a single field is specified' do
      before do
        @options = { fields: 'education' }
      end

      it 'handles single field correctly' do
        expect(omniauth_mlh.send(:build_fields_param)).to eq('?expand[]=education')
      end
    end
  end

  describe '#info' do
    let(:access_token) { instance_double('AccessToken', get: response, token: 'test_token') }
    before do
      allow(omniauth_mlh).to receive(:access_token).and_return(access_token)
    end

    context 'when all fields are present' do
      let(:raw_info) do
        {
          'id' => '123',
          'email' => 'user@example.com',
          'first_name' => 'John',
          'last_name' => 'Doe',
          'created_at' => '2024-01-01T00:00:00Z',
          'updated_at' => '2024-01-02T00:00:00Z',
          'roles' => ['hacker', 'organizer'],
          'phone_number' => '+1234567890'
        }
      end
      let(:response) { instance_double('Response', parsed: raw_info) }

      it 'returns a hash with all user information' do
        expect(omniauth_mlh.info).to eq({
          id: '123',
          email: 'user@example.com',
          first_name: 'John',
          last_name: 'Doe',
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-01-02T00:00:00Z',
          roles: ['hacker', 'organizer'],
          phone_number: '+1234567890'
        })
      end
    end

    context 'when some fields are missing' do
      let(:raw_info) do
        {
          'id' => '123',
          'email' => 'user@example.com',
          'first_name' => 'John'
        }
      end
      let(:response) { instance_double('Response', parsed: raw_info) }

      it 'returns a hash with available information and nil for missing fields' do
        expect(omniauth_mlh.info).to eq({
          id: '123',
          email: 'user@example.com',
          first_name: 'John',
          last_name: nil,
          created_at: nil,
          updated_at: nil,
          roles: nil,
          phone_number: nil
        })
      end
    end

    context 'when raw_info is empty' do
      let(:response) { instance_double('Response', parsed: {}) }

      it 'returns a hash with all nil values except id' do
        expect(omniauth_mlh.info).to eq({
          id: nil,
          email: nil,
          first_name: nil,
          last_name: nil,
          created_at: nil,
          updated_at: nil,
          roles: nil,
          phone_number: nil
        })
      end
    end
  end

  describe '#extra' do
    let(:access_token) { instance_double('AccessToken', get: response, token: 'test_token') }
    before do
      allow(omniauth_mlh).to receive(:access_token).and_return(access_token)
    end

    context 'when all extra fields are present' do
      let(:raw_info) do
        {
          'id' => '123',
          'profile' => { 'bio' => 'Hacker', 'skills' => ['Ruby', 'Python'] },
          'address' => { 'city' => 'New York', 'country' => 'USA' },
          'social_profiles' => { 'github' => 'johndoe', 'linkedin' => 'john-doe' },
          'professional_experience' => [{ 'company' => 'MLH', 'role' => 'Developer' }],
          'education' => [{ 'school' => 'University', 'degree' => 'CS' }],
          'identifiers' => { 'github_id' => '12345' }
        }
      end
      let(:response) { instance_double('Response', parsed: raw_info) }

      it 'returns a hash with all extra information' do
        expect(omniauth_mlh.extra).to eq({
          'raw_info' => raw_info,
          'profile' => { 'bio' => 'Hacker', 'skills' => ['Ruby', 'Python'] },
          'address' => { 'city' => 'New York', 'country' => 'USA' },
          'social_profiles' => { 'github' => 'johndoe', 'linkedin' => 'john-doe' },
          'professional_experience' => [{ 'company' => 'MLH', 'role' => 'Developer' }],
          'education' => [{ 'school' => 'University', 'degree' => 'CS' }],
          'identifiers' => { 'github_id' => '12345' }
        })
      end
    end

    context 'when some extra fields are missing' do
      let(:raw_info) do
        {
          'id' => '123',
          'profile' => { 'bio' => 'Hacker' },
          'education' => [{ 'school' => 'University' }]
        }
      end
      let(:response) { instance_double('Response', parsed: raw_info) }

      it 'returns a hash with available extra information and nil for missing fields' do
        expect(omniauth_mlh.extra).to eq({
          'raw_info' => raw_info,
          'profile' => { 'bio' => 'Hacker' },
          'address' => nil,
          'social_profiles' => nil,
          'professional_experience' => nil,
          'education' => [{ 'school' => 'University' }],
          'identifiers' => nil
        })
      end
    end

    context 'when raw_info is empty' do
      let(:response) { instance_double('Response', parsed: {}) }

      it 'returns a hash with empty raw_info and nil values' do
        expect(omniauth_mlh.extra).to eq({
          'raw_info' => {},
          'profile' => nil,
          'address' => nil,
          'social_profiles' => nil,
          'professional_experience' => nil,
          'education' => nil,
          'identifiers' => nil
        })
      end
    end
  end
end
