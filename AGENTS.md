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
- Volume handling: `Kitchen::Driver::Openstack::Volume` in `lib/kitchen/driver/openstack/volume.rb`
- Version constant: `OPENSTACK_VERSION` in `lib/kitchen/driver/openstack_version.rb` — used by gemspec and release automation
- Configuration uses `default_config` declarations; raise `Kitchen::ActionFailed` for driver errors

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
