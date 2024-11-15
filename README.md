# MLH/omniauth-mlh

[![Gem Version](https://badge.fury.io/rb/omniauth-mlh.svg)](https://badge.fury.io/rb/omniauth-mlh)
[![Test](https://github.com/MLH/omniauth-mlh/actions/workflows/test.yml/badge.svg)](https://github.com/MLH/omniauth-mlh/actions/workflows/test.yml)

This is the official [OmniAuth](https://github.com/omniauth/omniauth) strategy for
authenticating with [MyMLH](https://my.mlh.io) in Ruby applications. To use it, you'll need to
[register an application](https://my.mlh.io/developers) and obtain a OAuth Application ID and Secret from MyMLH.

It now supports MyMLH API V4. [Read the MyMLH V4 docs here](https://my.mlh.io/developers/docs).

Once you have done so, you can follow the instructions below:

## Requirements

This Gem requires your Ruby version to be at least `3.2.0`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-mlh'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-mlh

## Usage (Rack)

You can find a list of potential scopes and expandable fields in the [docs](https://my.mlh.io/developers/docs). The below defaults are provided simply as an example.

```ruby
use OmniAuth::Builder do
  provider :mlh, ENV['MY_MLH_KEY'], ENV['MY_MLH_SECRET'],
    scope: 'public offline_access user:read:profile',
    expand_fields: ['education']
end
```

## Usage (Rails with Devise)

```ruby
# config/devise.rb

Devise.setup do |config|
  config.provider :mlh, ENV['MY_MLH_KEY'], ENV['MY_MLH_SECRET'],
    scope: 'public offline_access user:read:profile',
    expand_fields: ['education']
end
```

## Accessing User Data
Once a user has been authorized and you have received a token in your callback, you may access the scoped information for that user via the info key on the request data, as per the below example from a simple Sinatra app:

```ruby
get '/auth/mlh/callback' do
  auth = request.env['omniauth.auth']
  user_data = auth['info']
  first_name = user_data['first_name']
  erb "
    <h1>Hello #{first_name}</h1>"
end
```

You can find the full User object in the [docs](https://my.mlh.io/developers/docs).

## Contributing

For guidance on setting up a development environment and how to make a contribution to omniauth-mlh, see the [contributing guidelines](https://github.com/MLH/omniauth-mlh/blob/main/CONTRIBUTING.md).

## Credit

We used part of [datariot/omniauth-paypal](http://github.com/datariot/omniauth-paypal)'s code to help us test this gem.

## Questions?

Have a question about the API or this library? Start by checking out the
[official MyMLH documentation](https://my.mlh.io/developers/docs). If you still can't
find an answer, tweet at [@MLHacks](http://twitter.com/mlhacks) or drop an
email to [engineering@mlh.io](mailto:engineering@mlh.io).
