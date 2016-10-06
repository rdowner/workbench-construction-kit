# Workbench Construction Kit

The Workbench Construction Kit is a tool for creating an Amiga operating system image with lots of useful software, but which leaves it up to you to decide what you want to install. It's opinionated at the micro level (for example, if you install a TCP/IP stack you will automatically get drivers for common NICs) but not at the macro level (it's up to you to decide if you want to install a TCP/IP stack or not). This means that you can get your Amiga configured with the software you prefer without having to answer hundreds of questions of minutia.

The kit is run on a Linux, macOS or similar OS and will generate a hard drive image. You can then copy this image to a real drive, plug it into your Amiga, and finish off the installation. Alternatively the image file can be used immediately with WinUAE and similar Amiga emulators.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wbck'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wbck

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rdowner/workbench-construction-kit

