# MLH/my-mlh-omniauth

[![Build Status](https://travis-ci.org/MLH/my-mlh-omniauth.svg?branch=master)](https://travis-ci.org/MLH/my-mlh-omniauth)

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

## Development

### Releasing a New Version of the Gem

To release a new version of the Gem, follow these steps:

- Update the version number 
Replace the version in `OmniAuth::MLH::Version` with new version number you want to release, following the Semantic Versioning convention.
-  Commit and push the changes
- Create a new release on GitHub
  - Go to the repository page
  - Click on the "Releases" tab
  - Click on the "Draft a new release" button
  - Fill the release information, including the tag version, release title, and release notes
- Build and publish the Gem
```
gem build omniauth-mlh.gemspec
gem push omniauth-mlh-X.Y.Z.gem
```
Replace `X.Y.Z` with the new version number you want to release.

### Local Testing Strategy

To test Omniauth-MLH locally, you can use [Sinatra application](https://gist.github.com/theycallmeswift/d8a8a22f95dd5d35f03661b19665e0d3). Here are the steps to set up and run the application:

- Add files from [Sinatra application](https://gist.github.com/theycallmeswift/d8a8a22f95dd5d35f03661b19665e0d3) in a folder within a directory next to the checked out [my-mlh-omniauth](https://github.com/MLH/my-mlh-omniauth) library. 
- Add your `api_key` and `api_secret` from your My MLH application to `server.rb` file
- Install the required gems
```bundle install```
- Run the Sinatra Application
```bundle exec rackup```
- Test the application 
Go to `http://localhost:9292` in your browser to test the application

## Contributing

1. Fork it ( https://github.com/mlh/my-mlh-omniauth/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Credit

We used part of [datariot/omniauth-paypal](http://github.com/datariot/omniauth-paypal)'s code to help us test this gem.

## Questions?

Have a question about the API or this library? Start by checking out the
[official MyMLH documentation](https://my.mlh.io/docs). If you still can't
find an answer, tweet at [@MLHacks](http://twitter.com/mlhacks) or drop an
email to [engineering@mlh.io](mailto:engineering@mlh.io).
