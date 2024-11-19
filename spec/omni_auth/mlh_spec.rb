# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OmniAuth::MLH do
  it 'has a version number' do
    expect(OmniAuth::MLH::VERSION).not_to be_nil
    expect(OmniAuth::MLH::VERSION).to eq('4.0.2')
  end

  it 'loads the MLH strategy' do
    expect(OmniAuth::Strategies::MLH).to be_a(Class)
    expect(OmniAuth::Strategies::MLH.superclass).to eq(OmniAuth::Strategies::OAuth2)
  end
end
