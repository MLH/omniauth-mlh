# Contributing Guidelines

Thank you for considering contributing to omniauth-mlh.

## Contributor Checklist

- Fork the Repo ( https://github.com/mlh/omniauth-mlh/fork )
- Create your feature branch (`git checkout -b my-new-feature`)
- Commit your changes (`git commit -am 'Add some feature'`)
- Push to the branch (`git push origin my-new-feature`)
- Create a new Pull Request

## Local Testing Strategy

To test Omniauth-MLH locally, you can use [Sinatra application](https://gist.github.com/theycallmeswift/d8a8a22f95dd5d35f03661b19665e0d3). Here are the steps to set up and run the application:

- Add files from Sinatra application](https://gist.github.com/theycallmeswift/d8a8a22f95dd5d35f03661b19665e0d3) in a folder within a directory next to the checked out [omniauth-mlh](https://github.com/MLH/omniauth-mlh) library. 
- Add your `api_key` and `api_secret` from your My MLH application to `server.rb` file
- Install the required gems
```bundle install```
- Run the Sinatra Application
```bundle exec rackup```
- Test the application 
Go to `http://localhost:9292` in your browser to test the application

## Releasing a New Version of the Gem

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