# ?.?.? / ????-??-??

### Improvements

* PR [#19][] - Don't assume `public` and `private` network names exist
* PR [#19][] - Make IPv4 or IPv6 configurable instead of relying on Fog to pick

### Bug Fixes

* PR [#20][] - Limit generated hostnames to 64 characters

# 0.4.0 / 2013-06-06

### New Features

* PR [#12][] - Support `openstack_network_name` option; via [@saketoba][]
* PR [#11][] - Support `ssh_key` option; via [@saketoba][]

# 0.2.0 / 2013-05-11

### Bug Fixes

* PR [#7][] - `disable_ssl_validation` wasn't being respected on destroy

### New Features

* PR [#10][] - Support optional `openstack_region` and `openstack_service_name`
* PR [#2][] - Support `key_name:` option; via [@stevendanna][]

### Improvements

* PR [#7][] - Clean up/refactor to pass style checks
* PR [#9][] - Add some (probably overkill) RSpec tests

# 0.1.0 / 2013-03-12

* Initial release! Woo!

[#20]: https://github.com/RoboticCheese/kitchen-openstack/pull/20
[#19]: https://github.com/RoboticCheese/kitchen-openstack/pull/19
[#12]: https://github.com/RoboticCheese/kitchen-openstack/pull/12
[#11]: https://github.com/RoboticCheese/kitchen-openstack/pull/11
[#10]: https://github.com/RoboticCheese/kitchen-openstack/pull/10
[#9]: https://github.com/RoboticCheese/kitchen-openstack/pull/9
[#7]: https://github.com/RoboticCheese/kitchen-openstack/pull/7
[#2]: https://github.com/RoboticCheese/kitchen-openstack/pull/2

[@saketoba]: https://github.com/saketoba
[@stevendanna]: https://github.com/stevendanna
