# Kitchen::OpenStack

![Gem Version](https://img.shields.io/gem/v/kitchen-openstack.svg)
![CI](https://github.com/test-kitchen/kitchen-openstack/actions/workflows/lint.yml/badge.svg)

A Test Kitchen Driver for OpenStack.

This driver uses the fog gem to provision and destroy nova instances. Use an OpenStack cloud for your infrastructure testing!

Shamelessly copied from [Fletcher Nichol](https://github.com/fnichol)'s awesome work on an [EC2 driver](https://github.com/test-kitchen/kitchen-ec2), and [Adam Leff](https://github.com/adamleff)'s amazing work on an [VRO driver](https://github.com/chef-partners/kitchen-vro).

## Status

This software project is actively maintained by the [OSU Open Source Lab](https://osuosl.org/).

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

### Using `clouds.yaml`

This driver supports OpenStack's standard
[`clouds.yaml`](https://docs.openstack.org/python-openstackclient/latest/configuration/index.html)
client configuration file. This allows you to use the same credentials and
endpoint configuration that other OpenStack tools (like the `openstack` CLI)
already use, instead of duplicating them in `kitchen.yml`.

The driver searches for `clouds.yaml` in the standard locations:

1. `OS_CLIENT_CONFIG_FILE` environment variable (if set)
2. `clouds_yaml_path` driver config option (if set)
3. Current directory (`./clouds.yaml`)
4. `~/.config/openstack/clouds.yaml`
5. `/etc/openstack/clouds.yaml`

The first file found is used. A `secure.yaml` file in the same search
locations is also loaded and merged, so you can split secrets out of
`clouds.yaml` following the
[standard convention](https://docs.openstack.org/openstacksdk/latest/user/config/configuration.html#splitting-secrets).

#### Selecting a cloud

Specify which cloud entry to use in one of two ways:

- Set `openstack_cloud` in `kitchen.yml` (takes precedence)
- Set the `OS_CLOUD` environment variable

#### Example `kitchen.yml`

```yaml
driver:
  name: openstack
  openstack_cloud: mycloud
  image_ref: ubuntu-22.04
  flavor_ref: m1.small
  key_name: my-keypair
```

Or, relying entirely on `OS_CLOUD`:

```bash
export OS_CLOUD=mycloud
```

```yaml
driver:
  name: openstack
  image_ref: ubuntu-22.04
  flavor_ref: m1.small
  key_name: my-keypair
```

Settings specified in `kitchen.yml` always take precedence over values from
`clouds.yaml`. For example, you can override just the region:

```yaml
driver:
  name: openstack
  openstack_cloud: mycloud
  openstack_region: RegionTwo
```

#### Using `OS_*` environment variables

The driver recognizes the standard OpenStack `OS_*` environment variables
(e.g. from an `openrc` file). This means you can source your OpenStack
credentials and use them directly without any extra configuration in
`kitchen.yml`:

```bash
source openrc.sh
```

```yaml
driver:
  name: openstack
  image_ref: ubuntu-22.04
  flavor_ref: m1.small
  key_name: my-keypair
```

The supported environment variables are:

| Env var | Maps to |
|---|---|
| `OS_AUTH_URL` | `openstack_auth_url` |
| `OS_USERNAME` | `openstack_username` |
| `OS_PASSWORD` | `openstack_api_key` |
| `OS_PROJECT_NAME` | `openstack_project_name` |
| `OS_PROJECT_ID` | `openstack_project_id` |
| `OS_USER_DOMAIN_NAME` | `openstack_user_domain` |
| `OS_USER_DOMAIN_ID` | `openstack_user_domain_id` |
| `OS_PROJECT_DOMAIN_NAME` | `openstack_project_domain` |
| `OS_PROJECT_DOMAIN_ID` | `openstack_project_domain_id` |
| `OS_DOMAIN_ID` | `openstack_domain_id` |
| `OS_DOMAIN_NAME` | `openstack_domain_name` |
| `OS_REGION_NAME` | `openstack_region` |
| `OS_INTERFACE` | `openstack_endpoint_type` |
| `OS_IDENTITY_API_VERSION` | `openstack_identity_api_version` |
| `OS_APPLICATION_CREDENTIAL_ID` | `openstack_application_credential_id` |
| `OS_APPLICATION_CREDENTIAL_SECRET` | `openstack_application_credential_secret` |
| `OS_CACERT` | `ssl_ca_file` |

#### Configuration precedence

The driver follows the upstream OpenStack SDK precedence order:

1. **`kitchen.yml`** — explicit driver config always wins
2. **`OS_*` env vars** — override `clouds.yaml` values
3. **`clouds.yaml`** (merged with `secure.yaml`) — base configuration

#### New driver config options

| Option | Default | Description |
|---|---|---|
| `openstack_cloud` | `nil` | Name of the cloud entry in `clouds.yaml`. Falls back to the `OS_CLOUD` env var. |
| `clouds_yaml_path` | `nil` | Explicit path to a `clouds.yaml` file, inserted into the search path. |

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
