# MLH/omniauth-mlh

[![Gem Version](https://badge.fury.io/rb/omniauth-mlh.svg)](https://badge.fury.io/rb/omniauth-mlh)
[![Test](https://github.com/MLH/omniauth-mlh/actions/workflows/test.yml/badge.svg)](https://github.com/MLH/omniauth-mlh/actions/workflows/test.yml)

This is the official [OmniAuth](https://github.com/omniauth/omniauth) strategy for
authenticating with [MyMLH](https://my.mlh.io). To use it, you'll need to
[register an application](https://my.mlh.io/oauth/applications) and obtain a OAuth Application ID and Secret from MyMLH.

It supports MyMLH API V4. [Read the MyMLH V4 docs here](https://my.mlh.io/docs).

Once you have done so, you can follow the instructions below:

## Requirements

This Gem requires Ruby version 3.2.0 or higher. This requirement is set to ensure compatibility
with the latest features and security updates.

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

```ruby
use OmniAuth::Builder do
  provider :mlh, ENV['MY_MLH_KEY'], ENV['MY_MLH_SECRET'],
          scope: 'user:read:profile user:read:email offline_access'
end
```

## Usage (Rails with Devise)

```ruby
# config/devise.rb

Devise.setup do |config|
  config.provider :mlh, ENV['MY_MLH_KEY'], ENV['MY_MLH_SECRET'],
                  scope: 'user:read:profile user:read:email offline_access'
end
```

## Available Scopes

The following scopes are available in the v4 API:
- `user:read:profile` - Access to basic profile information
- `user:read:email` - Access to email address
- `user:read:demographics` - Access to demographic information
- `user:read:education` - Access to education details
- `user:read:employment` - Access to employment information
- `offline_access` - Enables refresh token support

## Contributing

For guidance on setting up a development environment and how to make a contribution to omniauth-mlh, see the [contributing guidelines](https://github.com/MLH/omniauth-mlh/blob/main/CONTRIBUTING.md).

## Credit

We used part of [datariot/omniauth-paypal](http://github.com/datariot/omniauth-paypal)'s code to help us test this gem.

## Questions?

Have a question about the API or this library? Start by checking out the
[official MyMLH documentation](https://my.mlh.io/docs). If you still can't
find an answer, tweet at [@MLHacks](http://twitter.com/mlhacks) or drop an
email to [engineering@mlh.io](mailto:engineering@mlh.io).
