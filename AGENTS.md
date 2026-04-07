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
bundle exec rake          # runs tests + style + stats (default)
bundle exec rake test     # unit tests only (RSpec)
bundle exec rake style    # Cookstyle lint
bundle exec rake quality  # style + stats
```

## Conventions

- Use `Fog::OpenStack::Compute` and `Fog::OpenStack::Network` for cloud interactions
- Thread safety: use `Mutex` for shared resource pools (e.g., floating IP allocation)
- Resource finders (`find_image`, `find_flavor`, `find_network`) support regex matching via `/pattern/` syntax
- Test with RSpec 3 using `let` fixtures, `double` mocks, and `allow_any_instance_of` for Kitchen internals
- Release automation via Release Please — version bumps go in `lib/kitchen/driver/openstack_version.rb`
