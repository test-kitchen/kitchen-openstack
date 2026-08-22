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

This plugin ships out of the box with [Cinc Workstation](https://cinc.sh/start/workstation/), which is the easiest
way to make sure you always have the latest testing dependencies in a single package. If you have Cinc Workstation
installed, there is nothing else to install.

The examples below use the `cinc` commands. Everything here works identically with Chef Workstation — see
[Using with Chef](#using-with-chef).

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

## Quick Start

The least you need is credentials, an image, a flavor, and a keypair. If you already use the `openstack` CLI, source
your `openrc` and the driver picks the credentials up automatically:

```bash
source openrc.sh
```

```yaml
---
driver:
  name: openstack
  image_ref: ubuntu-22.04
  flavor_ref: m1.small
  key_name: my-keypair

provisioner:
  name: cinc_infra

verifier:
  name: cinc_auditor

platforms:
  - name: ubuntu-22.04

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
```

Then run the full test cycle:

```bash
cinc kitchen test
```

Or step through it:

```bash
cinc kitchen create    # build the nova instance
cinc kitchen converge  # apply your cookbook
cinc kitchen verify    # run your tests
cinc kitchen destroy   # delete the instance
```

## Credentials

There are three ways to give the driver credentials, described in full under
[Using `clouds.yaml`](#using-cloudsyaml) below:

- a `clouds.yaml` file, the same one the `openstack` CLI uses
- the standard `OS_*` environment variables, e.g. from an `openrc` file
- explicit `openstack_*` options in `kitchen.yml`

They combine, in that order of increasing precedence.

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
| --- | --- |
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
| --- | --- | --- |
| `openstack_cloud` | `nil` | Name of the cloud entry in `clouds.yaml`. Falls back to the `OS_CLOUD` env var. |
| `clouds_yaml_path` | `nil` | Explicit path to a `clouds.yaml` file, inserted into the search path. |

## Configuration

All options below are set under the `driver:` key in `kitchen.yml`, or per platform under `platforms[].driver:`.

Credential options (`openstack_auth_url`, `openstack_username`, `openstack_api_key`, `openstack_project_name`,
and the rest of the `openstack_*` family) are listed in
[Using `OS_*` environment variables](#using-os_-environment-variables) above, alongside the environment variable
each one maps to.

### Image and flavor

Give **either** the `_ref` or the `_id` form of each, never both — the driver raises `ActionFailed` if you set both.

| Option | Default | Description |
| --- | --- | --- |
| `image_ref` | *none* | Image to boot, by name, ID, or regular expression. |
| `image_id` | *none* | Image to boot, by exact ID. Cannot be combined with `image_ref`. |
| `flavor_ref` | *none* | Flavor to use, by name, ID, or regular expression. |
| `flavor_id` | *none* | Flavor to use, by exact ID. Cannot be combined with `flavor_ref`. |

### Instance

| Option | Default | Description |
| --- | --- | --- |
| `server_name` | *generated* | Name of the instance. Generated from the suite and platform if unset. |
| `server_name_prefix` | `nil` | Prefix for the generated name. Ignored when `server_name` is set. |
| `availability_zone` | *scheduler chooses* | Availability zone to launch into. |
| `security_groups` | *project default* | Array of security group names to apply. |
| `key_name` | `nil` | Name of an existing OpenStack keypair to inject. |
| `metadata` | `nil` | Hash of instance metadata. |
| `block_device_mapping` | `nil` | Hash describing a block device to boot from or attach. See [Block device mapping](#block-device-mapping). |
| `user_data` | *unset* | Path to a user data file passed to the instance. Cannot be combined with `cloud_config`. |
| `cloud_config` | *unset* | Inline cloud-init configuration. Cannot be combined with `user_data`. |

### Networking

| Option | Default | Description |
| --- | --- | --- |
| `openstack_network_name` | `nil` | Name of the network to attach to, and to take the instance's address from. |
| `network_ref` | `nil` | Network to attach, by name, ID, or an array of either, for multiple NICs. |
| `network_id` | `nil` | Network to attach, by exact ID. |
| `floating_ip` | `nil` | Specific floating IP to associate with the instance. |
| `floating_ip_pool` | `nil` | Pool to allocate a floating IP from. |
| `allocate_floating_ip` | `false` | Allocate a new floating IP, and release it again on destroy. |
| `use_ipv6` | `false` | Connect over the instance's IPv6 address. |
| `public_ip_order` | `0` | Index of the public address to use when the instance has several. |
| `private_ip_order` | `0` | Index of the private address to use when the instance has several. |
| `port` | `"22"` | SSH port to connect to. |

### Waiting and timeouts

| Option | Default | Description |
| --- | --- | --- |
| `server_wait` | *unset* | Seconds to sleep after the instance is active, before connecting. Useful when an image needs time to finish booting. |
| `no_ssh_tcp_check` | `false` | Skip the TCP check on the SSH port. Use when a firewall makes the check unreliable. |
| `no_ssh_tcp_check_sleep` | `120` | Seconds to sleep instead of checking, when `no_ssh_tcp_check` is enabled. |
| `glance_cache_wait_timeout` | `600` | Seconds to wait while Glance caches the image before the instance can boot. |
| `connect_timeout` | `60` | Seconds to wait when opening an API connection. |
| `read_timeout` | `60` | Seconds to wait for an API read. |
| `write_timeout` | `60` | Seconds to wait for an API write. |

### API and endpoints

| Option | Default | Description |
| --- | --- | --- |
| `openstack_region` | `$OS_REGION_NAME` | Region to operate in. |
| `openstack_service_name` | `nil` | Compute service name in the catalog, when the deployment uses a non-standard one. |
| `disable_ssl_validation` | `false` | Skip TLS certificate validation. Only use this against a deployment with an invalid certificate. |
| `openstack_cloud` | `nil` | Name of the cloud entry in `clouds.yaml`. Falls back to `OS_CLOUD`. |
| `clouds_yaml_path` | `nil` | Explicit path to a `clouds.yaml` file, inserted into the search path. |

## Block device mapping

`block_device_mapping` boots the instance from a volume rather than the image directly, or attaches an extra volume:

```yaml
driver:
  name: openstack
  image_ref: ubuntu-22.04
  flavor_ref: m1.small
  block_device_mapping:
    make_volume: true
    snapshot_id: 5e4e5d5e-1f1f-4b4b-9c9c-2d2d3e3e4f4f
    device_name: vda
    volume_size: 20
    volume_id: null
    availability_zone: nova
    delete_on_termination: true
```

## Examples

### Allocating a floating IP

```yaml
driver:
  name: openstack
  image_ref: ubuntu-22.04
  flavor_ref: m1.small
  key_name: my-keypair
  floating_ip_pool: public
  allocate_floating_ip: true
```

### Several networks

```yaml
driver:
  name: openstack
  image_ref: ubuntu-22.04
  flavor_ref: m1.small
  network_ref:
    - management
    - storage
  openstack_network_name: management
```

### cloud-init

```yaml
driver:
  name: openstack
  image_ref: ubuntu-22.04
  flavor_ref: m1.small
  cloud_config:
    packages:
      - htop
```

### A slow image

```yaml
driver:
  name: openstack
  image_ref: ubuntu-22.04
  flavor_ref: m1.small
  server_wait: 60
  glance_cache_wait_timeout: 1200
  no_ssh_tcp_check: true
```

### Per-platform images

```yaml
driver:
  name: openstack
  flavor_ref: m1.small
  key_name: my-keypair

platforms:
  - name: ubuntu-22.04
    driver:
      image_ref: ubuntu-22.04
  - name: rockylinux-9
    driver:
      image_ref: rocky-9
```

## Using with Chef

This driver is not tied to Cinc. The examples above use Cinc Workstation and the `cinc_infra` provisioner, but the
driver works exactly the same with [Chef Workstation](https://www.chef.io/downloads/tools/workstation) — run
`kitchen` instead of `cinc kitchen`, and use `chef_infra` instead of `cinc_infra`:

```yaml
provisioner:
  name: chef_infra

verifier:
  name: inspec
```

No driver configuration changes are needed.

## Contributing

Pull requests are very welcome on [GitHub](https://github.com/test-kitchen/kitchen-openstack). See
[CONTRIBUTING.md](CONTRIBUTING.md) for development setup, how to run the tests, and the release process.

## Authors

Created by Jonathan Hartman

## License

Apache 2.0 (see LICENSE.txt file)
