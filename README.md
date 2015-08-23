# SimpleBench

Running benchmarks is good if you have 2 blocks of trivial code

But if you are comparing across a series of versions, then it is tricky.

The goal is to collect multiple versions of a number of benchmarks
and easily understand what is different across them.

From there, a profiler can be used to track down the regression.

This feels very similar to rubybench, and I'm hoping to
migrate to their data storage, and possibly update their
data display.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_bench'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_bench

## Usage

To populate historical data.
Do note, that you should stash if you have data checked out locally

```bash
$ git checkout master
$ for i in {1..5}; do
  git checkout HEAD~1
  simple_bench
done
git checkout master
```

View the data

    $ simple_bench --web


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec simple_bench` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kbrock/simple_bench.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

