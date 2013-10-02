[![Gem Version](https://badge.fury.io/rb/kitchen-openstack.png)](http://badge.fury.io/rb/kitchen-openstack) [![Dependency Status](https://gemnasium.com/RoboticCheese/kitchen-openstack.png)](https://gemnasium.com/RoboticCheese/kitchen-openstack) [![Build Status](https://travis-ci.org/RoboticCheese/kitchen-openstack.png?branch=master)](https://travis-ci.org/RoboticCheese/kitchen-openstack) [![Code Climate](https://codeclimate.com/github/RoboticCheese/kitchen-openstack.png)](https://codeclimate.com/github/RoboticCheese/kitchen-openstack)

# Kitchen::OpenStack

An OpenStack Nova driver for Test Kitchen 1.0!

Shamelessly copied from [Fletcher Nichol](https://github.com/fnichol)'s
awesome work on an [EC2 driver](https://github.com/opscode/kitchen-ec2).

## Installation

Add this line to your application's Gemfile:

    gem 'kitchen-openstack'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kitchen-openstack

## Usage

Provide, at a minimum, the required driver options in your `.kitchen.yml` file:

    driver_plugin: openstack
    driver_config:
      openstack_username: [YOUR OPENSTACK USERNAME]
      openstack_api_key: [YOUR OPENSTACK API KEY]
      openstack_auth_url: [YOUR OPENSTACK AUTH URL]
      require_chef_omnibus: latest (if you'll be using Chef)
      image_ref: [SERVER IMAGE ID]
      flavor_ref: [SERVER FLAVOR ID]

By default, a unique server name will be generated and the current user's SSH
key will be used (with an RSA key taking precedence over a DSA), though that
behavior can be overridden with additional options:

    name: [A UNIQUE SERVER NAME]
    private_key_path: [PATH TO YOUR PRIVATE SSH KEY]
    public_key_path: [PATH TO YOUR SSH PUBLIC KEY]
    username: [SSH USER]
    port: [SSH PORT]
    key_name: [SSH KEY NAME]
    openstack_tenant: [YOUR OPENSTACK TENANT ID]
    openstack_region: [A VALID OPENSTACK REGION]
    openstack_service_name: [YOUR OPENSTACK COMPUTE SERVICE NAME]
    openstack_network_name: [YOUR OPENSTACK NETWORK NAME]
    floating_ip: [A SPECIFIC FLOATING IP TO ASSIGN]
    floating_ip_pool: [AN OPENSTACK POOL NAME TO ASSIGN THE NEXT IP FROM]

If a `key_name` is provided it will be used instead of any
`public_key_path` that is specified.

If a `key_name` is provided without any `private_key_path`, unexpected
behavior may result if your local RSA/DSA private key doesn't match that
OpenStack key.

    disable_ssl_validation: true

Only disable SSL cert validation if you absolutely know what you are doing,
but are stuck with an OpenStack deployment without valid SSL certs.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
