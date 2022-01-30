# <a name="title"></a> Kitchen::OpenStack: A Test Kitchen Driver for OpenStack

[![Gem Version](https://img.shields.io/gem/v/kitchen-openstack.svg)][gem]
![CI](https://github.com/test-kitchen/kitchen-openstack/workflows/CI/badge.svg)

A [Test Kitchen][kitchen_ci] Driver for [OpenStack][openstack_web].

This driver uses the [fog gem][fog_web] to provision and destroy nova instances. Use an OpenStack cloud for your infrastructure testing!

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
$ bundle
```

Or install it yourself as:

```bash
$ gem install kitchen-openstack
```

## Usage

See https://kitchen.ci/docs/drivers/openstack/ for documentation.

## <a name="development"></a> Development

* Source hosted at [GitHub][repo]
* Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run the tests and rubocop, `bundle exec rake spec` and `bundle exec rake rubocop`
4. Commit your changes (`git commit -am 'Added some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

## <a name="authors"></a> Authors

Created by [Jonathan Hartman][author] (<j@p4nt5.com>)
and maintained by [JJ Asghar][maintainer] (<jj@chef.io>)

## <a name="license"></a> License

Apache 2.0 (see [LICENSE][license])


[gem]: https://rubygems.org/gems/kitchen-openstack

[author]:           https://github.com/RoboticCheese
[maintainer]:       https://github.com/jjasghar
[issues]:           https://github.com/test-kitchen/kitchen-openstack/issues
[license]:          https://github.com/test-kitchen/kitchen-openstack/blob/master/LICENSE.txt
[repo]:             https://github.com/test-kitchen/kitchen-openstack
[driver_usage]:     https://github.com/test-kitchen/kitchen-openstack
[chef_omnibus_dl]:  https://downloads.chef.io/tools/infra-client
[kitchen_ci]:       http://kitchen.ci

[openstack_web]:    http://www.openstack.org
[fog_web]:          http://fog.io
