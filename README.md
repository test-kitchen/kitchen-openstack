# kitchen-openstack

![Gem Version](https://img.shields.io/gem/v/kitchen-openstack.svg)
![CI](https://github.com/test-kitchen/kitchen-openstack/actions/workflows/lint.yml/badge.svg)

A [Test Kitchen](https://kitchen.ci/) driver for OpenStack.

Test Kitchen builds a throwaway machine, converges your configuration code on
it, runs your tests, and destroys it. This driver makes that throwaway machine
a Nova instance in an OpenStack cloud, so you can test against the same
platform you deploy to.

Maintained by the [OSU Open Source Lab](https://osuosl.org/).

> This documentation uses [Cinc Workstation](https://cinc.sh/) and the `cinc`
> commands throughout. Everything here works identically with Chef Workstation —
> see [Using with Chef](#using-with-chef).

---

## Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Authentication](#authentication)
- [Configuration reference](#configuration-reference)
- [Common setups](#common-setups)
- [Troubleshooting](#troubleshooting)
- [Using with Chef](#using-with-chef)
- [Contributing](#contributing)

---

## Requirements

- Ruby 3.1 or newer
- Access to an OpenStack cloud, and credentials for it
- An SSH keypair uploaded to that cloud (Nova calls this a "keypair"; you
  reference it by name as `key_name`)

There are no other system requirements. The driver talks to OpenStack over
HTTPS using the [fog-openstack](https://github.com/fog/fog-openstack) library.

## Installation

This driver ships with [Cinc
Workstation](https://cinc.sh/start/workstation/), which is the simplest way to
get Test Kitchen and its plugins in one package. It also ships with
[Chef Workstation](https://www.chef.io/downloads/tools/workstation).

To install it yourself, add it to your `Gemfile`:

```ruby
gem "kitchen-openstack"
```

then `bundle install`. Or install the gem directly:

```bash
gem install kitchen-openstack
```

Confirm Test Kitchen can see it:

```bash
cinc kitchen driver discover | grep openstack
```

## Quick start

This walks from nothing to a running instance. It assumes you already have a
project with a `kitchen.yml`.

### 1. Get your credentials into your shell

If you use the `openstack` CLI, you already have what you need. Most clouds
give you an `openrc` file to source, or a `clouds.yaml` in
`~/.config/openstack/`. Either works — this driver reads both, the same way
the CLI does:

```bash
source openrc.sh          # sets OS_AUTH_URL, OS_USERNAME, OS_PASSWORD, ...
# or
export OS_CLOUD=mycloud   # selects an entry from your existing clouds.yaml
```

Check that it works before involving Test Kitchen:

```bash
openstack server list
```

If that fails, fix it first. Test Kitchen will fail the same way, with less
helpful output.

### 2. Find an image and a flavor

You need to tell the driver what to boot and how big:

```bash
openstack image list
openstack flavor list
openstack keypair list
```

### 3. Write your `kitchen.yml`

```yaml
---
driver:
  name: openstack
  image_ref: ubuntu-24.04       # name, ID, or /regex/
  flavor_ref: m1.small
  key_name: my-keypair          # a keypair already uploaded to OpenStack

transport:
  username: ubuntu              # the image's default login user
  ssh_key: ~/.ssh/my-keypair    # the *private* half of key_name

provisioner:
  name: cinc_infra

verifier:
  name: inspec

platforms:
  - name: ubuntu-24.04

suites:
  - name: default
```

Two things new users most often get wrong here:

- **`username` and `ssh_key` go under `transport:`, not `driver:`.** The driver
  creates the machine; the transport logs into it. They are separate.
- **`key_name` is the name OpenStack knows; `ssh_key` is the private key file
  on your disk.** They must be two halves of the same pair.

### 4. Run it

```bash
cinc kitchen create      # boot the instance
cinc kitchen converge    # apply your configuration code
cinc kitchen verify      # run your tests
cinc kitchen destroy     # tear it down

cinc kitchen test        # all four, from scratch
```

`cinc kitchen list` shows the state of each suite. If something goes wrong, jump to
[Troubleshooting](#troubleshooting).

## Authentication

You can supply credentials three ways. You do not need to pick one globally —
they layer, and the precedence is fixed:

1. **`kitchen.yml`** — anything set explicitly here always wins
2. **`OS_*` environment variables** — override `clouds.yaml`
3. **`clouds.yaml`** (merged with `secure.yaml`) — the base

This is the order the upstream OpenStack SDK uses, so it should match what the
`openstack` CLI does.

### Using `clouds.yaml` (recommended)

OpenStack's standard
[`clouds.yaml`](https://docs.openstack.org/python-openstackclient/latest/configuration/index.html)
keeps credentials in one place shared by every OpenStack tool. If you have one,
use it — there is nothing to copy into `kitchen.yml`.

The driver searches these locations and uses the first file it finds:

1. `$OS_CLIENT_CONFIG_FILE`
2. the `clouds_yaml_path` driver option
3. `./clouds.yaml`
4. `~/.config/openstack/clouds.yaml`
5. `/etc/openstack/clouds.yaml`

A `secure.yaml` is searched for in the same locations — with
`$OS_CLIENT_SECURE_FILE` in place of `$OS_CLIENT_CONFIG_FILE` — and merged on
top, so you can keep secrets in a separate file following the [standard
convention](https://docs.openstack.org/openstacksdk/latest/user/config/configuration.html#splitting-secrets).

Select which cloud entry to use with either `OS_CLOUD` or the
`openstack_cloud` driver option:

```yaml
driver:
  name: openstack
  openstack_cloud: mycloud
  image_ref: ubuntu-24.04
  flavor_ref: m1.small
  key_name: my-keypair
```

Because `kitchen.yml` wins, you can adopt a cloud entry and override one piece
of it:

```yaml
driver:
  name: openstack
  openstack_cloud: mycloud
  openstack_region: RegionTwo   # everything else still comes from clouds.yaml
```

### Using `OS_*` environment variables

Sourcing an `openrc` file is enough on its own:

```bash
source openrc.sh
```

```yaml
driver:
  name: openstack
  image_ref: ubuntu-24.04
  flavor_ref: m1.small
  key_name: my-keypair
```

Recognized variables:

| Environment variable | Driver option |
| --- | --- |
| `OS_CLOUD` | `openstack_cloud` |
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

An exported-but-empty variable is ignored, so `OS_REGION_NAME=""` will not
shadow a region set in `clouds.yaml`.

### Putting credentials in `kitchen.yml`

Supported, but avoid committing secrets. Prefer reading them from the
environment:

```yaml
driver:
  name: openstack
  openstack_username: <%= ENV["OS_USERNAME"] %>
  openstack_api_key: <%= ENV["OS_PASSWORD"] %>
  openstack_auth_url: https://keystone.example.com:5000/v3
  openstack_domain_id: default
  openstack_project_name: my-project
```

### Application credentials

Preferred over a password where your cloud supports them:

```yaml
driver:
  name: openstack
  openstack_auth_url: https://keystone.example.com:5000/v3
  openstack_application_credential_id: <%= ENV["OS_APPLICATION_CREDENTIAL_ID"] %>
  openstack_application_credential_secret: <%= ENV["OS_APPLICATION_CREDENTIAL_SECRET"] %>
```

## Configuration reference

Everything below goes under `driver:` in `kitchen.yml`.

### Choosing what to boot

| Option | Default | Description |
| --- | --- | --- |
| `image_ref` | — | Image to boot, by name, ID, or `/regex/`. Mutually exclusive with `image_id`. |
| `image_id` | — | Image UUID, used verbatim with no lookup. |
| `flavor_ref` | — | Flavor, by name, ID, or `/regex/`. Mutually exclusive with `flavor_id`. |
| `flavor_id` | — | Flavor UUID, used verbatim with no lookup. |
| `key_name` | `nil` | Name of an SSH keypair already uploaded to OpenStack. |
| `availability_zone` | `nil` | Availability zone to boot into. |
| `security_groups` | `nil` | List of security group names. **Must be a list**, even for one group. |
| `metadata` | `nil` | Hash of Nova instance metadata. |

Set exactly one of `image_ref`/`image_id`, and exactly one of
`flavor_ref`/`flavor_id`. Setting both members of a pair is an error.

The `_ref` options accept three forms:

```yaml
image_ref: 8a8c0f4d-...        # exact ID (checked first)
image_ref: ubuntu-24.04        # exact name
image_ref: /^ubuntu-24\.04/    # regex, first match wins
```

### Naming the instance

| Option | Default | Description |
| --- | --- | --- |
| `server_name` | generated | Exact instance name. Overrides everything below. |
| `server_name_prefix` | `nil` | Prefix, plus a random 8-character suffix. |

With neither set, the name is `<suite-platform>-<user>-<host>-<random>`,
truncated to OpenStack's 63-character limit. Non-word characters are stripped.

### Networking

| Option | Default | Description |
| --- | --- | --- |
| `network_ref` | `nil` | Network(s) to attach, by name, ID, or `/regex/`. A string or a list. Mutually exclusive with `network_id`. |
| `network_id` | `nil` | Network UUID(s), used verbatim. A string or a list. |
| `openstack_network_name` | `nil` | Which network's address Test Kitchen should connect to. |
| `floating_ip` | `nil` | A specific floating IP to attach. |
| `floating_ip_pool` | `nil` | Pool (external network) to take a floating IP from. |
| `allocate_floating_ip` | `false` | Allocate a *new* floating IP rather than reusing a free one. Released on `destroy`. |
| `public_ip_order` | `0` | Index into the public addresses when several exist. |
| `private_ip_order` | `0` | Index into the private addresses when several exist. |
| `use_ipv6` | `false` | Connect over IPv6 instead of IPv4. |

Address selection, in order: `floating_ip` if set, then
`openstack_network_name` if set, then the public addresses at
`public_ip_order`, then the private addresses at `private_ip_order`.

### Storage

| Option | Default | Description |
| --- | --- | --- |
| `block_device_mapping` | `nil` | Boot from, or attach, a Cinder volume. See [below](#booting-from-a-volume). |

### Instance customization

| Option | Default | Description |
| --- | --- | --- |
| `user_data` | `nil` | Path to a cloud-init file. **Must exist**, or `create` fails. |
| `cloud_config` | `nil` | Inline cloud-config as YAML, rendered for you. Mutually exclusive with `user_data`. |
| `config_drive` | `nil` | Attach a config drive. |

### Connection and timeouts

| Option | Default | Description |
| --- | --- | --- |
| `connect_timeout` | `60` | Seconds to wait establishing an API connection. |
| `read_timeout` | `60` | Seconds to wait reading an API response. |
| `write_timeout` | `60` | Seconds to wait writing an API request. |
| `glance_cache_wait_timeout` | `600` | Seconds to wait for the instance to reach `ACTIVE`. Raise it if your cloud caches images slowly on first boot. |
| `server_wait` | `nil` | Extra seconds to sleep after boot before trying SSH. A blunt instrument; try it if your instances need a moment before accepting connections. |
| `disable_ssl_validation` | `false` | Skip TLS verification. Prefer `ssl_ca_file`. |
| `ssl_ca_file` | `nil` | Path to a CA bundle, passed to the HTTP connection. Set by `OS_CACERT` or a `cacert` entry in `clouds.yaml`. |

### Credentials and endpoints

| Option | Default | Description |
| --- | --- | --- |
| `openstack_cloud` | `nil` | Cloud entry to read from `clouds.yaml`. Falls back to `OS_CLOUD`. |
| `clouds_yaml_path` | `nil` | Explicit `clouds.yaml` path, inserted into the search path. |
| `openstack_auth_url` | `nil` | Keystone endpoint. |
| `openstack_username` | `nil` | Username. |
| `openstack_api_key` | `nil` | Password. |
| `openstack_project_name` | `nil` | Project (tenant) name. |
| `openstack_project_id` | `nil` | Project ID. |
| `openstack_domain_id` | `nil` | Domain ID. Usually `default`. |
| `openstack_domain_name` | `nil` | Domain name. |
| `openstack_user_domain` | `nil` | User domain name. |
| `openstack_user_domain_id` | `nil` | User domain ID. |
| `openstack_project_domain` | `nil` | Project domain name. |
| `openstack_project_domain_id` | `nil` | Project domain ID. |
| `openstack_region` | `nil` | Region name. |
| `openstack_endpoint_type` | `nil` | Endpoint interface: `public`, `internal`, or `admin`. |
| `openstack_identity_api_version` | `nil` | Keystone API version. |
| `openstack_service_name` | `nil` | Compute service name. |
| `openstack_application_credential_id` | `nil` | Application credential ID. |
| `openstack_application_credential_secret` | `nil` | Application credential secret. |
| `openstack_tenant` | `nil` | Tenant name. The Keystone v2 name for a project; use `openstack_project_name` on v3. |
| `openstack_tenant_id` | `nil` | Tenant ID. The Keystone v2 name for a project ID. |
| `openstack_service_type` | `nil` | Compute service type to look up in the catalog. |

Any other `openstack_*` option that fog-openstack recognizes is forwarded as
well, including `openstack_auth_token`, `openstack_identity_endpoint`,
`openstack_management_url`, and `openstack_cache_ttl`. To see the full list
your installed version supports:

```bash
ruby -r fog/openstack -e 'puts Fog::OpenStack::Compute.recognized.grep(/^openstack/).sort'
```

### Settings that are not driver options

Commonly mistaken for driver options:

- **`username`, `ssh_key`, `port`, `connection_timeout`** belong under
  `transport:`. The driver builds the instance; the transport connects to it.
- **`no_ssh_tcp_check` and `no_ssh_tcp_check_sleep`** are accepted but have no
  effect. They are leftovers from an earlier version and are not read anywhere
  in the driver.
- **`pre_create_command`** is declared by Test Kitchen's base driver, but this
  driver overrides `create` without invoking it, so setting it does nothing
  here.

## Common setups

### Attaching a floating IP

Reuse an already-allocated but unattached address from a pool:

```yaml
driver:
  name: openstack
  floating_ip_pool: public
```

Or allocate a fresh one, which is released again on `kitchen destroy`:

```yaml
driver:
  name: openstack
  floating_ip_pool: public
  allocate_floating_ip: true
```

Or pin a specific address:

```yaml
driver:
  name: openstack
  floating_ip: 203.0.113.10
```

### Choosing a network

```yaml
driver:
  name: openstack
  network_ref: my-private-net           # name, ID, or /regex/
```

Attach several:

```yaml
driver:
  name: openstack
  network_ref:
    - my-private-net
    - my-storage-net
  openstack_network_name: my-private-net   # which one to connect over
```

### Running cloud-init

Inline, which is usually easier to read:

```yaml
driver:
  name: openstack
  cloud_config:
    packages:
      - htop
    runcmd:
      - [systemctl, restart, sshd]
```

Or from a file, which must exist:

```yaml
driver:
  name: openstack
  user_data: files/cloud-init.yml
```

### Booting from a volume

```yaml
driver:
  name: openstack
  block_device_mapping:
    make_volume: true
    volume_size: 20
    device_name: vda
    delete_on_termination: true
    creation_timeout: 60      # seconds to wait for the volume to be available
    attach_timeout: 5         # extra seconds before attaching
```

`make_volume: true` creates a new volume; source it from `snapshot_id`,
`imageRef`, or `source_volid`. To attach a volume you already have, drop
`make_volume` and give `volume_id`.

### A cloud with a private CA

Point at your CA bundle rather than turning verification off:

```bash
export OS_CACERT=/etc/ssl/certs/my-ca.pem
```

or in `clouds.yaml`:

```yaml
clouds:
  mycloud:
    cacert: /etc/ssl/certs/my-ca.pem
```

Either is passed through to the HTTP connection. `verify: false` in
`clouds.yaml` disables verification entirely, equivalent to setting
`disable_ssl_validation: true`.

## Troubleshooting

Start with `kitchen diagnose`, which prints the fully resolved driver config
after `clouds.yaml` and `OS_*` have been merged in. If a credential is not
there, the driver never saw it.

```bash
kitchen diagnose --all
kitchen create --log-level=debug
```

| Symptom | Likely cause |
| --- | --- |
| `Image not found` / `Flavor not found` | The `_ref` matched nothing. Check `openstack image list`. A `/regex/` needs the surrounding slashes. |
| `Cannot specify both image_ref and image_id` | Set one, not both. Same for flavor and network. |
| `Could not find an IP` | The instance has no address of the family you asked for. Check `use_ipv6`, and whether you need a floating IP. |
| `Server is not attached to network <name>` | `openstack_network_name` does not match any network on the instance. |
| `Floating IP pool <name> not found` | The pool name is wrong; it is the external *network* name. |
| `No available IPs in pool <name>` | Every address is in use. Set `allocate_floating_ip: true` to make a new one. |
| `The user_data file <path> does not exist` | The path is wrong. It is resolved relative to where you run `kitchen`. |
| `The security_groups config must be an array` | Use a list, even for a single group. |
| Hangs at "Waiting for server to be ready" | The instance booted but SSH is unreachable. Check the security group allows port 22, that a floating IP is attached if you need one, and that `transport: username:` matches the image's default user. |
| Times out reaching `ACTIVE` | Raise `glance_cache_wait_timeout`. First boot of a large image can be slow. |
| TLS errors | Set `ssl_ca_file` (or `OS_CACERT`) to your CA bundle. |

The instance is destroyed automatically if it never becomes reachable, so a
failed `kitchen create` should not leak a server. If one does leak, `kitchen
destroy` or `openstack server delete` will clear it.

## Using with Chef

This driver is not tied to Cinc. The examples above use Cinc Workstation and the
`cinc_infra` provisioner, but the driver works exactly the same with
[Chef Workstation](https://www.chef.io/downloads/tools/workstation) — run
`kitchen` instead of `cinc kitchen`, and use `chef_infra` instead of
`cinc_infra`:

```yaml
provisioner:
  name: chef_infra

verifier:
  name: inspec
```

No driver configuration changes are needed.

## Contributing

Pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for
development setup, how to run the tests, how the suite is built, and the
release process.

## Credits

Originally created by Jonathan Hartman.

Structure borrowed from [Fletcher Nichol](https://github.com/fnichol)'s
[kitchen-ec2](https://github.com/test-kitchen/kitchen-ec2) and [Adam
Leff](https://github.com/adamleff)'s
[kitchen-vro](https://github.com/chef-partners/kitchen-vro).

Further reference documentation is at
<https://kitchen.ci/docs/drivers/openstack/>.

## License

Apache 2.0. See [LICENSE.txt](LICENSE.txt).
