# frozen_string_literal: true

# Credit: https://github.com/datariot/omniauth-paypal/blob/master/spec/support/shared_examples.rb
# NOTE it would be useful if this lived in omniauth-oauth2 eventually

shared_examples 'an oauth2 strategy' do
  describe '#client' do
    it 'is initialized with symbolized client_options' do
      @options = { client_options: { 'authorize_url' => 'https://example.com' } }

      expect(subject.client.options[:authorize_url]).to eq('https://example.com')
    end
  end

  describe '#authorize_params' do
    it 'includes any authorize params passed in the :authorize_params option' do
      @options = { authorize_params: { foo: 'bar', baz: 'zip' } }

      expect(subject.authorize_params['foo']).to eq('bar')
      expect(subject.authorize_params['baz']).to eq('zip')
    end

    it 'includes top-level options that are marked as :authorize_options' do
      @options = { authorize_options: ['scope', 'foo'], scope: 'bar', foo: 'baz' }

      expect(subject.authorize_params['scope']).to eq('bar')
      expect(subject.authorize_params['foo']).to eq('baz')
    end
  end

  describe '#token_params' do
    it 'includes any token params passed in the :token_params option' do
      @options = { token_params: { foo: 'bar', baz: 'zip' } }

      expect(subject.token_params['foo']).to eq('bar')
      expect(subject.token_params['baz']).to eq('zip')
    end

    it 'includes top-level options that are marked as :token_options' do
      @options = { token_options: [:scope, :foo], scope: 'bar', foo: 'baz' }

      expect(subject.token_params['scope']).to eq('bar')
      expect(subject.token_params['foo']).to eq('baz')
    end
  end
end
