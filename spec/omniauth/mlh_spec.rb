require 'spec_helper'

describe OmniAuth::MLH do
  subject do
    OmniAuth::Strategies::MLH.new({})
  end

  context "client options" do
    it 'should have correct site' do
      expect(subject.options.client_options.site).to eq('https://my.mlh.io')
    end

    it 'should have correct authorize url' do
      expect(subject.options.client_options.authorize_path).to eq('/oauth/authorize')
    end
  end
end
