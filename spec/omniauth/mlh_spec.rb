require 'spec_helper'

describe OmniAuth::MLH do
  subject do
    OmniAuth::Strategies::MLH.new(nil, @options || {})
  end

  it_should_behave_like 'an oauth2 strategy'

  describe '#client' do
    it 'has correct MyMLH site' do
      expect(subject.client.site).to eq('https://my.mlh.io')
    end

    it 'has correct authorize url' do
      expect(subject.client.options[:authorize_url]).to eq('oauth/authorize')
    end

    it 'has correct token url' do
      expect(subject.client.options[:token_url]).to eq('oauth/token')
    end

    it 'runs the setup block if passed one' do
      counter = ''
      @options = { :setup => Proc.new { |env| counter = 'ok' } }
      subject.setup_phase
      expect(counter).to eq("ok")
    end
  end

  describe '#callback_path' do
    it "has the correct callback path" do
      expect(subject.callback_path).to eq('/auth/mlh/callback')
    end
  end
end
