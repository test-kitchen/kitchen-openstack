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
      openstack_tenant: [YOUR OPENSTACK TENANT ID]
      require_chef_omnibus: latest (if you'll be using Chef)
      image_ref: [SERVER IMAGE ID]
      flavor_ref: [SERVER FLAVOR ID]

By default, a unique server name will be generated and the current user's SSH
key will be used, though that behavior can be overridden with additional
options:

    name: [A UNIQUE SERVER NAME]
    public_key_path: [PATH TO YOUR SSH PUBLIC KEY]
    username: [SSH USER]
    port: [SSH PORT]

Only disable SSL cert validation if you absolutely know what you are doing,
but are stuck with an OpenStack deployment without valid SSL certs.

    disable_ssl_validation: true

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
