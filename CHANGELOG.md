# 2.1.0.pre / 2015-XX-XX

### New Features

* PR [#106][] - The ability to bootstrap on only a private network paired with [@thomascate][] and [@BobbyRyterski][]

### Bug Fixes

* PR [#106][] - Updated the README with better formatting

# 2.0.0 / 2015-09-30

### New Features

* Windows and WinRM support
* Re-written for the new test-kitchen [1.4](http://kitchen.ci/blog/test-kitchen-1-4-0-release-notes/)

### Bug Fixes

* PR [#80][] - Stole some code from [@jmahowald][]
* PR [#96][] - Resolve for issue PR
* PR [#100][] - Don't create instance if name is already created - from [@dpetzel][]
* PR [#99][] - Load openstack_version for plugin_version  - from [@BobbyRyterski][]
* PR [#98][] - Support all Fog OpenStack options PR [#98][] - from [@BobbyRyterski][]
* PR [#104][] - Fix for ohai running hint not running as root - from [@spion06][]

### Improvements

* PR [#102][] - Updates to the readme - from [@BobbyRyterski][]

# 1.8.1 / 2015-07-22

### Bug Fixes

* PR [#88][] - Fail immediately and with a more understandable message if
  required SSH configs can't be found

# 1.8.0 / 2015-04-08

### New Features

* PR [#74][] - Support attaching block storage volumes; via [@LiamHaworth][]

# 1.7.1 / 2015-01-07

* PR [#70][] - Use configured password for SSH access, if provided

# 1.7.0 / 2014-10-25

### New Features

* PR [#66][] - Allow setting a timed sleep for SSH check edge cases
* PR [#63][] - Add support for a static server name prefix; via [@ftclausen][]
* PR [#62][] - Add availability zone support; via [@fortable1999][]

# 1.6.1 / 2014-10-07

### Bug Fixes

* PR [#60][] - Resolve method name conflict with Kitchen::Configurable; via
[@stevejmason][]

# 1.6.0 / 2014-09-04

### Improvements

* PR [#56][] - Fall back to the first valid IP if no public or private nets can
be found; via [@jer][]
* PR [#55][] - Give a floating IP priority over an IP pool if both are present;
via [@StaymanHou][]

### Bug Fixes

* PR [#58][] - Prevent errors when run without a login shell

# 1.5.3 / 2014-08-01

* PR [#53][] - Rework how server names are generated, disallowing possibly
error-causing punctuation in resultant names

# 1.5.2 / 2014-05-31

### Bug Fixes

* PR [#50][] - Fix possible infinite loop when generating server names
* PR [#49][] - Limit server names to 63 characters to get around OpenSSH bug
[2239](https://bugzilla.mindrot.org/show_bug.cgi?id=2239); via [@dschlenk][]

# 1.5.0 / 2014-05-22

### New Features

* PR [#48][] - Enable the Ohai OpenStack plugin; via [@dschlenk][]

# 1.4.0 / 2014-04-09

### Improvements

* PR [#46][] - Use a configured floating IP for SSH; via [@dschlenk][]

# 1.3.0 / 2014-03-09

### New Features

* PR [#40][] - New `user_data` option; via [@wilreichert][]
* PR [#39][] - New `network_ref` option to only provision a server with
certain specified NICs; via [@monsterzz][]

### Bug Fixes

* PR [#41][] - Fix issue creating servers with custom SSH ports; via
[@tenforward][]

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


[#106]: https://github.com/test-kitchen/kitchen-openstack/pull/106
[#104]: https://github.com/test-kitchen/kitchen-openstack/pull/104
[#102]: https://github.com/test-kitchen/kitchen-openstack/pull/102
[#100]: https://github.com/test-kitchen/kitchen-openstack/pull/100
[#99]: https://github.com/test-kitchen/kitchen-openstack/pull/99
[#98]: https://github.com/test-kitchen/kitchen-openstack/pull/98
[#96]: https://github.com/test-kitchen/kitchen-openstack/pull/96
[#88]: https://github.com/test-kitchen/kitchen-openstack/pull/88
[#80]: https://github.com/test-kitchen/kitchen-openstack/pull/80
[#74]: https://github.com/test-kitchen/kitchen-openstack/pull/74
[#70]: https://github.com/test-kitchen/kitchen-openstack/pull/70
[#66]: https://github.com/test-kitchen/kitchen-openstack/pull/66
[#63]: https://github.com/test-kitchen/kitchen-openstack/pull/63
[#62]: https://github.com/test-kitchen/kitchen-openstack/pull/62
[#60]: https://github.com/test-kitchen/kitchen-openstack/pull/60
[#58]: https://github.com/test-kitchen/kitchen-openstack/pull/58
[#56]: https://github.com/test-kitchen/kitchen-openstack/pull/56
[#55]: https://github.com/test-kitchen/kitchen-openstack/pull/55
[#53]: https://github.com/test-kitchen/kitchen-openstack/pull/53
[#50]: https://github.com/test-kitchen/kitchen-openstack/pull/50
[#49]: https://github.com/test-kitchen/kitchen-openstack/pull/49
[#48]: https://github.com/test-kitchen/kitchen-openstack/pull/48
[#46]: https://github.com/test-kitchen/kitchen-openstack/pull/46
[#41]: https://github.com/test-kitchen/kitchen-openstack/pull/41
[#40]: https://github.com/test-kitchen/kitchen-openstack/pull/40
[#39]: https://github.com/test-kitchen/kitchen-openstack/pull/39
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

[@thomascate]: https://github.com/thomascate
[@jmahowald]: https://github.com/jmahowald
[@dpetzel]: https://github.com/dpetzel
[@BobbyRyterski]: https://github.com/BobbyRyterski
[@spion06]: https://github.com/spion06
[@LiamHaworth]: https://github.com/LiamHaworth
[@ftclausen]: https://github.com/ftclausen
[@fortable1999]: https://github.com/fortable1999
[@stevejmason]: https://github.com/stevejmason
[@StaymanHou]: https://github.com/StaymanHou
[@jer]: https://github.com/jer
[@dschlenk]: https://github.com/dschlenk
[@wilreichert]: https://github.com/wilreichert
[@tenforward]: https://github.com/tenforward
[@monsterzz]: https://github.com/monsterzz
[@bears4barrett]: https://github.com/bears4barrett
[@jgawor]: https://github.com/jgawor
[@hufman]: https://github.com/hufman
[@saketoba]: https://github.com/saketoba
[@stevendanna]: https://github.com/stevendanna
