# OmniAuth MLH

This is the official OmniAuth strategy for authenticating to My MLH. To use
it, you'll need to sign up for an OAuth2 Application ID and Secret on the
[My MLH Applications Page](https://my.mlh.io/oauth/applications).

# Usage

```
use OmniAuth::Builder do
  provider :mlh, ENV['MLH_KEY'], ENV['MLH_SECRET']
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-mlh'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-mlh

## Contributing

1. Fork it ( https://github.com/mlh/omniauth-mlh/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Questions?

Have a question about the API or this library? Start by checking out the
[official My MLH documentation](https://my.mlh.io/docs). If you still can't
find an answer, tweet at [@MLHacks](http://twitter.com/mlhacks) or drop an
email to [hi@mlh.io](mailto://hi@mlh.io).
