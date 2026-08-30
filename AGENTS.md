# Project Guidelines

## Overview

kitchen-openstack is a Test Kitchen driver for OpenStack. It provisions and destroys Nova instances using the Fog OpenStack library.

## Code Style

- Ruby 3.1+ required
- All files must start with `# frozen_string_literal: true`
- Follow Cookstyle (Chef's RuboCop) conventions — config in `.rubocop.yml`
- Spec files are excluded from linting

## Architecture

- Driver class: `Kitchen::Driver::Openstack` in `lib/kitchen/driver/openstack.rb` — extends `Kitchen::Driver::Base` (Driver API v2)
- Clouds.yaml support: `Kitchen::Driver::Openstack::Clouds` in `lib/kitchen/driver/openstack/clouds.rb` — parses OpenStack `clouds.yaml`/`secure.yaml` and translates to Fog config
- Server configuration: `Kitchen::Driver::Openstack::Config` in `lib/kitchen/driver/openstack/config.rb` — server naming helpers
- Helpers: `Kitchen::Driver::Openstack::Helpers` in `lib/kitchen/driver/openstack/helpers.rb` — ohai hints, SSL, server wait
- Networking: `Kitchen::Driver::Openstack::Networking` in `lib/kitchen/driver/openstack/networking.rb` — floating IP allocation, IP resolution
- Server creation: `Kitchen::Driver::Openstack::ServerHelper` in `lib/kitchen/driver/openstack/server_helper.rb` — server creation, image/flavor/network finders
- Volume handling: `Kitchen::Driver::Openstack::Volume` in `lib/kitchen/driver/openstack/volume.rb`
- Version constant: `OPENSTACK_VERSION` in `lib/kitchen/driver/openstack_version.rb` — used by gemspec and release automation
- Configuration uses `default_config` declarations; raise `Kitchen::ActionFailed` for driver errors
- Supports `clouds.yaml` via `openstack_cloud` config or `OS_CLOUD` env var — see `Clouds` module

## Build and Test

```bash
bundle install
bundle exec rake             # runs tests + style (default)
bundle exec rake test        # unit tests only (RSpec)
bundle exec rake integration # Test Kitchen suites against fog-openstack mocks
bundle exec rake style       # Cookstyle lint
bundle exec rake quality     # style
bundle exec rake yard        # render YARD docs to doc/ (not CI-gated)
bundle exec rake yard_stats  # list undocumented methods
```

## Conventions

- Use `Fog::OpenStack::Compute` and `Fog::OpenStack::Network` for cloud interactions
- Thread safety: use `Mutex` for shared resource pools (e.g., floating IP allocation)
- Resource finders (`find_image`, `find_flavor`, `find_network`) support regex matching via `/pattern/` syntax
- Every method in `lib/` carries YARD tags (`@param`/`@return`/`@raise`). Keep new ones documented; `rake yard_stats` reports gaps but nothing enforces it
- Specs mirror `lib/` one-to-one: `spec/kitchen/driver/openstack/<module>_spec.rb`
- Shared spec setup lives in `spec/support/`: the `"with a configured driver"` shared context builds the driver and stubs `instance`; `FogDoubles` builds the Fog stand-ins
- `verify_partial_doubles` is on. Fog *model* classes take `instance_double`; Fog *service* objects cannot, because Fog defines their methods dynamically at instantiation
- Unit tests never sleep, hit the network, or read outside a `Dir.mktmpdir`. The one exemption is `openstack_version_spec.rb`, which reads the gemspec and the Release Please manifest to catch version drift, and skips when they are absent. `ENV` is replaced with an `OS_*`-free hash, and the clouds.yaml specs additionally pin `Dir.pwd`, `Dir.home` and `/etc/openstack`, so neither a developer's OpenStack environment nor their real `clouds.yaml`/`secure.yaml` can leak in
- Integration suites live in `kitchen.yml` and run against fog-openstack's mock backend; `test/fog_mock.rb` must be required before the `kitchen` executable (`ruby -Itest -r fog_mock -S kitchen test`). No credentials or cloud needed
- Release automation via Release Please — version bumps go in `lib/kitchen/driver/openstack_version.rb`
