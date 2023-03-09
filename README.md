# MLH/omniauth-mlh

[![Build Status](https://travis-ci.org/MLH/omniauth-mlh.svg?branch=master)](https://travis-ci.org/MLH/omniauth-mlh)

This is the official [OmniAuth](https://github.com/omniauth/omniauth) strategy for
authenticating with [MyMLH](https://my.mlh.io). To use it, you'll need to
[register an application](https://my.mlh.io/oauth/applications) and obtain a OAuth Application ID and Secret from MyMLH.

It now supports MyMLH API V3. [Read the MyMLH V3 docs here](https://my.mlh.io/docs).

Once you have done so, you can follow the instructions below:

## Requirements

This Gem requires your Ruby version to be at least `2.2.0`, which is set
downstream by [Omniauth](https://github.com/omniauth/omniauth/blob/master/omniauth.gemspec#L22).

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
  provider :mlh, ENV['MY_MLH_KEY'], ENV['MY_MLH_SECRET'], scope: 'default email birthday'
end
```

## Usage (Rails with Devise)

```ruby
# config/devise.rb

Devise.setup do |config|
  config.provider :mlh, ENV['MY_MLH_KEY'], ENV['MY_MLH_SECRET'], scope: 'default email birthday'
end
```

## Contributing

For guidance on setting up a development environment and how to make a contribution to omniauth-mlh, see the [contributing guidelines](https://github.com/MLH/omniauth-mlh/blob/main/CONTRIBUTING.md).

## Credit

We used part of [datariot/omniauth-paypal](http://github.com/datariot/omniauth-paypal)'s code to help us test this gem.

## Questions?

Have a question about the API or this library? Start by checking out the
[official MyMLH documentation](https://my.mlh.io/docs). If you still can't
find an answer, tweet at [@MLHacks](http://twitter.com/mlhacks) or drop an
email to [engineering@mlh.io](mailto:engineering@mlh.io).
