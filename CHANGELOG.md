# 1.2.0 / 2014-01-30

### New Features

* PR [#37][] - Support configurable security groups; via [@bears4barrett][]

# 1.1.0 / 2013-12-07

### Improvements

* Tested against, and working with, Test Kitchen 1.1.0

### Bug Fixes

* PR [#31][] - Fix collision with TK 1.x; change `name` option to `server_name`

# 1.0.0 / 2013-10-16

### New Features

* PR [#26][] - Support image and flavor names and regexes; via [@jgawor][]
* PR [#25][] - Support specific floating IPs, in addition to named pools
* PR [#14][] - Add support for floating IP pools; via [@hufman][]

### Improvements

* PR [#15][] - Improved SSH key support, support RSA and DSA; via [@hufman][]

### Bug Fixes

* PR [#27][] - Prevent IP contention in TK parallel mode; via [@jgawor][]

# 0.5.0 / 2013-09-23

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

[#37]: https://github.com/test-kitchen/kitchen-openstack/pull/37
[#31]: https://github.com/test-kitchen/kitchen-openstack/pull/31
[#27]: https://github.com/test-kitchen/kitchen-openstack/pull/27
[#26]: https://github.com/test-kitchen/kitchen-openstack/pull/26
[#25]: https://github.com/test-kitchen/kitchen-openstack/pull/25
[#20]: https://github.com/test-kitchen/kitchen-openstack/pull/20
[#19]: https://github.com/test-kitchen/kitchen-openstack/pull/19
[#15]: https://github.com/test-kitchen/kitchen-openstack/pull/15
[#14]: https://github.com/test-kitchen/kitchen-openstack/pull/14
[#12]: https://github.com/test-kitchen/kitchen-openstack/pull/12
[#11]: https://github.com/test-kitchen/kitchen-openstack/pull/11
[#10]: https://github.com/test-kitchen/kitchen-openstack/pull/10
[#9]: https://github.com/test-kitchen/kitchen-openstack/pull/9
[#7]: https://github.com/test-kitchen/kitchen-openstack/pull/7
[#2]: https://github.com/test-kitchen/kitchen-openstack/pull/2

[@bears4barrett]: https://github.com/bears4barrett
[@jgawor]: https://github.com/jgawor
[@hufman]: https://github.com/hufman
[@saketoba]: https://github.com/saketoba
[@stevendanna]: https://github.com/stevendanna
