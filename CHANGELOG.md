# Change Log

## [v6.0.0](https://github.com/test-kitchen/kitchen-openstack/tree/v6.0.0)

- Require Ruby 2.6 or later and add testing for Ruby 3.0
- Add a new `cloud_config` option which allows you to pass data to cloud-init. See https://github.com/test-kitchen/kitchen-openstack#cloud_config for usage information. Thanks [@JimScadden](https://github.com/JimScadden)

## [v5.0.1](https://github.com/test-kitchen/kitchen-openstack/tree/v5.0.1)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v5.0.0..v5.0.1)

- Switched to GitHub Actions for PR testing
- Resolved fog deprecation warnings when running the plugin
- Removed the unused `unf` gem dependency

## [v5.0.0](https://github.com/test-kitchen/kitchen-openstack/tree/v5.0.0)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v4.0.0..v5.0.0)

- Added functionality to delay attaching a volume after its marked active when configuring block device mapping. This addresses an issue in VMWare Openstack (VIO) that may be present in others when attaching large volumes in which VIO would mark the device active but was still performing operations which caused test kitchen to fail.
- Require fog-openstack 1.X instead of Fog < 1, which greatly reduces the total dependencies necessary. This may require updating other tools to support fog 1.x, which has breaking changes.
- Only ship the necessary files in the gem to slim the size of the gem install slightly

## [v4.0.0](https://github.com/test-kitchen/kitchen-openstack/tree/v4.0.0)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.6.2..v4.0.0)

- Loosen the Test Kitchen dependency to allow for 2.x
- Fix minor style issues in the code

## [v3.6.2](https://github.com/test-kitchen/kitchen-openstack/tree/v3.6.2)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.6.1...v3.6.2)

**Merged pull requests:**

- Fall back on Etc.getlogin for windows environments [\#186](https://github.com/test-kitchen/kitchen-openstack/pull/186) ([joshuariojas](https://github.com/joshuariojas))
- Update Travis to the latest ruby releases [\#185](https://github.com/test-kitchen/kitchen-openstack/pull/185) ([tas50](https://github.com/tas50))
- Getting travis green. [\#184](https://github.com/test-kitchen/kitchen-openstack/pull/184) ([jjasghar](https://github.com/jjasghar))

## [v3.6.1](https://github.com/test-kitchen/kitchen-openstack/tree/v3.6.1) (2018-06-06)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.6.0...v3.6.1)

**Merged pull requests:**

- Use Etc.getpwuid instead of getlogin [\#183](https://github.com/test-kitchen/kitchen-openstack/pull/183) ([tnguyen14](https://github.com/tnguyen14))

## [v3.6.0](https://github.com/test-kitchen/kitchen-openstack/tree/v3.6.0) (2018-03-28)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.5.1...v3.6.0)

**Closed issues:**

- Is there a way to re-use volume? [\#181](https://github.com/test-kitchen/kitchen-openstack/issues/181)
- private method `select' called for nil:NilClass [\#177](https://github.com/test-kitchen/kitchen-openstack/issues/177)
- The request you have made requires authentication [\#167](https://github.com/test-kitchen/kitchen-openstack/issues/167)

**Merged pull requests:**

- Support for v3 [\#179](https://github.com/test-kitchen/kitchen-openstack/pull/179) ([andybrucenet](https://github.com/andybrucenet))

## [v3.5.1](https://github.com/test-kitchen/kitchen-openstack/tree/v3.5.1) (2017-11-10)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.5.0...v3.5.1)

**Closed issues:**

- block\_device\_mapping crashes on nodename nor servname provided [\#176](https://github.com/test-kitchen/kitchen-openstack/issues/176)
- Same floating IP to different server [\#175](https://github.com/test-kitchen/kitchen-openstack/issues/175)
- Cannot create windows machines [\#172](https://github.com/test-kitchen/kitchen-openstack/issues/172)

**Merged pull requests:**

- Switch from fog to fog-openstack to slim deps and speed runtime [\#174](https://github.com/test-kitchen/kitchen-openstack/pull/174) ([tas50](https://github.com/tas50))

## [v3.5.0](https://github.com/test-kitchen/kitchen-openstack/tree/v3.5.0) (2017-04-12)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.4.0...v3.5.0)

**Merged pull requests:**

- Add metadata support [\#166](https://github.com/test-kitchen/kitchen-openstack/pull/166) ([akitada](https://github.com/akitada))
- Use new ohai config context [\#165](https://github.com/test-kitchen/kitchen-openstack/pull/165) ([akitada](https://github.com/akitada))

## [v3.4.0](https://github.com/test-kitchen/kitchen-openstack/tree/v3.4.0) (2017-03-27)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.3.0...v3.4.0)

**Closed issues:**

- Multiple networks in network\_id causes error [\#163](https://github.com/test-kitchen/kitchen-openstack/issues/163)
- Can't create VM [\#160](https://github.com/test-kitchen/kitchen-openstack/issues/160)
- Why is private\_key\_path required? [\#151](https://github.com/test-kitchen/kitchen-openstack/issues/151)
- version 3.1.0 does not properly wait for VM to be up before failing [\#147](https://github.com/test-kitchen/kitchen-openstack/issues/147)

**Merged pull requests:**

- Fix creation of floating IP to use network ID instead of name [\#162](https://github.com/test-kitchen/kitchen-openstack/pull/162) ([dannytrigo](https://github.com/dannytrigo))
- Updated readme with clarity [\#161](https://github.com/test-kitchen/kitchen-openstack/pull/161) ([jjasghar](https://github.com/jjasghar))

## [v3.3.0](https://github.com/test-kitchen/kitchen-openstack/tree/v3.3.0) (2017-03-13)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.2.0...v3.3.0)

**Merged pull requests:**

- Uuids [\#159](https://github.com/test-kitchen/kitchen-openstack/pull/159) ([boc-tothefuture](https://github.com/boc-tothefuture))

## [v3.2.0](https://github.com/test-kitchen/kitchen-openstack/tree/v3.2.0) (2017-03-02)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.1.0...v3.2.0)

**Closed issues:**

- Expose excon timeouts to kitchen  [\#157](https://github.com/test-kitchen/kitchen-openstack/issues/157)
- Enhancement: generate openstack keypair on create [\#150](https://github.com/test-kitchen/kitchen-openstack/issues/150)
- kitchen-openstack should use SSH Agent [\#149](https://github.com/test-kitchen/kitchen-openstack/issues/149)
- Permission Denied on kitchen runs after first [\#146](https://github.com/test-kitchen/kitchen-openstack/issues/146)
- Config-drive [\#143](https://github.com/test-kitchen/kitchen-openstack/issues/143)
- Support Identity v3 [\#137](https://github.com/test-kitchen/kitchen-openstack/issues/137)

**Merged pull requests:**

- Prep for v3.2.0 [\#158](https://github.com/test-kitchen/kitchen-openstack/pull/158) ([jjasghar](https://github.com/jjasghar))
- Expose excon timeout configuration [\#156](https://github.com/test-kitchen/kitchen-openstack/pull/156) ([MariusCC](https://github.com/MariusCC))
- Dynamically allocate Floating IP for the test server. [\#155](https://github.com/test-kitchen/kitchen-openstack/pull/155) ([dannytrigo](https://github.com/dannytrigo))
- Defer ssh key handling to transport. [\#154](https://github.com/test-kitchen/kitchen-openstack/pull/154) ([cliles](https://github.com/cliles))
- fix failing to get IP when there is no public IP. [\#152](https://github.com/test-kitchen/kitchen-openstack/pull/152) ([onceking](https://github.com/onceking))

## [v3.1.0](https://github.com/test-kitchen/kitchen-openstack/tree/v3.1.0) (2016-06-02)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.0.0...v3.1.0)

**Closed issues:**

- `use\_ipv6` setting not respected when using `openstack\_network\_name` [\#141](https://github.com/test-kitchen/kitchen-openstack/issues/141)

**Merged pull requests:**

- v3.1.0 [\#145](https://github.com/test-kitchen/kitchen-openstack/pull/145) ([jjasghar](https://github.com/jjasghar))
- Add config drive [\#144](https://github.com/test-kitchen/kitchen-openstack/pull/144) ([bradkwadsworth](https://github.com/bradkwadsworth))
- Update to check IP version when using `openstack\_network\_name`. [\#142](https://github.com/test-kitchen/kitchen-openstack/pull/142) ([nmische](https://github.com/nmische))
- minor grammar tweak to sleep message [\#140](https://github.com/test-kitchen/kitchen-openstack/pull/140) ([dpetzel](https://github.com/dpetzel))

## [v3.0.0](https://github.com/test-kitchen/kitchen-openstack/tree/v3.0.0) (2016-02-24)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.0.0.pre.1...v3.0.0)

**Merged pull requests:**

- 3.0.0 prep work [\#139](https://github.com/test-kitchen/kitchen-openstack/pull/139) ([jjasghar](https://github.com/jjasghar))
- 3.0.0 Release of kitchen-openstack [\#136](https://github.com/test-kitchen/kitchen-openstack/pull/136) ([jjasghar](https://github.com/jjasghar))

## [v3.0.0.pre.1](https://github.com/test-kitchen/kitchen-openstack/tree/v3.0.0.pre.1) (2016-02-12)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.2.0...v3.0.0.pre.1)

**Closed issues:**

- transport\#username is not working for me [\#135](https://github.com/test-kitchen/kitchen-openstack/issues/135)
- kitchen-openstack unable to retrieve network information [\#134](https://github.com/test-kitchen/kitchen-openstack/issues/134)
- Password value in transport is not used in driver [\#133](https://github.com/test-kitchen/kitchen-openstack/issues/133)
- SSL\_connect SYSCALL returned=5 errno=0 state=SSLv2/v3 read server hello A \(OpenSSL::SSL::SSLError\) [\#132](https://github.com/test-kitchen/kitchen-openstack/issues/132)
- Volume: create new, attach existing, make from snapshot \(seems not working\) [\#131](https://github.com/test-kitchen/kitchen-openstack/issues/131)
- Boot from Image \(into new volume\) [\#130](https://github.com/test-kitchen/kitchen-openstack/issues/130)
- Put the yml files for each instance in .kitchen/kitchen-openstack [\#116](https://github.com/test-kitchen/kitchen-openstack/issues/116)

## [v2.2.0](https://github.com/test-kitchen/kitchen-openstack/tree/v2.2.0) (2015-12-16)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.2.0.pre.1...v2.2.0)

**Implemented enhancements:**

- Glance Caching sleep time should probably be a configurable option [\#117](https://github.com/test-kitchen/kitchen-openstack/issues/117)

**Closed issues:**

- cannot change default key [\#129](https://github.com/test-kitchen/kitchen-openstack/issues/129)

**Merged pull requests:**

- 2.2.0 [\#128](https://github.com/test-kitchen/kitchen-openstack/pull/128) ([jjasghar](https://github.com/jjasghar))

## [v2.2.0.pre.1](https://github.com/test-kitchen/kitchen-openstack/tree/v2.2.0.pre.1) (2015-11-23)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.1.1...v2.2.0.pre.1)

**Merged pull requests:**

- Updated README with key\_name issue. [\#127](https://github.com/test-kitchen/kitchen-openstack/pull/127) ([jjasghar](https://github.com/jjasghar))
- Use OpenStack models for waiting for conditions [\#120](https://github.com/test-kitchen/kitchen-openstack/pull/120) ([carpnick](https://github.com/carpnick))

## [v2.1.1](https://github.com/test-kitchen/kitchen-openstack/tree/v2.1.1) (2015-11-03)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.1.0...v2.1.1)

**Closed issues:**

- kitchen create on Windows 2012/WinRM fails: "Expressions are only allowed as the first element of a pipeline." [\#122](https://github.com/test-kitchen/kitchen-openstack/issues/122)

**Merged pull requests:**

- 2.1.1 [\#125](https://github.com/test-kitchen/kitchen-openstack/pull/125) ([jjasghar](https://github.com/jjasghar))
- Ohai hint file is now created with the correct encoding on Windows [\#124](https://github.com/test-kitchen/kitchen-openstack/pull/124) ([stuartpreston](https://github.com/stuartpreston))
- Added info about user\_data [\#121](https://github.com/test-kitchen/kitchen-openstack/pull/121) ([jjasghar](https://github.com/jjasghar))

## [v2.1.0](https://github.com/test-kitchen/kitchen-openstack/tree/v2.1.0) (2015-10-19)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.1.0.pre.1...v2.1.0)

## [v2.1.0.pre.1](https://github.com/test-kitchen/kitchen-openstack/tree/v2.1.0.pre.1) (2015-10-13)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.1.0.pre...v2.1.0.pre.1)

**Implemented enhancements:**

- Clean Up README [\#109](https://github.com/test-kitchen/kitchen-openstack/issues/109)

**Fixed bugs:**

- Clean Up README [\#109](https://github.com/test-kitchen/kitchen-openstack/issues/109)

**Closed issues:**

- Countdown timer is a little too verbose [\#113](https://github.com/test-kitchen/kitchen-openstack/issues/113)
- image\_ref: underscores translated to dashes [\#84](https://github.com/test-kitchen/kitchen-openstack/issues/84)

**Merged pull requests:**

- Converting to dots [\#115](https://github.com/test-kitchen/kitchen-openstack/pull/115) ([jjasghar](https://github.com/jjasghar))

## [v2.1.0.pre](https://github.com/test-kitchen/kitchen-openstack/tree/v2.1.0.pre) (2015-10-07)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.0.0...v2.1.0.pre)

**Closed issues:**

- undefined method `public\_ip\_addresses' for {}:Hash [\#105](https://github.com/test-kitchen/kitchen-openstack/issues/105)

**Merged pull requests:**

- updated license links and data. [\#112](https://github.com/test-kitchen/kitchen-openstack/pull/112) ([jjasghar](https://github.com/jjasghar))
- New README [\#111](https://github.com/test-kitchen/kitchen-openstack/pull/111) ([jjasghar](https://github.com/jjasghar))
- Fail action when network info isn't available [\#110](https://github.com/test-kitchen/kitchen-openstack/pull/110) ([BobbyRyterski](https://github.com/BobbyRyterski))
- Wait for network info in get\_ip [\#108](https://github.com/test-kitchen/kitchen-openstack/pull/108) ([BobbyRyterski](https://github.com/BobbyRyterski))
- Refactor get\_ip [\#107](https://github.com/test-kitchen/kitchen-openstack/pull/107) ([BobbyRyterski](https://github.com/BobbyRyterski))
- 2.1.0 [\#106](https://github.com/test-kitchen/kitchen-openstack/pull/106) ([jjasghar](https://github.com/jjasghar))

## [v2.0.0](https://github.com/test-kitchen/kitchen-openstack/tree/v2.0.0) (2015-09-30)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.0.0.dev.4...v2.0.0)

## [v2.0.0.dev.4](https://github.com/test-kitchen/kitchen-openstack/tree/v2.0.0.dev.4) (2015-09-23)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.0.0.dev.3...v2.0.0.dev.4)

**Closed issues:**

- SSH Hangs with Key Auth  [\#101](https://github.com/test-kitchen/kitchen-openstack/issues/101)

**Merged pull requests:**

- fixup install ohai hints so the file is written with root privileges [\#104](https://github.com/test-kitchen/kitchen-openstack/pull/104) ([spion06](https://github.com/spion06))
- Readd key\_name to README [\#103](https://github.com/test-kitchen/kitchen-openstack/pull/103) ([BobbyRyterski](https://github.com/BobbyRyterski))
- Add transport ssh\_key note to README [\#102](https://github.com/test-kitchen/kitchen-openstack/pull/102) ([BobbyRyterski](https://github.com/BobbyRyterski))

## [v2.0.0.dev.3](https://github.com/test-kitchen/kitchen-openstack/tree/v2.0.0.dev.3) (2015-09-21)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.0.0.dev.2...v2.0.0.dev.3)

**Implemented enhancements:**

- Support all Fog OpenStack options [\#98](https://github.com/test-kitchen/kitchen-openstack/pull/98) ([BobbyRyterski](https://github.com/BobbyRyterski))

**Closed issues:**

- OpenStack Hint File should work with Ohai cookbook [\#96](https://github.com/test-kitchen/kitchen-openstack/issues/96)
- create command will makes duplicated images. [\#67](https://github.com/test-kitchen/kitchen-openstack/issues/67)

**Merged pull requests:**

- Don't create instance if name is already created [\#100](https://github.com/test-kitchen/kitchen-openstack/pull/100) ([dpetzel](https://github.com/dpetzel))
- Fix for issue 96 [\#97](https://github.com/test-kitchen/kitchen-openstack/pull/97) ([jjasghar](https://github.com/jjasghar))

## [v2.0.0.dev.2](https://github.com/test-kitchen/kitchen-openstack/tree/v2.0.0.dev.2) (2015-09-16)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.0.0.dev.1...v2.0.0.dev.2)

**Merged pull requests:**

- Load openstack\_version for plugin\_version [\#99](https://github.com/test-kitchen/kitchen-openstack/pull/99) ([BobbyRyterski](https://github.com/BobbyRyterski))

## [v2.0.0.dev.1](https://github.com/test-kitchen/kitchen-openstack/tree/v2.0.0.dev.1) (2015-09-10)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.0.0.dev...v2.0.0.dev.1)

**Closed issues:**

- 1.9.0.dev [\#93](https://github.com/test-kitchen/kitchen-openstack/issues/93)

**Merged pull requests:**

- 2.0.0.dev.1 [\#95](https://github.com/test-kitchen/kitchen-openstack/pull/95) ([jjasghar](https://github.com/jjasghar))

## [v2.0.0.dev](https://github.com/test-kitchen/kitchen-openstack/tree/v2.0.0.dev) (2015-09-09)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.9.0.dev...v2.0.0.dev)

**Implemented enhancements:**

- Test Kitchen Openstack doesn't support block storage\(volumes\) [\#75](https://github.com/test-kitchen/kitchen-openstack/issues/75)
- Enhancement: Windows Support [\#45](https://github.com/test-kitchen/kitchen-openstack/issues/45)

**Closed issues:**

- Waiting for SSH service [\#91](https://github.com/test-kitchen/kitchen-openstack/issues/91)
- Connections to Rackspace require the password instead of the API key [\#90](https://github.com/test-kitchen/kitchen-openstack/issues/90)

**Merged pull requests:**

- added rubygem tasks [\#94](https://github.com/test-kitchen/kitchen-openstack/pull/94) ([jjasghar](https://github.com/jjasghar))
- Kitchen::Base and Windows support [\#92](https://github.com/test-kitchen/kitchen-openstack/pull/92) ([jjasghar](https://github.com/jjasghar))

## [v1.9.0.dev](https://github.com/test-kitchen/kitchen-openstack/tree/v1.9.0.dev) (2015-09-03)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.8.1...v1.9.0.dev)

**Merged pull requests:**

- Ability to control the order of IP to connect to [\#89](https://github.com/test-kitchen/kitchen-openstack/pull/89) ([ytsarev](https://github.com/ytsarev))

## [v1.8.1](https://github.com/test-kitchen/kitchen-openstack/tree/v1.8.1) (2015-07-22)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.3.1...v1.8.1)

**Implemented enhancements:**

- Yo, dawg, I heard you like Test Kitchen... [\#30](https://github.com/test-kitchen/kitchen-openstack/issues/30)

**Closed issues:**

- Config checks in openstack.rb [\#82](https://github.com/test-kitchen/kitchen-openstack/issues/82)
- Readme Usage : Openstack tenant in config [\#81](https://github.com/test-kitchen/kitchen-openstack/issues/81)
- Kitchen converge hangs [\#71](https://github.com/test-kitchen/kitchen-openstack/issues/71)

**Merged pull requests:**

- Fail if required key information can't be found [\#88](https://github.com/test-kitchen/kitchen-openstack/pull/88) ([RoboticCheese](https://github.com/RoboticCheese))
- Fix for the readme.md [\#87](https://github.com/test-kitchen/kitchen-openstack/pull/87) ([jjasghar](https://github.com/jjasghar))
- Issue 82 [\#86](https://github.com/test-kitchen/kitchen-openstack/pull/86) ([jjasghar](https://github.com/jjasghar))
- Added a check for ssh key authetication [\#85](https://github.com/test-kitchen/kitchen-openstack/pull/85) ([jjasghar](https://github.com/jjasghar))

## [v1.3.1](https://github.com/test-kitchen/kitchen-openstack/tree/v1.3.1) (2015-07-18)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.2.0...v1.3.1)

**Merged pull requests:**

- Update README.md for chefdk installation [\#83](https://github.com/test-kitchen/kitchen-openstack/pull/83) ([kcd83](https://github.com/kcd83))

## [v1.2.0](https://github.com/test-kitchen/kitchen-openstack/tree/v1.2.0) (2015-06-18)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.2.0.rc2...v1.2.0)

## [v1.2.0.rc2](https://github.com/test-kitchen/kitchen-openstack/tree/v1.2.0.rc2) (2015-06-10)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.2.0.rc1...v1.2.0.rc2)

## [v1.2.0.rc1](https://github.com/test-kitchen/kitchen-openstack/tree/v1.2.0.rc1) (2015-06-04)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.8.0...v1.2.0.rc1)

## [v1.8.0](https://github.com/test-kitchen/kitchen-openstack/tree/v1.8.0) (2015-04-09)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.7.1...v1.8.0)

**Closed issues:**

- Create failed on instance \<default-cirros\> 400 [\#73](https://github.com/test-kitchen/kitchen-openstack/issues/73)
- not able to  find the driver [\#72](https://github.com/test-kitchen/kitchen-openstack/issues/72)

**Merged pull requests:**

- Update tests for newer TK [\#76](https://github.com/test-kitchen/kitchen-openstack/pull/76) ([RoboticCheese](https://github.com/RoboticCheese))
- Respect a configured password when setting up SSH [\#70](https://github.com/test-kitchen/kitchen-openstack/pull/70) ([RoboticCheese](https://github.com/RoboticCheese))

## [v1.7.1](https://github.com/test-kitchen/kitchen-openstack/tree/v1.7.1) (2015-01-08)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.7.0...v1.7.1)

## [v1.7.0](https://github.com/test-kitchen/kitchen-openstack/tree/v1.7.0) (2014-10-26)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.6.1...v1.7.0)

**Closed issues:**

- kitchen attempting to log in too quickly? [\#64](https://github.com/test-kitchen/kitchen-openstack/issues/64)
- problem to specify Availability Zone when create instance [\#61](https://github.com/test-kitchen/kitchen-openstack/issues/61)

**Merged pull requests:**

- Support a timed sleep for SSH edge cases [\#66](https://github.com/test-kitchen/kitchen-openstack/pull/66) ([RoboticCheese](https://github.com/RoboticCheese))
- Availability zone support+ [\#65](https://github.com/test-kitchen/kitchen-openstack/pull/65) ([RoboticCheese](https://github.com/RoboticCheese))
- Add server\_name\_prefix semi-random naming with some known prefix [\#63](https://github.com/test-kitchen/kitchen-openstack/pull/63) ([ftclausen](https://github.com/ftclausen))

## [v1.6.1](https://github.com/test-kitchen/kitchen-openstack/tree/v1.6.1) (2014-10-07)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/1.0.0...v1.6.1)

**Merged pull requests:**

- Renamed 'init\_config' method to resolve conflicting method name with lat... [\#60](https://github.com/test-kitchen/kitchen-openstack/pull/60) ([stevejmason](https://github.com/stevejmason))

## [1.0.0](https://github.com/test-kitchen/kitchen-openstack/tree/1.0.0) (2014-10-07)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/1.0.0.rc2...1.0.0)

## [1.0.0.rc2](https://github.com/test-kitchen/kitchen-openstack/tree/1.0.0.rc2) (2014-09-29)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/1.0.0.rc1...1.0.0.rc2)

## [1.0.0.rc1](https://github.com/test-kitchen/kitchen-openstack/tree/1.0.0.rc1) (2014-09-24)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.6.0...1.0.0.rc1)

## [v1.6.0](https://github.com/test-kitchen/kitchen-openstack/tree/v1.6.0) (2014-09-04)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.5.3...v1.6.0)

**Closed issues:**

- 1.5.3 name generation broken. [\#54](https://github.com/test-kitchen/kitchen-openstack/issues/54)
- Remove occurrences of "require\_chef\_omnibus: latest" in docs [\#34](https://github.com/test-kitchen/kitchen-openstack/issues/34)

**Merged pull requests:**

- \#55 + shut Rubocop up for now [\#59](https://github.com/test-kitchen/kitchen-openstack/pull/59) ([RoboticCheese](https://github.com/RoboticCheese))
- Fix \#54; prevent errors on non-login shells [\#58](https://github.com/test-kitchen/kitchen-openstack/pull/58) ([RoboticCheese](https://github.com/RoboticCheese))
- \#56 + drop Ruby 1.9.2 [\#57](https://github.com/test-kitchen/kitchen-openstack/pull/57) ([RoboticCheese](https://github.com/RoboticCheese))
- Select the first valid IP if all other checks fail [\#56](https://github.com/test-kitchen/kitchen-openstack/pull/56) ([jer](https://github.com/jer))
- Reverse the priority of floating\_ip & floating\_ip\_pool [\#55](https://github.com/test-kitchen/kitchen-openstack/pull/55) ([StaymanHou](https://github.com/StaymanHou))

## [v1.5.3](https://github.com/test-kitchen/kitchen-openstack/tree/v1.5.3) (2014-08-01)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.5.2...v1.5.3)

**Closed issues:**

- generate\_name generates bad hostnames [\#52](https://github.com/test-kitchen/kitchen-openstack/issues/52)

**Merged pull requests:**

- Fix bad hostnames being generated [\#53](https://github.com/test-kitchen/kitchen-openstack/pull/53) ([RoboticCheese](https://github.com/RoboticCheese))
- Switch to Rubocop and clean up as much as possible [\#51](https://github.com/test-kitchen/kitchen-openstack/pull/51) ([RoboticCheese](https://github.com/RoboticCheese))

## [v1.5.2](https://github.com/test-kitchen/kitchen-openstack/tree/v1.5.2) (2014-05-31)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.5.0...v1.5.2)

**Merged pull requests:**

- Roboticcheese/fix server name length loop bug [\#50](https://github.com/test-kitchen/kitchen-openstack/pull/50) ([RoboticCheese](https://github.com/RoboticCheese))
- Hostname limit [\#49](https://github.com/test-kitchen/kitchen-openstack/pull/49) ([dschlenk](https://github.com/dschlenk))

## [v1.5.0](https://github.com/test-kitchen/kitchen-openstack/tree/v1.5.0) (2014-05-23)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/0.10.0...v1.5.0)

**Merged pull requests:**

- Add OpenStack Ohai hints file [\#48](https://github.com/test-kitchen/kitchen-openstack/pull/48) ([dschlenk](https://github.com/dschlenk))

## [0.10.0](https://github.com/test-kitchen/kitchen-openstack/tree/0.10.0) (2014-05-09)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.4.0...0.10.0)

## [v1.4.0](https://github.com/test-kitchen/kitchen-openstack/tree/v1.4.0) (2014-04-09)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/0.9.1...v1.4.0)

**Closed issues:**

- Message: cannot copy directory [\#43](https://github.com/test-kitchen/kitchen-openstack/issues/43)

**Merged pull requests:**

- Use floating IP for ssh connection by default if defined or allocated from pool. [\#46](https://github.com/test-kitchen/kitchen-openstack/pull/46) ([dschlenk](https://github.com/dschlenk))

## [0.9.1](https://github.com/test-kitchen/kitchen-openstack/tree/0.9.1) (2014-03-12)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.3.0...0.9.1)

**Closed issues:**

- Unable to create instance using network\_ref [\#42](https://github.com/test-kitchen/kitchen-openstack/issues/42)

## [v1.3.0](https://github.com/test-kitchen/kitchen-openstack/tree/v1.3.0) (2014-03-09)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/0.9.0...v1.3.0)

## [0.9.0](https://github.com/test-kitchen/kitchen-openstack/tree/0.9.0) (2014-03-07)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.1.0...0.9.0)

**Implemented enhancements:**

- Security Group support [\#36](https://github.com/test-kitchen/kitchen-openstack/issues/36)

**Merged pull requests:**

- Wait ssh connection for the specified port after the instance is created [\#41](https://github.com/test-kitchen/kitchen-openstack/pull/41) ([tenforward](https://github.com/tenforward))
- option for user\_data to be passed to openstack [\#40](https://github.com/test-kitchen/kitchen-openstack/pull/40) ([wilreichert](https://github.com/wilreichert))
- added basic support for networks [\#39](https://github.com/test-kitchen/kitchen-openstack/pull/39) ([monsterzz](https://github.com/monsterzz))
- added support to assign security groups [\#37](https://github.com/test-kitchen/kitchen-openstack/pull/37) ([bears4barrett](https://github.com/bears4barrett))
- Update URLs to test-kitchen org [\#35](https://github.com/test-kitchen/kitchen-openstack/pull/35) ([RoboticCheese](https://github.com/RoboticCheese))
- Add Coveralls support, maybe [\#32](https://github.com/test-kitchen/kitchen-openstack/pull/32) ([RoboticCheese](https://github.com/RoboticCheese))

## [v1.1.0](https://github.com/test-kitchen/kitchen-openstack/tree/v1.1.0) (2013-12-07)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.0.0...v1.1.0)

**Fixed bugs:**

- config\[:name\] is now used by Test Kitchen... [\#29](https://github.com/test-kitchen/kitchen-openstack/issues/29)

**Merged pull requests:**

- Fix \#29 - Rename 'name' option to 'server\_name' [\#31](https://github.com/test-kitchen/kitchen-openstack/pull/31) ([RoboticCheese](https://github.com/RoboticCheese))

## [v1.0.0](https://github.com/test-kitchen/kitchen-openstack/tree/v1.0.0) (2013-10-16)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.5.0...v1.0.0)

**Implemented enhancements:**

- Support requesting a specific floating IP [\#21](https://github.com/test-kitchen/kitchen-openstack/issues/21)
- Support friendly flavor names [\#23](https://github.com/test-kitchen/kitchen-openstack/issues/23)
- Support friendly image names [\#22](https://github.com/test-kitchen/kitchen-openstack/issues/22)

**Merged pull requests:**

- synchronize lookup and assignment of floating ip [\#27](https://github.com/test-kitchen/kitchen-openstack/pull/27) ([jgawor](https://github.com/jgawor))
- specify image or flavor using the name or regular expression [\#26](https://github.com/test-kitchen/kitchen-openstack/pull/26) ([jgawor](https://github.com/jgawor))
- Refactoring and updating unit tests [\#25](https://github.com/test-kitchen/kitchen-openstack/pull/25) ([RoboticCheese](https://github.com/RoboticCheese))
- SSH key tweaks [\#15](https://github.com/test-kitchen/kitchen-openstack/pull/15) ([hufman](https://github.com/hufman))
- Floating ip support [\#14](https://github.com/test-kitchen/kitchen-openstack/pull/14) ([hufman](https://github.com/hufman))

## [v0.5.0](https://github.com/test-kitchen/kitchen-openstack/tree/v0.5.0) (2013-09-23)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.8.1...v0.5.0)

**Fixed bugs:**

- Ordering of server.addresses isn't guaranteed [\#17](https://github.com/test-kitchen/kitchen-openstack/issues/17)

**Closed issues:**

- Cap generate\_name output to 64 characters [\#18](https://github.com/test-kitchen/kitchen-openstack/issues/18)
- Don't assume network names of "public" and "private" [\#16](https://github.com/test-kitchen/kitchen-openstack/issues/16)
- issue with latest test-kitchen 1.0.0.beta.2 and kitchen-openstack [\#13](https://github.com/test-kitchen/kitchen-openstack/issues/13)

**Merged pull requests:**

- Fix \#18 - Limit generated hostnames to 64 characters [\#20](https://github.com/test-kitchen/kitchen-openstack/pull/20) ([RoboticCheese](https://github.com/RoboticCheese))
- Fix \#16 and \#17 - Rewrite get\_ip method [\#19](https://github.com/test-kitchen/kitchen-openstack/pull/19) ([RoboticCheese](https://github.com/RoboticCheese))

## [v0.8.1](https://github.com/test-kitchen/kitchen-openstack/tree/v0.8.1) (2013-06-14)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.4.0...v0.8.1)

## [v0.4.0](https://github.com/test-kitchen/kitchen-openstack/tree/v0.4.0) (2013-06-06)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.8.0...v0.4.0)

**Merged pull requests:**

- support get\_ip from user-defined network group [\#12](https://github.com/test-kitchen/kitchen-openstack/pull/12) ([ainoya](https://github.com/ainoya))
- Care about ssh\_key option [\#11](https://github.com/test-kitchen/kitchen-openstack/pull/11) ([ainoya](https://github.com/ainoya))

## [v0.8.0](https://github.com/test-kitchen/kitchen-openstack/tree/v0.8.0) (2013-05-13)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.2.0...v0.8.0)

## [v0.2.0](https://github.com/test-kitchen/kitchen-openstack/tree/v0.2.0) (2013-05-11)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.7.1...v0.2.0)

**Implemented enhancements:**

- Support an optional region setting [\#8](https://github.com/test-kitchen/kitchen-openstack/issues/8)
- Start building in TravisCI [\#6](https://github.com/test-kitchen/kitchen-openstack/issues/6)
- RSpec Tests\(?\) [\#5](https://github.com/test-kitchen/kitchen-openstack/issues/5)
- Use Project Name in Server Hostname [\#1](https://github.com/test-kitchen/kitchen-openstack/issues/1)

**Fixed bugs:**

- Servers Linger post-destroy [\#3](https://github.com/test-kitchen/kitchen-openstack/issues/3)

**Closed issues:**

- Fix Failing Style Checks [\#4](https://github.com/test-kitchen/kitchen-openstack/issues/4)

**Merged pull requests:**

- Add region and service name support [\#10](https://github.com/test-kitchen/kitchen-openstack/pull/10) ([RoboticCheese](https://github.com/RoboticCheese))
- Working overkill RSpec tests [\#9](https://github.com/test-kitchen/kitchen-openstack/pull/9) ([RoboticCheese](https://github.com/RoboticCheese))
- Jdh assorted enhancements [\#7](https://github.com/test-kitchen/kitchen-openstack/pull/7) ([RoboticCheese](https://github.com/RoboticCheese))
- Allow users to use keys uploaded to Openstack [\#2](https://github.com/test-kitchen/kitchen-openstack/pull/2) ([stevendanna](https://github.com/stevendanna))

## [v0.7.1](https://github.com/test-kitchen/kitchen-openstack/tree/v0.7.1) (2013-04-11)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/0.7.0...v0.7.1)

## [0.7.0](https://github.com/test-kitchen/kitchen-openstack/tree/0.7.0) (2013-03-09)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.6.2...0.7.0)

## [v0.6.2](https://github.com/test-kitchen/kitchen-openstack/tree/v0.6.2) (2012-10-14)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.6.0...v0.6.2)

## [v0.6.0](https://github.com/test-kitchen/kitchen-openstack/tree/v0.6.0) (2012-06-27)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.5.4...v0.6.0)

## [v0.5.4](https://github.com/test-kitchen/kitchen-openstack/tree/v0.5.4) (2011-05-03)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.5.3...v0.5.4)

## [v0.5.3](https://github.com/test-kitchen/kitchen-openstack/tree/v0.5.3) (2011-04-06)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.5.2...v0.5.3)

## [v0.5.2](https://github.com/test-kitchen/kitchen-openstack/tree/v0.5.2) (2011-04-06)
[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.5.1...v0.5.2)

## [v0.5.1](https://github.com/test-kitchen/kitchen-openstack/tree/v0.5.1) (2011-04-05)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
