# Kitchen::OpenStack

![Gem Version](https://img.shields.io/gem/v/kitchen-openstack.svg)
![CI](https://github.com/test-kitchen/kitchen-openstack/workflows/CI/badge.svg)

A Test Kitchen Driver for OpenStack.

This driver uses the fog gem to provision and destroy nova instances. Use an OpenStack cloud for your infrastructure testing!

Shamelessly copied from [Fletcher Nichol](https://github.com/fnichol)'s awesome work on an [EC2 driver](https://github.com/test-kitchen/kitchen-ec2), and [Adam Leff](https://github.com/adamleff)'s amazing work on an [VRO driver](https://github.com/chef-partners/kitchen-vro).

## Status

This software project is no longer under active development as it has no active maintainers. The software may continue to work for some or all use cases, but issues filed in GitHub will most likely not be triaged. If a new maintainer is interested in working on this project please come chat with us in #test-kitchen on Chef Community Slack.

## Requirements

There are **no** external system requirements for this driver. However you will need access to an OpenStack cloud.

## Installation and Setup

This plugin ships out of the box with Chef Workstation, which is the easiest way to make sure you always have the latest testing dependencies in a single package.

[Download Chef Workstation](https://downloads.chef.io/tools/workstation) to get started

### Manual Installation

Add this line to your application's Gemfile:

```ruby
gem 'kitchen-openstack'
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install kitchen-openstack
```

## Usage

See <https://kitchen.ci/docs/drivers/openstack/> for documentation.

## Development

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run the tests and rubocop, `bundle exec rake spec` and `bundle exec rake rubocop`
4. Commit your changes (`git commit -am 'Added some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

## Authors

Created by Jonathan Hartman

## License

Apache 2.0 (see LICENSE.txt file)
