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
end
