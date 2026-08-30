# Contributing to kitchen-openstack

Pull requests are welcome. Please make sure your patches are tested.

This project is maintained by the [OSU Open Source Lab](https://osuosl.org/).

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

## Getting set up

```bash
git clone https://github.com/test-kitchen/kitchen-openstack
cd kitchen-openstack
bundle install
```

## Rake tasks

```bash
bundle exec rake             # tests + lint (default)
bundle exec rake test        # unit tests only
bundle exec rake integration # Test Kitchen suites against fog's mocks
bundle exec rake style       # Cookstyle lint
bundle exec rake yard        # render docs to doc/
bundle exec rake yard_stats  # list undocumented methods
```

`rake test` runs the `unit` task, and `rake quality` runs `style`. The default
task deliberately leaves `integration` out so that the common case stays fast;
CI runs it as its own job.

To run a single spec file:

```bash
bundle exec rspec spec/kitchen/driver/openstack_spec.rb
```

## How the tests work

Unit tests live in `spec/`, one file per file in `lib/`, and the whole suite
runs in well under a second. Nothing in it touches the network or the clock.

Nothing reads the filesystem outside a temp directory either, with one
deliberate exception: `spec/kitchen/driver/openstack_version_spec.rb` reads the
gemspec and the Release Please manifest to check that the version number agrees
in all four places it is written down. Those two examples skip themselves when
the files are not present.

Your own OpenStack setup cannot change the result. `ENV` is replaced with an
`OS_*`-free hash, and the `clouds.yaml` specs additionally pin `Dir.pwd`,
`Dir.home` and `/etc/openstack`, so a real `clouds.yaml` or `secure.yaml` on
your machine is never read — which also means a real password can never end up
in an RSpec diff.

Fog *model* objects use `instance_double`. Fog *service* objects cannot, because
Fog defines their methods dynamically at instantiation — `spec/support/fog_doubles.rb`
explains this.

Coverage instrumentation is off by default so a single-file run stays fast. Use
`bundle exec rake coverage` (or set `COVERAGE=1`) to write a report to
`coverage/`; CI always collects it. It is informational and never fails the run.

## Documentation

`lib/` is documented with YARD. `bundle exec rake yard_stats` lists anything
undocumented. Neither is enforced in CI, but new methods should come with docs.

When you add or change a configuration option, update the configuration
reference in `README.md` as well.

## Integration tests

`bundle exec rake integration` runs the suites in `kitchen.yml` through Test
Kitchen itself. They need no credentials and no OpenStack deployment:
`test/fog_mock.rb` puts Fog into mock mode before the driver is loaded, so
`create` and `destroy` run their real code against fog-openstack's in-memory
Nova, Neutron and Cinder.

Fog has to be mocked before Test Kitchen instantiates the driver, which is why
the rake task requires the file ahead of the `kitchen` executable rather than
doing it from `kitchen.yml`:

```bash
bundle exec ruby -Itest -r fog_mock -S kitchen test
bundle exec ruby -Itest -r fog_mock -S kitchen test network-ref-cirros
bundle exec ruby -Itest -r fog_mock -S kitchen diagnose --all
```

What this catches that the unit tests cannot: the driver failing to load or
register, a Driver API version mismatch, a file missing from the gemspec, a
config key that no longer survives `finalize_config!`, and any exception on the
real create/destroy path — each of which the unit tests can miss because they
never go through Test Kitchen's own plugin loading and instance lifecycle.

What it cannot catch: anything only a real cloud decides. Quotas, scheduling,
whether the image actually boots, real networking, and SSH are all outside a
mock. There is no way to run those in hosted CI — they need a live OpenStack —
so they stay a manual step, below.

A few paths are not covered as suites because fog's mocks do not model them:
allocating a *new* floating IP (the mock's response carries no address),
Cinder volumes (mock volumes never reach `available`), and reading an address
back off a named network (mock servers are not attached to the mock networks).
Those are covered by the unit tests, and by the manual pass.

## Manual testing

The tests above never contact a cloud, so changes that touch instance creation,
networking, or credential resolution should also be exercised against a real
OpenStack deployment.

Worth exercising separately, since they take different paths:

- **each credential source** — `clouds.yaml`, `OS_*` environment variables, and
  explicit `kitchen.yml` options, including the precedence between them
- **floating IPs**, both `allocate_floating_ip` and a pre-existing `floating_ip`
- **multiple networks**, via `network_ref`

Confirm after `kitchen destroy` that no instances remain, and that any floating
IP allocated by the run was released.

## Opening a pull request

1. Fork the repo
2. Create a topic branch (`git checkout -b my-new-feature`)
3. Make your change, with tests
4. Run `bundle exec rake`
5. Push and open a pull request

Please keep pull requests focused on a single change — it makes review much
faster.

## Release process

Releases are handled by the maintainers.

1. Update `lib/kitchen/driver/openstack_version.rb` with the new version.
2. Update `CHANGELOG.md`.
3. Merge to `main`; the publish workflow builds the gem and pushes it to
   RubyGems.
