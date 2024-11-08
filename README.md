# MLH/omniauth-mlh

[![Gem Version](https://badge.fury.io/rb/omniauth-mlh.svg)](https://badge.fury.io/rb/omniauth-mlh)
[![Test](https://github.com/MLH/omniauth-mlh/actions/workflows/test.yml/badge.svg)](https://github.com/MLH/omniauth-mlh/actions/workflows/test.yml)

This is the official [OmniAuth](https://github.com/omniauth/omniauth) strategy for
authenticating with [MyMLH](https://my.mlh.io). To use it, you'll need to
[register an application](https://my.mlh.io/oauth/applications) and obtain a OAuth Application ID and Secret from MyMLH.

It supports MyMLH API V4. For API documentation, please contact MLH support.

Once you have done so, you can follow the instructions below:

## Breaking Changes in Version 2.0.0

Version 2.0.0 introduces support for MyMLH API V4, which includes several breaking changes:

1. New API Endpoints
   - The API now uses `https://api.mlh.com` as the base URL
   - User data is now fetched from `/v4/users/me`

2. Updated Scope System
   - New granular scope system
   - Default scopes: `public user:read:profile user:read:email`
   - The old scope system (e.g., 'default email birthday') is no longer supported

3. Authentication Flow
   - Only Authorization Code Flow is supported
   - Implicit Grant Flow has been removed

## Requirements

This Gem requires your Ruby version to be at least `2.2.0`, which is set
downstream by [Omniauth](https://github.com/omniauth/omniauth/blob/master/omniauth.gemspec#L22).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-mlh', '~> 2.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-mlh

## Usage (Rack)

```ruby
use OmniAuth::Builder do
  provider :mlh, ENV['MY_MLH_KEY'], ENV['MY_MLH_SECRET'],
          scope: 'public user:read:profile user:read:email'
end
```

## Usage (Rails with Devise)

```ruby
# config/devise.rb

Devise.setup do |config|
  config.provider :mlh, ENV['MY_MLH_KEY'], ENV['MY_MLH_SECRET'],
                 scope: 'public user:read:profile user:read:email'
end
```

## Migration Guide

If you're upgrading from v1.x to v2.0.0:

1. Update your gemfile to use version 2.0.0:
   ```ruby
   gem 'omniauth-mlh', '~> 2.0'
   ```

2. Update your scope configuration:
   - Old: `scope: 'default email birthday'`
   - New: `scope: 'public user:read:profile user:read:email'`

3. If you're accessing the API directly:
   - Update API base URL to `https://api.mlh.com`
   - Update user endpoint to `/v4/users/me`

4. Test your integration thoroughly as this is a breaking change

## Contributing

For guidance on setting up a development environment and how to make a contribution to omniauth-mlh, see the [contributing guidelines](https://github.com/MLH/omniauth-mlh/blob/main/CONTRIBUTING.md).

## Credit

We used part of [datariot/omniauth-paypal](http://github.com/datariot/omniauth-paypal)'s code to help us test this gem.

## Questions?

Have a question about the API or this library? Start by checking out the
[official MyMLH documentation](https://my.mlh.io/docs). If you still can't
find an answer, tweet at [@MLHacks](http://twitter.com/mlhacks) or drop an
email to [engineering@mlh.io](mailto:engineering@mlh.io).
