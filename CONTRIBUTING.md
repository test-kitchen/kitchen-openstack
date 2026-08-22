# Contributing to kitchen-openstack

Thanks for your interest in improving kitchen-openstack. Bug reports, feature requests, and pull requests are all welcome.

This project is actively maintained by the [OSU Open Source Lab](https://osuosl.org/).

## Reporting issues

Report bugs and request features on the [issue tracker](https://github.com/test-kitchen/kitchen-openstack/issues). For bugs, please include:

- the version of kitchen-openstack and Test Kitchen you are using
- your OpenStack release, and which services are involved
- your `kitchen.yml` with credentials and endpoints removed
- the output of the failing command, ideally with `-l debug`

`kitchen diagnose` is useful here: the driver merges `clouds.yaml` values into
its config during `finalize_config!`, so diagnose shows the settings actually in
effect after `clouds.yaml`, the `OS_*` environment variables, and `kitchen.yml`
have been combined.

## Development setup

Clone the repository and install the dependencies:

```sh
git clone https://github.com/test-kitchen/kitchen-openstack.git
cd kitchen-openstack
bundle install
```

## Running the tests

```sh
bundle exec rake spec      # RSpec unit tests
bundle exec rake rubocop   # Cookstyle / RuboCop
```

To run a single spec file:

```sh
bundle exec rspec spec/kitchen/driver/openstack_spec.rb
```

Many style offenses can be corrected automatically:

```sh
bundle exec cookstyle -a
```

The unit tests stub Fog, so they neither build instances nor require an
OpenStack account.

## Manual testing

Changes that touch instance creation, networking, or credential resolution
should also be exercised against a real cloud, since the stubbed tests cannot
catch API-level regressions.

Worth exercising separately, since they take different paths:

- **each credential source** — `clouds.yaml`, `OS_*` environment variables, and
  explicit `kitchen.yml` options, including the precedence between them
- **floating IPs**, both `allocate_floating_ip` and a pre-existing `floating_ip`
- **multiple networks**, via `network_ref`

Confirm after `kitchen destroy` that no instances remain, and that any floating
IP allocated by the run was released.

## Submitting changes

1. Fork the repository.
2. Create a feature branch off `main`.
3. Make your change, adding or updating tests to cover it.
4. Run the tests and the linter: `bundle exec rake spec` and
   `bundle exec rake rubocop`.
5. Push the branch to your fork and open a pull request.

Please keep pull requests focused on a single change — it makes review much
faster. Update the documentation in `README.md` when you add or change a
configuration option.

## Release process

Releases are handled by the maintainers.

1. Update `lib/kitchen/driver/openstack_version.rb` with the new version.
2. Update `CHANGELOG.md`.
3. Merge to `main`; the publish workflow builds the gem and pushes it to
   RubyGems.
