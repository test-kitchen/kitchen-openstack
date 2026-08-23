# Change Log

## Unreleased

* chore(deps): update googleapis/release-please-action action to v5 ([#240](https://github.com/test-kitchen/kitchen-openstack/pull/240)) ([efe8e298](https://github.com/test-kitchen/kitchen-openstack/commit/efe8e298))
* chore(deps): update actions/checkout action to v7 ([#242](https://github.com/test-kitchen/kitchen-openstack/pull/242)) ([297cd575](https://github.com/test-kitchen/kitchen-openstack/commit/297cd575))
* Fix typos ([#243](https://github.com/test-kitchen/kitchen-openstack/pull/243)) ([e4755bd8](https://github.com/test-kitchen/kitchen-openstack/commit/e4755bd8))
* Require Ruby 3.1+ and modernize CI ([#244](https://github.com/test-kitchen/kitchen-openstack/pull/244)) ([d199adaa](https://github.com/test-kitchen/kitchen-openstack/commit/d199adaa))
* Docs: document every driver option and split contributor docs ([#246](https://github.com/test-kitchen/kitchen-openstack/pull/246)) ([ee556dae](https://github.com/test-kitchen/kitchen-openstack/commit/ee556dae))
* Standardize renovate config and remove dependabot ([#247](https://github.com/test-kitchen/kitchen-openstack/pull/247)) ([39ccc29e](https://github.com/test-kitchen/kitchen-openstack/commit/39ccc29e))

## [8.0.0](https://github.com/test-kitchen/kitchen-openstack/compare/v7.0.1...v8.0.0) (2026-08-23)


### ⚠ BREAKING CHANGES

* three behaviours change in ways that can fail a converge that previously succeeded.

### Bug Fixes

* rebuild the unit test suite, document lib/, fix the bugs it found ([#245](https://github.com/test-kitchen/kitchen-openstack/issues/245)) ([42039e0](https://github.com/test-kitchen/kitchen-openstack/commit/42039e020f3e12425373d1fe30706f7b8dabb375))

## [7.0.1](https://github.com/test-kitchen/kitchen-openstack/compare/v7.0.0...v7.0.1) (2026-04-24)

### Bug Fixes

* **driver:** coerce OpenStack auth/config values to strings before Fog ([#239](https://github.com/test-kitchen/kitchen-openstack/issues/239)) ([f53b635](https://github.com/test-kitchen/kitchen-openstack/commit/f53b6351872bc7fa0cc6d55cd650c0b649990c8a))

## [7.0.0](https://github.com/test-kitchen/kitchen-openstack/compare/v6.2.2...v7.0.0) (2026-04-07)

### ⚠ BREAKING CHANGES

* Kitchen::Driver::Openstack internals have been reorganized into separate modules (Config, Networking, ServerHelper, Helpers). Users relying on internal class structure may need to update.

### Features

* add OpenStack clouds.yaml and OS_* env var support ([#236](https://github.com/test-kitchen/kitchen-openstack/issues/236)) ([66db1c2](https://github.com/test-kitchen/kitchen-openstack/commit/66db1c25f8ab5da6effca7a772c33a6a178b2e87)), closes [#212](https://github.com/test-kitchen/kitchen-openstack/issues/212)


### Miscellaneous Chores

* target major release ([#238](https://github.com/test-kitchen/kitchen-openstack/issues/238)) ([e126d92](https://github.com/test-kitchen/kitchen-openstack/commit/e126d929ab5fadfb94e1db61adca6e322b05f51d))

### Other Changes

* refactor: split main driver file into focused modules ([#235](https://github.com/test-kitchen/kitchen-openstack/pull/235)) ([633e8f13](https://github.com/test-kitchen/kitchen-openstack/commit/633e8f13))

## [6.2.2](https://github.com/test-kitchen/kitchen-openstack/compare/v6.2.1...v6.2.2) (2026-01-24)

### Bug Fixes

* switch to cookstyle ([#233](https://github.com/test-kitchen/kitchen-openstack/issues/233)) ([dda6596](https://github.com/test-kitchen/kitchen-openstack/commit/dda659687a48dbde55e49407194f231af8b3f691))

### Other Changes

* chore(deps): update actions/checkout action to v5 ([#230](https://github.com/test-kitchen/kitchen-openstack/pull/230)) ([3ac1075e](https://github.com/test-kitchen/kitchen-openstack/commit/3ac1075e))
* fix: bump tk dep to allow tk 4 ([#232](https://github.com/test-kitchen/kitchen-openstack/pull/232)) ([a0450b0b](https://github.com/test-kitchen/kitchen-openstack/commit/a0450b0b))
* chore(deps): update actions/checkout action to v6 ([#231](https://github.com/test-kitchen/kitchen-openstack/pull/231)) ([0e6c7463](https://github.com/test-kitchen/kitchen-openstack/commit/0e6c7463))

## [6.2.1](https://github.com/test-kitchen/kitchen-openstack/compare/v6.2.0...v6.2.1) (2024-06-21)

### Bug Fixes

* release please configs ([#228](https://github.com/test-kitchen/kitchen-openstack/issues/228)) ([cbb2736](https://github.com/test-kitchen/kitchen-openstack/commit/cbb27362313150d6be7de0d356affbc3069101bb))

### Other Changes

* Configure Renovate ([#224](https://github.com/test-kitchen/kitchen-openstack/pull/224)) ([71a2287b](https://github.com/test-kitchen/kitchen-openstack/commit/71a2287b))

## [6.2.0](https://github.com/test-kitchen/kitchen-openstack/tree/v6.2.0)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v6.1.0..v6.2.0)

- Support for Ruby 3.1
- Check for ERROR status after server create

* Move documentation to kitchen.ci ([7d500d81](https://github.com/test-kitchen/kitchen-openstack/commit/7d500d81))
* run specs on ruby 3.1 ([#221](https://github.com/test-kitchen/kitchen-openstack/pull/221)) ([cd7a2cb1](https://github.com/test-kitchen/kitchen-openstack/commit/cd7a2cb1))

## [6.1.0](https://github.com/test-kitchen/kitchen-openstack/tree/v6.1.0)

- Support Test Kitchen 3.0

* Upgrade to GitHub-native Dependabot ([#216](https://github.com/test-kitchen/kitchen-openstack/pull/216)) ([aa04fe14](https://github.com/test-kitchen/kitchen-openstack/commit/aa04fe14))

## [6.0.0](https://github.com/test-kitchen/kitchen-openstack/tree/v6.0.0)

- Require Ruby 2.6 or later and add testing for Ruby 3.0
- Add a new `cloud_config` option which allows you to pass data to cloud-init. See <https://github.com/test-kitchen/kitchen-openstack#cloud_config> for usage information. Thanks [@JimScadden](https://github.com/JimScadden)

* Chefstyle fixes ([#209](https://github.com/test-kitchen/kitchen-openstack/pull/209)) ([a5046d5f](https://github.com/test-kitchen/kitchen-openstack/commit/a5046d5f))
* Optimize our requires ([#210](https://github.com/test-kitchen/kitchen-openstack/pull/210)) ([c27b941a](https://github.com/test-kitchen/kitchen-openstack/commit/c27b941a))
* Require Ruby 2.6 or newer ([#215](https://github.com/test-kitchen/kitchen-openstack/pull/215)) ([54f984ea](https://github.com/test-kitchen/kitchen-openstack/commit/54f984ea))
* New option cloud_config for generating user data ([#214](https://github.com/test-kitchen/kitchen-openstack/pull/214)) ([c2d79263](https://github.com/test-kitchen/kitchen-openstack/commit/c2d79263))
* Test on Ruby 3.0 and cache gem installs ([#213](https://github.com/test-kitchen/kitchen-openstack/pull/213)) ([46aae21f](https://github.com/test-kitchen/kitchen-openstack/commit/46aae21f))
* Remove old badges and improve installation steps ([c7d25f7d](https://github.com/test-kitchen/kitchen-openstack/commit/c7d25f7d))
* Swap Travis badge for GitHub Actions badge ([4873c625](https://github.com/test-kitchen/kitchen-openstack/commit/4873c625))

## [5.0.1](https://github.com/test-kitchen/kitchen-openstack/tree/v5.0.1)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v5.0.0..v5.0.1)

- Switched to GitHub Actions for PR testing
- Resolved fog deprecation warnings when running the plugin
- Removed the unused `unf` gem dependency

* Switch to Github Actions ([#206](https://github.com/test-kitchen/kitchen-openstack/pull/206)) ([d464627c](https://github.com/test-kitchen/kitchen-openstack/commit/d464627c))
* Fix deprecation warnings ([#207](https://github.com/test-kitchen/kitchen-openstack/pull/207)) ([78e4bd94](https://github.com/test-kitchen/kitchen-openstack/commit/78e4bd94))

## [5.0.0](https://github.com/test-kitchen/kitchen-openstack/tree/v5.0.0)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v4.0.0..v5.0.0)

- Added functionality to delay attaching a volume after its marked active when configuring block device mapping. This addresses an issue in VMWare Openstack (VIO) that may be present in others when attaching large volumes in which VIO would mark the device active but was still performing operations which caused test kitchen to fail.
- Require fog-openstack 1.X instead of Fog < 1, which greatly reduces the total dependencies necessary. This may require updating other tools to support fog 1.x, which has breaking changes.
- Only ship the necessary files in the gem to slim the size of the gem install slightly

* Loosen the Test Kitchen dep to allow 2.0 ([#195](https://github.com/test-kitchen/kitchen-openstack/pull/195)) ([8f018725](https://github.com/test-kitchen/kitchen-openstack/commit/8f018725))
* Allow fog-openstack 1.x ([#202](https://github.com/test-kitchen/kitchen-openstack/pull/202)) ([a0d8a382](https://github.com/test-kitchen/kitchen-openstack/commit/a0d8a382))

## [4.0.0](https://github.com/test-kitchen/kitchen-openstack/tree/v4.0.0)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.6.2..v4.0.0)

- Loosen the Test Kitchen dependency to allow for 2.x
- Fix minor style issues in the code

* Update README.md ([5e0233c3](https://github.com/test-kitchen/kitchen-openstack/commit/5e0233c3))
* Test kitchen 2.x Fixes ([#200](https://github.com/test-kitchen/kitchen-openstack/pull/200)) ([7888bb25](https://github.com/test-kitchen/kitchen-openstack/commit/7888bb25))
* Bump to version 4.0.0 ([7d822025](https://github.com/test-kitchen/kitchen-openstack/commit/7d822025))

## [3.6.2](https://github.com/test-kitchen/kitchen-openstack/tree/v3.6.2)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.6.1...v3.6.2)

**Merged pull requests:**

- Fall back on Etc.getlogin for windows environments [\#186](https://github.com/test-kitchen/kitchen-openstack/pull/186) ([joshuariojas](https://github.com/joshuariojas))
- Update Travis to the latest ruby releases [\#185](https://github.com/test-kitchen/kitchen-openstack/pull/185) ([tas50](https://github.com/tas50))
- Getting travis green. [\#184](https://github.com/test-kitchen/kitchen-openstack/pull/184) ([jjasghar](https://github.com/jjasghar))

* v3.6.2 release ([0f715a95](https://github.com/test-kitchen/kitchen-openstack/commit/0f715a95))

## [3.6.1](https://github.com/test-kitchen/kitchen-openstack/tree/v3.6.1) (2018-06-06)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.6.0...v3.6.1)

**Merged pull requests:**

- Use Etc.getpwuid instead of getlogin [\#183](https://github.com/test-kitchen/kitchen-openstack/pull/183) ([tnguyen14](https://github.com/tnguyen14))

* work around for travis ([2c11d22d](https://github.com/test-kitchen/kitchen-openstack/commit/2c11d22d))
* v3.6.1 release ([1edf7b15](https://github.com/test-kitchen/kitchen-openstack/commit/1edf7b15))

## [3.6.0](https://github.com/test-kitchen/kitchen-openstack/tree/v3.6.0) (2018-03-28)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.5.1...v3.6.0)

**Merged pull requests:**

- Support for v3 [\#179](https://github.com/test-kitchen/kitchen-openstack/pull/179) ([andybrucenet](https://github.com/andybrucenet))

* v3.6.0 release ([8a34e415](https://github.com/test-kitchen/kitchen-openstack/commit/8a34e415))

## [3.5.1](https://github.com/test-kitchen/kitchen-openstack/tree/v3.5.1) (2017-11-10)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.5.0...v3.5.1)

**Merged pull requests:**

- Switch from fog to fog-openstack to slim deps and speed runtime [\#174](https://github.com/test-kitchen/kitchen-openstack/pull/174) ([tas50](https://github.com/tas50))

* 3.5.1 release ([c1398fbb](https://github.com/test-kitchen/kitchen-openstack/commit/c1398fbb))

## [3.5.0](https://github.com/test-kitchen/kitchen-openstack/tree/v3.5.0) (2017-04-12)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.4.0...v3.5.0)

**Merged pull requests:**

- Add metadata support [\#166](https://github.com/test-kitchen/kitchen-openstack/pull/166) ([akitada](https://github.com/akitada))
- Use new ohai config context [\#165](https://github.com/test-kitchen/kitchen-openstack/pull/165) ([akitada](https://github.com/akitada))

* v3.5.0 release ([bc24c335](https://github.com/test-kitchen/kitchen-openstack/commit/bc24c335))

## [3.4.0](https://github.com/test-kitchen/kitchen-openstack/tree/v3.4.0) (2017-03-27)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.3.0...v3.4.0)

**Merged pull requests:**

- Fix creation of floating IP to use network ID instead of name [\#162](https://github.com/test-kitchen/kitchen-openstack/pull/162) ([dannytrigo](https://github.com/dannytrigo))
- Updated readme with clarity [\#161](https://github.com/test-kitchen/kitchen-openstack/pull/161) ([jjasghar](https://github.com/jjasghar))

* v3.4.0 ([cb2674db](https://github.com/test-kitchen/kitchen-openstack/commit/cb2674db))

## [3.3.0](https://github.com/test-kitchen/kitchen-openstack/tree/v3.3.0) (2017-03-13)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.2.0...v3.3.0)

**Merged pull requests:**

- Uuids [\#159](https://github.com/test-kitchen/kitchen-openstack/pull/159) ([boc-tothefuture](https://github.com/boc-tothefuture))

* v3.3.0 ([f4646cdb](https://github.com/test-kitchen/kitchen-openstack/commit/f4646cdb))

## [3.2.0](https://github.com/test-kitchen/kitchen-openstack/tree/v3.2.0) (2017-03-02)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.1.0...v3.2.0)

**Merged pull requests:**

- Prep for v3.2.0 [\#158](https://github.com/test-kitchen/kitchen-openstack/pull/158) ([jjasghar](https://github.com/jjasghar))
- Expose excon timeout configuration [\#156](https://github.com/test-kitchen/kitchen-openstack/pull/156) ([MariusCC](https://github.com/MariusCC))
- Dynamically allocate Floating IP for the test server. [\#155](https://github.com/test-kitchen/kitchen-openstack/pull/155) ([dannytrigo](https://github.com/dannytrigo))
- Defer ssh key handling to transport. [\#154](https://github.com/test-kitchen/kitchen-openstack/pull/154) ([cliles](https://github.com/cliles))
- fix failing to get IP when there is no public IP. [\#152](https://github.com/test-kitchen/kitchen-openstack/pull/152) ([onceking](https://github.com/onceking))

## [3.1.0](https://github.com/test-kitchen/kitchen-openstack/tree/v3.1.0) (2016-06-02)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.0.0...v3.1.0)

**Merged pull requests:**

- v3.1.0 [\#145](https://github.com/test-kitchen/kitchen-openstack/pull/145) ([jjasghar](https://github.com/jjasghar))
- Add config drive [\#144](https://github.com/test-kitchen/kitchen-openstack/pull/144) ([bradkwadsworth](https://github.com/bradkwadsworth))
- Update to check IP version when using `openstack\_network\_name`. [\#142](https://github.com/test-kitchen/kitchen-openstack/pull/142) ([nmische](https://github.com/nmische))
- minor grammar tweak to sleep message [\#140](https://github.com/test-kitchen/kitchen-openstack/pull/140) ([dpetzel](https://github.com/dpetzel))

## [3.0.0](https://github.com/test-kitchen/kitchen-openstack/tree/v3.0.0) (2016-02-24)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v3.0.0.pre.1...v3.0.0)

**Merged pull requests:**

- 3.0.0 prep work [\#139](https://github.com/test-kitchen/kitchen-openstack/pull/139) ([jjasghar](https://github.com/jjasghar))
- 3.0.0 Release of kitchen-openstack [\#136](https://github.com/test-kitchen/kitchen-openstack/pull/136) ([jjasghar](https://github.com/jjasghar))

## [3.0.0.pre.1](https://github.com/test-kitchen/kitchen-openstack/tree/v3.0.0.pre.1) (2016-02-12)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.2.0...v3.0.0.pre.1)

* Update README.md ([149a5d45](https://github.com/test-kitchen/kitchen-openstack/commit/149a5d45))
* 3.0.0 Release of kitchen-openstack ([1c9d0bce](https://github.com/test-kitchen/kitchen-openstack/commit/1c9d0bce))
* Removed old tests - Removed old tests for the code that I removed from the earlier commit ([8f996076](https://github.com/test-kitchen/kitchen-openstack/commit/8f996076))
* Pinned rubocop version - Pinned rubocop version because of travis failures ([940fb355](https://github.com/test-kitchen/kitchen-openstack/commit/940fb355))
* Making the rubocop gods happy - Updated rubocop to ~&gt; 0.36 - Fixed SignalExceptions - Froze the version.rb per rubocop ([3a7a0bcd](https://github.com/test-kitchen/kitchen-openstack/commit/3a7a0bcd))

## [2.2.0](https://github.com/test-kitchen/kitchen-openstack/tree/v2.2.0) (2015-12-16)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.2.0.pre.1...v2.2.0)

**Implemented enhancements:**

- Glance Caching sleep time should probably be a configurable option [\#117](https://github.com/test-kitchen/kitchen-openstack/issues/117)

**Merged pull requests:**

- 2.2.0 [\#128](https://github.com/test-kitchen/kitchen-openstack/pull/128) ([jjasghar](https://github.com/jjasghar))

* 2.2.0 ([829dd78e](https://github.com/test-kitchen/kitchen-openstack/commit/829dd78e))

## [2.2.0.pre.1](https://github.com/test-kitchen/kitchen-openstack/tree/v2.2.0.pre.1) (2015-11-23)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.1.1...v2.2.0.pre.1)

**Merged pull requests:**

- Updated README with key\_name issue. [\#127](https://github.com/test-kitchen/kitchen-openstack/pull/127) ([jjasghar](https://github.com/jjasghar))
- Use OpenStack models for waiting for conditions [\#120](https://github.com/test-kitchen/kitchen-openstack/pull/120) ([carpnick](https://github.com/carpnick))

* inital 2.2.0.pre.1 ([0885ba7b](https://github.com/test-kitchen/kitchen-openstack/commit/0885ba7b))

## [2.1.1](https://github.com/test-kitchen/kitchen-openstack/tree/v2.1.1) (2015-11-03)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.1.0...v2.1.1)

**Merged pull requests:**

- 2.1.1 [\#125](https://github.com/test-kitchen/kitchen-openstack/pull/125) ([jjasghar](https://github.com/jjasghar))
- Ohai hint file is now created with the correct encoding on Windows [\#124](https://github.com/test-kitchen/kitchen-openstack/pull/124) ([stuartpreston](https://github.com/stuartpreston))
- Added info about user\_data [\#121](https://github.com/test-kitchen/kitchen-openstack/pull/121) ([jjasghar](https://github.com/jjasghar))

* updated changelog to generated changelog ([8a4e8709](https://github.com/test-kitchen/kitchen-openstack/commit/8a4e8709))

## [2.1.0](https://github.com/test-kitchen/kitchen-openstack/tree/v2.1.0) (2015-10-19)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.1.0.pre.1...v2.1.0)

* 2.1.0 release ([dfa246a1](https://github.com/test-kitchen/kitchen-openstack/commit/dfa246a1))

## [2.1.0.pre.1](https://github.com/test-kitchen/kitchen-openstack/tree/v2.1.0.pre.1) (2015-10-13)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.1.0.pre...v2.1.0.pre.1)

**Implemented enhancements:**

- Clean Up README [\#109](https://github.com/test-kitchen/kitchen-openstack/issues/109)

**Fixed bugs:**


**Merged pull requests:**

- Converting to dots [\#115](https://github.com/test-kitchen/kitchen-openstack/pull/115) ([jjasghar](https://github.com/jjasghar))

* roll another dev release ([ae2d1e3e](https://github.com/test-kitchen/kitchen-openstack/commit/ae2d1e3e))

## [2.1.0.pre](https://github.com/test-kitchen/kitchen-openstack/tree/v2.1.0.pre) (2015-10-07)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.0.0...v2.1.0.pre)

**Merged pull requests:**

- updated license links and data. [\#112](https://github.com/test-kitchen/kitchen-openstack/pull/112) ([jjasghar](https://github.com/jjasghar))
- New README [\#111](https://github.com/test-kitchen/kitchen-openstack/pull/111) ([jjasghar](https://github.com/jjasghar))
- Fail action when network info isn't available [\#110](https://github.com/test-kitchen/kitchen-openstack/pull/110) ([BobbyRyterski](https://github.com/BobbyRyterski))
- Wait for network info in get\_ip [\#108](https://github.com/test-kitchen/kitchen-openstack/pull/108) ([BobbyRyterski](https://github.com/BobbyRyterski))
- Refactor get\_ip [\#107](https://github.com/test-kitchen/kitchen-openstack/pull/107) ([BobbyRyterski](https://github.com/BobbyRyterski))
- 2.1.0 [\#106](https://github.com/test-kitchen/kitchen-openstack/pull/106) ([jjasghar](https://github.com/jjasghar))

* Merge branch '2.1.0' ([1094eed0](https://github.com/test-kitchen/kitchen-openstack/commit/1094eed0))
* Merge branch 'master' of github.com:test-kitchen/kitchen-openstack y this merge is necessary, ([d55e4072](https://github.com/test-kitchen/kitchen-openstack/commit/d55e4072))

## [2.0.0](https://github.com/test-kitchen/kitchen-openstack/tree/v2.0.0) (2015-09-30)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.0.0.dev.4...v2.0.0)

* 2.0.0 Release ([35b15cd7](https://github.com/test-kitchen/kitchen-openstack/commit/35b15cd7))

## [2.0.0.dev.4](https://github.com/test-kitchen/kitchen-openstack/tree/v2.0.0.dev.4) (2015-09-23)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.0.0.dev.3...v2.0.0.dev.4)

**Merged pull requests:**

- fixup install ohai hints so the file is written with root privileges [\#104](https://github.com/test-kitchen/kitchen-openstack/pull/104) ([spion06](https://github.com/spion06))
- Readd key\_name to README [\#103](https://github.com/test-kitchen/kitchen-openstack/pull/103) ([BobbyRyterski](https://github.com/BobbyRyterski))
- Add transport ssh\_key note to README [\#102](https://github.com/test-kitchen/kitchen-openstack/pull/102) ([BobbyRyterski](https://github.com/BobbyRyterski))

* v2.0.0.dev.4 ([49124340](https://github.com/test-kitchen/kitchen-openstack/commit/49124340))

## [2.0.0.dev.3](https://github.com/test-kitchen/kitchen-openstack/tree/v2.0.0.dev.3) (2015-09-21)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.0.0.dev.2...v2.0.0.dev.3)

**Implemented enhancements:**

- Support all Fog OpenStack options [\#98](https://github.com/test-kitchen/kitchen-openstack/pull/98) ([BobbyRyterski](https://github.com/BobbyRyterski))

**Merged pull requests:**

- Don't create instance if name is already created [\#100](https://github.com/test-kitchen/kitchen-openstack/pull/100) ([dpetzel](https://github.com/dpetzel))
- Fix for issue 96 [\#97](https://github.com/test-kitchen/kitchen-openstack/pull/97) ([jjasghar](https://github.com/jjasghar))

* Updates for dev.3 ([555925fa](https://github.com/test-kitchen/kitchen-openstack/commit/555925fa))

## [2.0.0.dev.2](https://github.com/test-kitchen/kitchen-openstack/tree/v2.0.0.dev.2) (2015-09-16)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.0.0.dev.1...v2.0.0.dev.2)

**Merged pull requests:**

- Load openstack\_version for plugin\_version [\#99](https://github.com/test-kitchen/kitchen-openstack/pull/99) ([BobbyRyterski](https://github.com/BobbyRyterski))

* Bumped version. ([3e842c7d](https://github.com/test-kitchen/kitchen-openstack/commit/3e842c7d))

## [2.0.0.dev.1](https://github.com/test-kitchen/kitchen-openstack/tree/v2.0.0.dev.1) (2015-09-10)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v2.0.0.dev...v2.0.0.dev.1)

**Merged pull requests:**

- 2.0.0.dev.1 [\#95](https://github.com/test-kitchen/kitchen-openstack/pull/95) ([jjasghar](https://github.com/jjasghar))

## [2.0.0.dev](https://github.com/test-kitchen/kitchen-openstack/tree/v2.0.0.dev) (2015-09-09)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.9.0.dev...v2.0.0.dev)

**Implemented enhancements:**

- Test Kitchen Openstack doesn't support block storage\(volumes\) [\#75](https://github.com/test-kitchen/kitchen-openstack/issues/75)
- Enhancement: Windows Support [\#45](https://github.com/test-kitchen/kitchen-openstack/issues/45)

**Merged pull requests:**

- added rubygem tasks [\#94](https://github.com/test-kitchen/kitchen-openstack/pull/94) ([jjasghar](https://github.com/jjasghar))
- Kitchen::Base and Windows support [\#92](https://github.com/test-kitchen/kitchen-openstack/pull/92) ([jjasghar](https://github.com/jjasghar))

* Merge branch 'new_kitchen_openstack' ([3785039b](https://github.com/test-kitchen/kitchen-openstack/commit/3785039b))

## [1.9.0.dev](https://github.com/test-kitchen/kitchen-openstack/tree/v1.9.0.dev) (2015-09-03)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.8.1...v1.9.0.dev)

**Merged pull requests:**

- Ability to control the order of IP to connect to [\#89](https://github.com/test-kitchen/kitchen-openstack/pull/89) ([ytsarev](https://github.com/ytsarev))

* Merge branch 'checking_ssh_key_race' ([1836f236](https://github.com/test-kitchen/kitchen-openstack/commit/1836f236))
* Set dev 1.9.0 release ([eb38d016](https://github.com/test-kitchen/kitchen-openstack/commit/eb38d016))
* added rubygem tasks ([0e4c4ad0](https://github.com/test-kitchen/kitchen-openstack/commit/0e4c4ad0))

## [1.8.1](https://github.com/test-kitchen/kitchen-openstack/tree/v1.8.1) (2015-07-22)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.3.1...v1.8.1)

**Implemented enhancements:**

- Yo, dawg, I heard you like Test Kitchen... [\#30](https://github.com/test-kitchen/kitchen-openstack/issues/30)

**Merged pull requests:**

- Fail if required key information can't be found [\#88](https://github.com/test-kitchen/kitchen-openstack/pull/88) ([RoboticCheese](https://github.com/RoboticCheese))
- Fix for the readme.md [\#87](https://github.com/test-kitchen/kitchen-openstack/pull/87) ([jjasghar](https://github.com/jjasghar))
- Issue 82 [\#86](https://github.com/test-kitchen/kitchen-openstack/pull/86) ([jjasghar](https://github.com/jjasghar))
- Added a check for ssh key authetication [\#85](https://github.com/test-kitchen/kitchen-openstack/pull/85) ([jjasghar](https://github.com/jjasghar))

* Update README.md for chefdk installation ([#83](https://github.com/test-kitchen/kitchen-openstack/pull/83)) ([8aaee845](https://github.com/test-kitchen/kitchen-openstack/commit/8aaee845))
* Use shields.io so the badges all match ([0ce0cd14](https://github.com/test-kitchen/kitchen-openstack/commit/0ce0cd14))

## [1.8.0](https://github.com/test-kitchen/kitchen-openstack/tree/v1.8.0) (2015-04-09)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.7.1...v1.8.0)

**Merged pull requests:**

- Update tests for newer TK [\#76](https://github.com/test-kitchen/kitchen-openstack/pull/76) ([RoboticCheese](https://github.com/RoboticCheese))
- Respect a configured password when setting up SSH [\#70](https://github.com/test-kitchen/kitchen-openstack/pull/70) ([RoboticCheese](https://github.com/RoboticCheese))

* Add support for block device storage volumes ([64bf34ff](https://github.com/test-kitchen/kitchen-openstack/commit/64bf34ff))
* Lock to Kitchen pre-1.3 until issues can be fixed ([6dc773ba](https://github.com/test-kitchen/kitchen-openstack/commit/6dc773ba))
* Split Volume class out to its own file ([5b272dd7](https://github.com/test-kitchen/kitchen-openstack/commit/5b272dd7))

## [1.7.1](https://github.com/test-kitchen/kitchen-openstack/tree/v1.7.1) (2015-01-08)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.7.0...v1.7.1)

* Respect a configured password when setting up SSH ([#70](https://github.com/test-kitchen/kitchen-openstack/pull/70)) ([eea1144b](https://github.com/test-kitchen/kitchen-openstack/commit/eea1144b))

## [1.7.0](https://github.com/test-kitchen/kitchen-openstack/tree/v1.7.0) (2014-10-26)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.6.1...v1.7.0)

**Merged pull requests:**

- Support a timed sleep for SSH edge cases [\#66](https://github.com/test-kitchen/kitchen-openstack/pull/66) ([RoboticCheese](https://github.com/RoboticCheese))
- Availability zone support+ [\#65](https://github.com/test-kitchen/kitchen-openstack/pull/65) ([RoboticCheese](https://github.com/RoboticCheese))
- Add server\_name\_prefix semi-random naming with some known prefix [\#63](https://github.com/test-kitchen/kitchen-openstack/pull/63) ([ftclausen](https://github.com/ftclausen))

* Update CHANGELOG ([5d7cf4c7](https://github.com/test-kitchen/kitchen-openstack/commit/5d7cf4c7))

## [1.6.1](https://github.com/test-kitchen/kitchen-openstack/tree/v1.6.1) (2014-10-07)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/1.0.0...v1.6.1)

**Merged pull requests:**

- Renamed 'init\_config' method to resolve conflicting method name with lat... [\#60](https://github.com/test-kitchen/kitchen-openstack/pull/60) ([stevejmason](https://github.com/stevejmason))

## [1.6.0](https://github.com/test-kitchen/kitchen-openstack/tree/v1.6.0) (2014-09-04)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.5.3...v1.6.0)

**Merged pull requests:**

- \#55 + shut Rubocop up for now [\#59](https://github.com/test-kitchen/kitchen-openstack/pull/59) ([RoboticCheese](https://github.com/RoboticCheese))
- Fix \#54; prevent errors on non-login shells [\#58](https://github.com/test-kitchen/kitchen-openstack/pull/58) ([RoboticCheese](https://github.com/RoboticCheese))
- \#56 + drop Ruby 1.9.2 [\#57](https://github.com/test-kitchen/kitchen-openstack/pull/57) ([RoboticCheese](https://github.com/RoboticCheese))
- Select the first valid IP if all other checks fail [\#56](https://github.com/test-kitchen/kitchen-openstack/pull/56) ([jer](https://github.com/jer))
- Reverse the priority of floating\_ip & floating\_ip\_pool [\#55](https://github.com/test-kitchen/kitchen-openstack/pull/55) ([StaymanHou](https://github.com/StaymanHou))

## [1.5.3](https://github.com/test-kitchen/kitchen-openstack/tree/v1.5.3) (2014-08-01)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.5.2...v1.5.3)

**Merged pull requests:**

- Fix bad hostnames being generated [\#53](https://github.com/test-kitchen/kitchen-openstack/pull/53) ([RoboticCheese](https://github.com/RoboticCheese))
- Switch to Rubocop and clean up as much as possible [\#51](https://github.com/test-kitchen/kitchen-openstack/pull/51) ([RoboticCheese](https://github.com/RoboticCheese))

* s/latest/true/g in README for Chef ([f3cd712d](https://github.com/test-kitchen/kitchen-openstack/commit/f3cd712d))

## [1.5.2](https://github.com/test-kitchen/kitchen-openstack/tree/v1.5.2) (2014-05-31)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.5.0...v1.5.2)

**Merged pull requests:**

- Roboticcheese/fix server name length loop bug [\#50](https://github.com/test-kitchen/kitchen-openstack/pull/50) ([RoboticCheese](https://github.com/RoboticCheese))
- Hostname limit [\#49](https://github.com/test-kitchen/kitchen-openstack/pull/49) ([dschlenk](https://github.com/dschlenk))

* Update CHANGELOG for PR #49 ([fd7b50e1](https://github.com/test-kitchen/kitchen-openstack/commit/fd7b50e1))

## [1.5.0](https://github.com/test-kitchen/kitchen-openstack/tree/v1.5.0) (2014-05-23)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/0.10.0...v1.5.0)

**Merged pull requests:**

- Add OpenStack Ohai hints file [\#48](https://github.com/test-kitchen/kitchen-openstack/pull/48) ([dschlenk](https://github.com/dschlenk))

## [1.4.0](https://github.com/test-kitchen/kitchen-openstack/tree/v1.4.0) (2014-04-09)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/0.9.1...v1.4.0)

**Merged pull requests:**

- Use floating IP for ssh connection by default if defined or allocated from pool. [\#46](https://github.com/test-kitchen/kitchen-openstack/pull/46) ([dschlenk](https://github.com/dschlenk))

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.2.0...v1.3.1)
**Merged pull requests:**
- Update README.md for chefdk installation [\#83](https://github.com/test-kitchen/kitchen-openstack/pull/83) ([kcd83](https://github.com/kcd83))
* Add metadata support ([#166](https://github.com/test-kitchen/kitchen-openstack/pull/166)) ([cd015cb5](https://github.com/test-kitchen/kitchen-openstack/commit/cd015cb5))
* Updated travis.yml settings ([1f8701db](https://github.com/test-kitchen/kitchen-openstack/commit/1f8701db))
* from mtougeron/feature-add-openstack-ohai-hint ([#171](https://github.com/test-kitchen/kitchen-openstack/pull/171)) ([6aaee4f5](https://github.com/test-kitchen/kitchen-openstack/commit/6aaee4f5))
* from chef/vj/adding_floating_ip_commands ([#170](https://github.com/test-kitchen/kitchen-openstack/pull/170)) ([d088b4d8](https://github.com/test-kitchen/kitchen-openstack/commit/d088b4d8))
* Merge branch 'chef-vj/adding_floating_ip_commands' ([4858044e](https://github.com/test-kitchen/kitchen-openstack/commit/4858044e))
* 1.3.0 release ([c66985c3](https://github.com/test-kitchen/kitchen-openstack/commit/c66985c3))
* Updated for the new version of knife-cloud ([0cea9eae](https://github.com/test-kitchen/kitchen-openstack/commit/0cea9eae))

## [1.3.0](https://github.com/test-kitchen/kitchen-openstack/tree/v1.3.0) (2014-03-09)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/0.9.0...v1.3.0)

* Add Coveralls support, maybe ([#32](https://github.com/test-kitchen/kitchen-openstack/pull/32)) ([79c45635](https://github.com/test-kitchen/kitchen-openstack/commit/79c45635))
* Update URLs to test-kitchen org ([#35](https://github.com/test-kitchen/kitchen-openstack/pull/35)) ([7b128cc0](https://github.com/test-kitchen/kitchen-openstack/commit/7b128cc0))
* added support to assign security groups ([#37](https://github.com/test-kitchen/kitchen-openstack/pull/37)) ([cc3e02d4](https://github.com/test-kitchen/kitchen-openstack/commit/cc3e02d4))
* Update README/CHANGELOG/version for release ([bf908cec](https://github.com/test-kitchen/kitchen-openstack/commit/bf908cec))
* added basic support for networks ([#39](https://github.com/test-kitchen/kitchen-openstack/pull/39)) ([cec6cefa](https://github.com/test-kitchen/kitchen-openstack/commit/cec6cefa))
* Update CHANGELOG ([ed1cb5f0](https://github.com/test-kitchen/kitchen-openstack/commit/ed1cb5f0))
* Wait ssh connection for the specified port after the instance is created ([#41](https://github.com/test-kitchen/kitchen-openstack/pull/41)) ([afae5d41](https://github.com/test-kitchen/kitchen-openstack/commit/afae5d41))
* option for user_data to be passed to openstack ([#40](https://github.com/test-kitchen/kitchen-openstack/pull/40)) ([14153f27](https://github.com/test-kitchen/kitchen-openstack/commit/14153f27))

## [1.2.0](https://github.com/test-kitchen/kitchen-openstack/tree/v1.2.0) (2015-06-18)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.2.0.rc2...v1.2.0)

* Use new ohai config context ([#165](https://github.com/test-kitchen/kitchen-openstack/pull/165)) ([2d8e43d3](https://github.com/test-kitchen/kitchen-openstack/commit/2d8e43d3))
* updated version ([a9d51ea9](https://github.com/test-kitchen/kitchen-openstack/commit/a9d51ea9))

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.8.0...v1.2.0.rc1)
* Defer ssh key handling to transport. ([#154](https://github.com/test-kitchen/kitchen-openstack/pull/154)) ([5e255693](https://github.com/test-kitchen/kitchen-openstack/commit/5e255693))
* Expose excon timeout configuration ([#156](https://github.com/test-kitchen/kitchen-openstack/pull/156)) ([2285ed18](https://github.com/test-kitchen/kitchen-openstack/commit/2285ed18))
* from chef/update_email_addresses ([#157](https://github.com/test-kitchen/kitchen-openstack/pull/157)) ([ea6afff5](https://github.com/test-kitchen/kitchen-openstack/commit/ea6afff5))
* Dynamically allocate Floating IP for the test server. ([#155](https://github.com/test-kitchen/kitchen-openstack/pull/155)) ([aedc58cd](https://github.com/test-kitchen/kitchen-openstack/commit/aedc58cd))
* Added ability to specify metadata on the create_server call ([#148](https://github.com/test-kitchen/kitchen-openstack/pull/148)) ([9977ee8e](https://github.com/test-kitchen/kitchen-openstack/commit/9977ee8e))
* Update README.md ([8d0a8a0a](https://github.com/test-kitchen/kitchen-openstack/commit/8d0a8a0a))
* Uuids ([#159](https://github.com/test-kitchen/kitchen-openstack/pull/159)) ([baf03662](https://github.com/test-kitchen/kitchen-openstack/commit/baf03662))
* Merge branch 'karcaw-vol_sched_1.0.0work' into 1.2.0 ([c6318e74](https://github.com/test-kitchen/kitchen-openstack/commit/c6318e74))
* Merge branch 'elbandito-master' into 1.2.0 ([eb748b4e](https://github.com/test-kitchen/kitchen-openstack/commit/eb748b4e))
* Inital merge and taging of 1.2.0.rc1 ([d6da57f0](https://github.com/test-kitchen/kitchen-openstack/commit/d6da57f0))
* Ready for the pre release ([0859d364](https://github.com/test-kitchen/kitchen-openstack/commit/0859d364))
* Gotta love randomly deleting code.... ([f5720e40](https://github.com/test-kitchen/kitchen-openstack/commit/f5720e40))

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.2.0.rc1...v1.2.0.rc2)
* Added a more accurate summary of the gem ([05c39a05](https://github.com/test-kitchen/kitchen-openstack/commit/05c39a05))
* Added the updated gem. ([9305f756](https://github.com/test-kitchen/kitchen-openstack/commit/9305f756))
* Bumping RC version ([642ccb62](https://github.com/test-kitchen/kitchen-openstack/commit/642ccb62))
* updated per the new knife-cloud gem rc release ([48ce2e4b](https://github.com/test-kitchen/kitchen-openstack/commit/48ce2e4b))

## [1.1.0](https://github.com/test-kitchen/kitchen-openstack/tree/v1.1.0) (2013-12-07)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.0.0...v1.1.0)

**Fixed bugs:**

- config\[:name\] is now used by Test Kitchen... [\#29](https://github.com/test-kitchen/kitchen-openstack/issues/29)

**Merged pull requests:**

- Fix \#29 - Rename 'name' option to 'server\_name' [\#31](https://github.com/test-kitchen/kitchen-openstack/pull/31) ([RoboticCheese](https://github.com/RoboticCheese))

* Bump for 1.1.0 release ([b99956db](https://github.com/test-kitchen/kitchen-openstack/commit/b99956db))

## [1.0.0](https://github.com/test-kitchen/kitchen-openstack/tree/v1.0.0) (2013-10-16)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/1.0.0.rc2...1.0.0)

* Floating ip support ([#14](https://github.com/test-kitchen/kitchen-openstack/pull/14)) ([ae067f16](https://github.com/test-kitchen/kitchen-openstack/commit/ae067f16))
* SSH key tweaks ([#15](https://github.com/test-kitchen/kitchen-openstack/pull/15)) ([535ce450](https://github.com/test-kitchen/kitchen-openstack/commit/535ce450))
* Refactoring and updating unit tests ([#25](https://github.com/test-kitchen/kitchen-openstack/pull/25)) ([7bfb8cf8](https://github.com/test-kitchen/kitchen-openstack/commit/7bfb8cf8))
* Add Version and Dep badges ([c0c30a45](https://github.com/test-kitchen/kitchen-openstack/commit/c0c30a45))
* specify image or flavor using the name or regular expression ([#26](https://github.com/test-kitchen/kitchen-openstack/pull/26)) ([c826b2aa](https://github.com/test-kitchen/kitchen-openstack/commit/c826b2aa))
* Unify style under Tailor until ready to replace with Rubocop ([7a47a4d7](https://github.com/test-kitchen/kitchen-openstack/commit/7a47a4d7))
* Update CHANGELOG ([e3a39ce1](https://github.com/test-kitchen/kitchen-openstack/commit/e3a39ce1))
* synchronize lookup and assignment of floating ip ([#27](https://github.com/test-kitchen/kitchen-openstack/pull/27)) ([c93148f2](https://github.com/test-kitchen/kitchen-openstack/commit/c93148f2))

* 1.0.0 Release! ([dcc05f1c](https://github.com/test-kitchen/kitchen-openstack/commit/dcc05f1c))

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

\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
* first pass at knife OpenStack plugin ([0449e574](https://github.com/test-kitchen/kitchen-openstack/commit/0449e574))
* updated description in README and gemspec ([7f16c0cd](https://github.com/test-kitchen/kitchen-openstack/commit/7f16c0cd))
* print final run list using config[:run_list] not @name_args ([dc96b9cf](https://github.com/test-kitchen/kitchen-openstack/commit/dc96b9cf))
* remove dependency on chef ([008bca68](https://github.com/test-kitchen/kitchen-openstack/commit/008bca68))
* refactored to use knife ui class..kicked highline dependency to the curb ([8fcef439](https://github.com/test-kitchen/kitchen-openstack/commit/8fcef439))
* bumped version for release ([c1c773e6](https://github.com/test-kitchen/kitchen-openstack/commit/c1c773e6))

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.5.1...v0.5.2)
* Merge branch 'CHEF-2191' ([38d82fcd](https://github.com/test-kitchen/kitchen-openstack/commit/38d82fcd))
* Merge branch 'CHEF-2192' ([275778cd](https://github.com/test-kitchen/kitchen-openstack/commit/275778cd))
* removed phantom line in the README ([b8fe43af](https://github.com/test-kitchen/kitchen-openstack/commit/b8fe43af))
* removed some legacy vpc related code carried over from knife-ec2 ([2e1fc2de](https://github.com/test-kitchen/kitchen-openstack/commit/2e1fc2de))
* bumpted version number for release ([8b0b9f37](https://github.com/test-kitchen/kitchen-openstack/commit/8b0b9f37))

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.5.2...v0.5.3)
* [CHEF-2182] changing fog dependency to the 0.7.x series as it works correctly with excon 0.6.1 ([1418827c](https://github.com/test-kitchen/kitchen-openstack/commit/1418827c))

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.5.3...v0.5.4)
* Merge branch 'CHEF-2194' ([042b5754](https://github.com/test-kitchen/kitchen-openstack/commit/042b5754))
* print out environment at end of bootstrap ([dddf9a6c](https://github.com/test-kitchen/kitchen-openstack/commit/dddf9a6c))
* print _default if no environment is passed to create subcommand ([3dc9a366](https://github.com/test-kitchen/kitchen-openstack/commit/3dc9a366))
* short option for image is now -I ([7bc41484](https://github.com/test-kitchen/kitchen-openstack/commit/7bc41484))
* [CHEF-2195] bootstrap a specific version of Chef ([13ec706e](https://github.com/test-kitchen/kitchen-openstack/commit/13ec706e))
* version 0.5.4 ([bfd9a318](https://github.com/test-kitchen/kitchen-openstack/commit/bfd9a318))

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.5.4...v0.6.0)
* [CHEF-2338] catch EPERM error thrown under cygwin ([415ee162](https://github.com/test-kitchen/kitchen-openstack/commit/415ee162))
* from agoddard/patch-1 ([#4](https://github.com/test-kitchen/kitchen-openstack/pull/4)) ([71f4bbab](https://github.com/test-kitchen/kitchen-openstack/commit/71f4bbab))
* remove dependcy on net-ssh and net-ssh-multi..neither is access directly in plugin ([b431aa3f](https://github.com/test-kitchen/kitchen-openstack/commit/b431aa3f))
* [KNIFE_OPENSTACK-1] stale hostnames make me sad ([677653e7](https://github.com/test-kitchen/kitchen-openstack/commit/677653e7))
* refactor shared logic into base module ([fadccc89](https://github.com/test-kitchen/kitchen-openstack/commit/fadccc89))
* only use sudo for bootstrap on non-root users ([95b3aeb3](https://github.com/test-kitchen/kitchen-openstack/commit/95b3aeb3))
* improve validation ([5bc04644](https://github.com/test-kitchen/kitchen-openstack/commit/5bc04644))
* leverage msq_pair method from base module ([b5ed2abe](https://github.com/test-kitchen/kitchen-openstack/commit/b5ed2abe))
* [KNIFE_OPENSTACK-2] ensure value is string before empty? check ([a5c1a9d5](https://github.com/test-kitchen/kitchen-openstack/commit/a5c1a9d5))
* Fix knife-openstack server list to compensate for bad Fog output ([d232d6a5](https://github.com/test-kitchen/kitchen-openstack/commit/d232d6a5))
* fix bad if statement ([53611b33](https://github.com/test-kitchen/kitchen-openstack/commit/53611b33))
* converted to markdown, expect to use inline images eventually ([3e0b2655](https://github.com/test-kitchen/kitchen-openstack/commit/3e0b2655))
* fixed markdown link ([e6e7c81b](https://github.com/test-kitchen/kitchen-openstack/commit/e6e7c81b))
* markdown link done right ([3ace81c1](https://github.com/test-kitchen/kitchen-openstack/commit/3ace81c1))
* added self as an author and bumped fog version ([b15f58e1](https://github.com/test-kitchen/kitchen-openstack/commit/b15f58e1))
* works with updated Fog, now using name as well ([d83128dc](https://github.com/test-kitchen/kitchen-openstack/commit/d83128dc))
* architecture isn't an option, but Cores should be added ([bb20ff4e](https://github.com/test-kitchen/kitchen-openstack/commit/bb20ff4e))
* updated for the OpenStack API ([9010b897](https://github.com/test-kitchen/kitchen-openstack/commit/9010b897))
* first column is ID and sorted since name is not unique ([e05022cb](https://github.com/test-kitchen/kitchen-openstack/commit/e05022cb))
* kernel, architecture, root store and location are not currently supported ([aaa9810b](https://github.com/test-kitchen/kitchen-openstack/commit/aaa9810b))
* removed architecture and cores for now ([4eb11860](https://github.com/test-kitchen/kitchen-openstack/commit/4eb11860))
* remove public_key until it works :( ([bc87fcdb](https://github.com/test-kitchen/kitchen-openstack/commit/bc87fcdb))
* removed unsupported features to match current state of plugin ([76c1b185](https://github.com/test-kitchen/kitchen-openstack/commit/76c1b185))
* now works with osapi and warns on ids that aren't found ([ee8f8845](https://github.com/test-kitchen/kitchen-openstack/commit/ee8f8845))
* support creating servers with fog changes ([202d79f5](https://github.com/test-kitchen/kitchen-openstack/commit/202d79f5))
* added virtual cpus to 'knife openstack flavor list' ([b289f203](https://github.com/test-kitchen/kitchen-openstack/commit/b289f203))
* use public_ip_address instead of dns_name ([bcbb81a6](https://github.com/test-kitchen/kitchen-openstack/commit/bcbb81a6))
* fixed build instructions, proper bootstrap commands and added the TODO list ([404d701c](https://github.com/test-kitchen/kitchen-openstack/commit/404d701c))
* chef-full is the new default for bootstrapping ([932cfffd](https://github.com/test-kitchen/kitchen-openstack/commit/932cfffd))
* fix for KNIFE_OPENSTACK-5 ([b88c90fb](https://github.com/test-kitchen/kitchen-openstack/commit/b88c90fb))
* KNIFE_OPENSTACK-5 explicit dependencies ([493a7c60](https://github.com/test-kitchen/kitchen-openstack/commit/493a7c60))
* fixed KNIFE_OPENSTACK-6 ([48b9bc74](https://github.com/test-kitchen/kitchen-openstack/commit/48b9bc74))
* added a CHANGELOG.md for tracking version history ([2468fe97](https://github.com/test-kitchen/kitchen-openstack/commit/2468fe97))
* chef-full is now default bootstrap template ([df7c3415](https://github.com/test-kitchen/kitchen-openstack/commit/df7c3415))
* moving to mainline fog ([330fc23d](https://github.com/test-kitchen/kitchen-openstack/commit/330fc23d))
* merge Rob Hirschfeld's tenant patch ([cea1e3f8](https://github.com/test-kitchen/kitchen-openstack/commit/cea1e3f8))
* update to Rob Hirschfeld's tenant patch ([20df0c8b](https://github.com/test-kitchen/kitchen-openstack/commit/20df0c8b))
* actually using the Tenant Name and openstack_tenant is optional ([8774782f](https://github.com/test-kitchen/kitchen-openstack/commit/8774782f))
* openstack_tenant now supported ([25eb9249](https://github.com/test-kitchen/kitchen-openstack/commit/25eb9249))
* Add :openstack_tenant to connection ([b13f833d](https://github.com/test-kitchen/kitchen-openstack/commit/b13f833d))
* Addd :openstack_tenant to connection in server_create, fix output flavor and image ids ([44bad7c6](https://github.com/test-kitchen/kitchen-openstack/commit/44bad7c6))
* no passwords in debugging ([76709dc6](https://github.com/test-kitchen/kitchen-openstack/commit/76709dc6))
* note that openstack_tenant is actually optional ([f04cdd05](https://github.com/test-kitchen/kitchen-openstack/commit/f04cdd05))
* debugging for server_create and openstack_tenant is optional ([a77232bd](https://github.com/test-kitchen/kitchen-openstack/commit/a77232bd))
* openstack_tenant recorded ([cf7ae1a7](https://github.com/test-kitchen/kitchen-openstack/commit/cf7ae1a7))
* still depends on mattray/fog patches ([d2ccffce](https://github.com/test-kitchen/kitchen-openstack/commit/d2ccffce))
* redundant debuggin ([89a74f75](https://github.com/test-kitchen/kitchen-openstack/commit/89a74f75))
* handle empty addresses and additional server states ([ed24650c](https://github.com/test-kitchen/kitchen-openstack/commit/ed24650c))
* initial purge support, doesn't work since node names don't match ID ([d6577740](https://github.com/test-kitchen/kitchen-openstack/commit/d6577740))
* initial floating ip support. Works but node still gets the public_ip_address from initial create ([bbfd922f](https://github.com/test-kitchen/kitchen-openstack/commit/bbfd922f))
* floating ip support, issues moved to CHANGELOG ([9289ff3d](https://github.com/test-kitchen/kitchen-openstack/commit/9289ff3d))
* first phase of populating /etc/chef/ohai/hints/openstack.json ([ca157eac](https://github.com/test-kitchen/kitchen-openstack/commit/ca157eac))
* preliminary Floating IP docs ([a2e1c369](https://github.com/test-kitchen/kitchen-openstack/commit/a2e1c369))
* fixes KNIFE_OPENSTACK-7 ([e861a705](https://github.com/test-kitchen/kitchen-openstack/commit/e861a705))
* floating IPs exposed with the new Ohai openstack plugin ([2d7ec2a7](https://github.com/test-kitchen/kitchen-openstack/commit/2d7ec2a7))
* names for nodes are now generated if not provided ([e50ca20d](https://github.com/test-kitchen/kitchen-openstack/commit/e50ca20d))
* Added support for  (via Lamont Granquist) ([d2e1c0c0](https://github.com/test-kitchen/kitchen-openstack/commit/d2e1c0c0))
* security groups are broken in fog, return to fixing this later ([e9705b60](https://github.com/test-kitchen/kitchen-openstack/commit/e9705b60))
* support for bootstrapping private networks with --private-network ([c0765ae5](https://github.com/test-kitchen/kitchen-openstack/commit/c0765ae5))
* proper options listed, a little floating IP clarification ([7e10572a](https://github.com/test-kitchen/kitchen-openstack/commit/7e10572a))
* support Chef 10.12 and Chef 0.10.x (and later) ([cd58e1e9](https://github.com/test-kitchen/kitchen-openstack/commit/cd58e1e9))
* same dependency as knife-rackspace and knife-ec2 ([e632522f](https://github.com/test-kitchen/kitchen-openstack/commit/e632522f))
* Fog published 1.4.0, ready to push to RubyGems ([05b8a68a](https://github.com/test-kitchen/kitchen-openstack/commit/05b8a68a))

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.6.0...v0.6.2)
* Merge branch '0.6.0' ([b7fb4add](https://github.com/test-kitchen/kitchen-openstack/commit/b7fb4add))
* Add guard around private_ip_address which might return nil in some configurations. ([f4cea07a](https://github.com/test-kitchen/kitchen-openstack/commit/f4cea07a))
* Guard against NoMethodError on nil in server_delete. ([843a3ad2](https://github.com/test-kitchen/kitchen-openstack/commit/843a3ad2))
* Be more optimistic about fog version constraint. ([9757a6b6](https://github.com/test-kitchen/kitchen-openstack/commit/9757a6b6))
* Update version and changelog for release. ([3beb56a4](https://github.com/test-kitchen/kitchen-openstack/commit/3beb56a4))

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.6.2...0.7.0)
* yet another state, this time 'shutoff' ([e59718d3](https://github.com/test-kitchen/kitchen-openstack/commit/e59718d3))
* use the hint with the bootstrap method instead of assuming the :personality works with the server.create method ([a6119fe1](https://github.com/test-kitchen/kitchen-openstack/commit/a6119fe1))
* 0.7.0 merge ([8b68b86e](https://github.com/test-kitchen/kitchen-openstack/commit/8b68b86e))
* 0.7.0 merge for KNIFE-248 ([3a6d7caf](https://github.com/test-kitchen/kitchen-openstack/commit/3a6d7caf))
* KNIFE-79 apparently no longer an issue ([07fe5411](https://github.com/test-kitchen/kitchen-openstack/commit/07fe5411))

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/0.7.0...v0.7.1)
* file permssions, how do they work? ([30e312c6](https://github.com/test-kitchen/kitchen-openstack/commit/30e312c6))

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.2.0...v0.8.0)
* KNIFE-221 merge ([b55dd9ac](https://github.com/test-kitchen/kitchen-openstack/commit/b55dd9ac))

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.4.0...v0.8.1)
* formatting cleanup of the CHANGELOG ([ad21fe25](https://github.com/test-kitchen/kitchen-openstack/commit/ad21fe25))
* KNIFE-296 and KNIFE-304 fixes ([256f76c1](https://github.com/test-kitchen/kitchen-openstack/commit/256f76c1))

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
* mark KNIFE-310 for next release, same fix as KNIFE-309 ([f5e6902d](https://github.com/test-kitchen/kitchen-openstack/commit/f5e6902d))
* check for empty server.image, indicating a boot from volume instead of an image ([feff96d8](https://github.com/test-kitchen/kitchen-openstack/commit/feff96d8))
* from opscode/adamed-knife-382 ([#71](https://github.com/test-kitchen/kitchen-openstack/pull/71)) ([8b8fd13c](https://github.com/test-kitchen/kitchen-openstack/commit/8b8fd13c))
* 0.9.0 merge ([7700edd9](https://github.com/test-kitchen/kitchen-openstack/commit/7700edd9))
* Merge branch 'master' of github.com:opscode/knife-openstack ([a31a81c7](https://github.com/test-kitchen/kitchen-openstack/commit/a31a81c7))
* you're gonna want to test those things ([ee01740d](https://github.com/test-kitchen/kitchen-openstack/commit/ee01740d))

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.3.0...0.9.1)
* updated CHANGELOG to reflect all 0.9.0 tickets ([46f02aa5](https://github.com/test-kitchen/kitchen-openstack/commit/46f02aa5))
* KNIFE-462 merge ([0ab5a9fb](https://github.com/test-kitchen/kitchen-openstack/commit/0ab5a9fb))
* 0.9.1 release ([9ec96cff](https://github.com/test-kitchen/kitchen-openstack/commit/9ec96cff))

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.4.0...0.10.0)
* icky fix for KNIFE-467 ([2130f33c](https://github.com/test-kitchen/kitchen-openstack/commit/2130f33c))
* Added coverage for --bootstrap-network, --private-network and --no-network ([ff5f57d1](https://github.com/test-kitchen/kitchen-openstack/commit/ff5f57d1))
* 0.10.0 release ([43cab460](https://github.com/test-kitchen/kitchen-openstack/commit/43cab460))
* last note for 0.10.0 release ([3607e606](https://github.com/test-kitchen/kitchen-openstack/commit/3607e606))

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v1.6.0...1.0.0.rc1)
* Fix #29 - Rename 'name' option to 'server_name' ([#31](https://github.com/test-kitchen/kitchen-openstack/pull/31)) ([f5c96e5d](https://github.com/test-kitchen/kitchen-openstack/commit/f5c96e5d))
* added support to assign security groups ([#37](https://github.com/test-kitchen/kitchen-openstack/pull/37)) ([456ff9e4](https://github.com/test-kitchen/kitchen-openstack/commit/456ff9e4))
* Allow to specify networks to which NICs will be connected when creating VM ([#38](https://github.com/test-kitchen/kitchen-openstack/pull/38)) ([4bececdb](https://github.com/test-kitchen/kitchen-openstack/commit/4bececdb))
* option for user_data to be passed to openstack ([#40](https://github.com/test-kitchen/kitchen-openstack/pull/40)) ([196a65a7](https://github.com/test-kitchen/kitchen-openstack/commit/196a65a7))
* Use floating IP for ssh connection by default if defined or allocated from pool. ([#46](https://github.com/test-kitchen/kitchen-openstack/pull/46)) ([fe25f359](https://github.com/test-kitchen/kitchen-openstack/commit/fe25f359))
* from opscode/adamed-oc-9368 ([#52](https://github.com/test-kitchen/kitchen-openstack/pull/52)) ([87407099](https://github.com/test-kitchen/kitchen-openstack/commit/87407099))
* from opscode/adamed-oc-9390 ([#54](https://github.com/test-kitchen/kitchen-openstack/pull/54)) ([503e0d3b](https://github.com/test-kitchen/kitchen-openstack/commit/503e0d3b))
* Add server_name_prefix semi-random naming with some known prefix ([#63](https://github.com/test-kitchen/kitchen-openstack/pull/63)) ([394fefd2](https://github.com/test-kitchen/kitchen-openstack/commit/394fefd2))
* from opscode/adamed-oc-9430 ([#67](https://github.com/test-kitchen/kitchen-openstack/pull/67)) ([fd4793f3](https://github.com/test-kitchen/kitchen-openstack/commit/fd4793f3))
* ssh password support & cmd env support & unique server-name support ([#68](https://github.com/test-kitchen/kitchen-openstack/pull/68)) ([68c9b920](https://github.com/test-kitchen/kitchen-openstack/commit/68c9b920))
* Availability zone support+ ([#65](https://github.com/test-kitchen/kitchen-openstack/pull/65)) ([f4d1d152](https://github.com/test-kitchen/kitchen-openstack/commit/f4d1d152))
* Remove text editor backup leftover ([5bec6166](https://github.com/test-kitchen/kitchen-openstack/commit/5bec6166))
* from ClogenyTechnologies/sid-oc-10924-fix-pri-network ([#81](https://github.com/test-kitchen/kitchen-openstack/pull/81)) ([582b1c6b](https://github.com/test-kitchen/kitchen-openstack/commit/582b1c6b))
* Environment variable configuration overrides ([#79](https://github.com/test-kitchen/kitchen-openstack/pull/79)) ([a3cc4543](https://github.com/test-kitchen/kitchen-openstack/commit/a3cc4543))
* from opscode/kd/OC-11204-abstractions ([#84](https://github.com/test-kitchen/kitchen-openstack/pull/84)) ([68b7a1e7](https://github.com/test-kitchen/kitchen-openstack/commit/68b7a1e7))
* Implement Openstack Block Device Storage ([#74](https://github.com/test-kitchen/kitchen-openstack/pull/74)) ([d156859f](https://github.com/test-kitchen/kitchen-openstack/commit/d156859f))
* from ClogenyTechnologies/ameya-oc-10520-server-show ([#73](https://github.com/test-kitchen/kitchen-openstack/pull/73)) ([6b29816b](https://github.com/test-kitchen/kitchen-openstack/commit/6b29816b))
* 2.0.0.dev.1 ([#95](https://github.com/test-kitchen/kitchen-openstack/pull/95)) ([3501106e](https://github.com/test-kitchen/kitchen-openstack/commit/3501106e))
* added rubygem tasks ([#94](https://github.com/test-kitchen/kitchen-openstack/pull/94)) ([9d627ff8](https://github.com/test-kitchen/kitchen-openstack/commit/9d627ff8))
* from ClogenyTechnologies/ameya-oc-11564-bootstrap-network ([#93](https://github.com/test-kitchen/kitchen-openstack/pull/93)) ([1e23d39b](https://github.com/test-kitchen/kitchen-openstack/commit/1e23d39b))
* Kitchen::Base and Windows support ([#92](https://github.com/test-kitchen/kitchen-openstack/pull/92)) ([ef518c24](https://github.com/test-kitchen/kitchen-openstack/commit/ef518c24))
* from ClogenyTechnologies/pd-OC-10611-custom-arguments ([#77](https://github.com/test-kitchen/kitchen-openstack/pull/77)) ([6f43d290](https://github.com/test-kitchen/kitchen-openstack/commit/6f43d290))
* Update tests for newer TK ([#76](https://github.com/test-kitchen/kitchen-openstack/pull/76)) ([f3fad9ec](https://github.com/test-kitchen/kitchen-openstack/commit/f3fad9ec))
* Fix for issue 96 ([#97](https://github.com/test-kitchen/kitchen-openstack/pull/97)) ([5702d019](https://github.com/test-kitchen/kitchen-openstack/commit/5702d019))
* Don't create instance if name is already created ([#100](https://github.com/test-kitchen/kitchen-openstack/pull/100)) ([afd92ed3](https://github.com/test-kitchen/kitchen-openstack/commit/afd92ed3))
* from opscode/pd-remove-excon-exception-spec-fix ([#105](https://github.com/test-kitchen/kitchen-openstack/pull/105)) ([1a8d4a91](https://github.com/test-kitchen/kitchen-openstack/commit/1a8d4a91))
* Wait for network info in get_ip ([#108](https://github.com/test-kitchen/kitchen-openstack/pull/108)) ([8aaa622c](https://github.com/test-kitchen/kitchen-openstack/commit/8aaa622c))
* Refactor get_ip ([#107](https://github.com/test-kitchen/kitchen-openstack/pull/107)) ([701fe773](https://github.com/test-kitchen/kitchen-openstack/commit/701fe773))
* Fail action when network info isn't available ([#110](https://github.com/test-kitchen/kitchen-openstack/pull/110)) ([ad4f91c1](https://github.com/test-kitchen/kitchen-openstack/commit/ad4f91c1))
* updated license links and data. ([#112](https://github.com/test-kitchen/kitchen-openstack/pull/112)) ([1961a705](https://github.com/test-kitchen/kitchen-openstack/commit/1961a705))
* from opscode/pd-add-network-id-option ([#114](https://github.com/test-kitchen/kitchen-openstack/pull/114)) ([4b63cbde](https://github.com/test-kitchen/kitchen-openstack/commit/4b63cbde))
* from opscode/ameya-metadata-option ([#109](https://github.com/test-kitchen/kitchen-openstack/pull/109)) ([86e0a29b](https://github.com/test-kitchen/kitchen-openstack/commit/86e0a29b))
* New README ([#111](https://github.com/test-kitchen/kitchen-openstack/pull/111)) ([c07ac386](https://github.com/test-kitchen/kitchen-openstack/commit/c07ac386))
* from opscode/sid-readme-cleanup ([#116](https://github.com/test-kitchen/kitchen-openstack/pull/116)) ([556491e5](https://github.com/test-kitchen/kitchen-openstack/commit/556491e5))
* from opscode/ameya-rspec-coverage-bootstrap-network ([#117](https://github.com/test-kitchen/kitchen-openstack/pull/117)) ([8888e372](https://github.com/test-kitchen/kitchen-openstack/commit/8888e372))
* 2.1.0 ([#106](https://github.com/test-kitchen/kitchen-openstack/pull/106)) ([abe68965](https://github.com/test-kitchen/kitchen-openstack/commit/abe68965))
* Added glance_cache_wait ([#119](https://github.com/test-kitchen/kitchen-openstack/pull/119)) ([97b0ff2b](https://github.com/test-kitchen/kitchen-openstack/commit/97b0ff2b))
* Use OpenStack models for waiting for conditions ([#120](https://github.com/test-kitchen/kitchen-openstack/pull/120)) ([bcb8b9fc](https://github.com/test-kitchen/kitchen-openstack/commit/bcb8b9fc))
* from opscode/sid-bootstrap-with-ssh-password ([#118](https://github.com/test-kitchen/kitchen-openstack/pull/118)) ([a9597566](https://github.com/test-kitchen/kitchen-openstack/commit/a9597566))
* Added info about user_data ([#121](https://github.com/test-kitchen/kitchen-openstack/pull/121)) ([0affdd94](https://github.com/test-kitchen/kitchen-openstack/commit/0affdd94))
* from opscode/pd-refactor-rspec-tests ([#122](https://github.com/test-kitchen/kitchen-openstack/pull/122)) ([849a04a9](https://github.com/test-kitchen/kitchen-openstack/commit/849a04a9))
* Updated README with key_name issue. ([#127](https://github.com/test-kitchen/kitchen-openstack/pull/127)) ([2ddb0410](https://github.com/test-kitchen/kitchen-openstack/commit/2ddb0410))
* Allow user to wait for log entry line(s) before doing transport check ([#126](https://github.com/test-kitchen/kitchen-openstack/pull/126)) ([010ed28b](https://github.com/test-kitchen/kitchen-openstack/commit/010ed28b))
* Update README.md ([cc1584b1](https://github.com/test-kitchen/kitchen-openstack/commit/cc1584b1))
* 2.2.0 ([#128](https://github.com/test-kitchen/kitchen-openstack/pull/128)) ([866ff714](https://github.com/test-kitchen/kitchen-openstack/commit/866ff714))
* 3.0.0 Release of kitchen-openstack ([#136](https://github.com/test-kitchen/kitchen-openstack/pull/136)) ([ce36bc65](https://github.com/test-kitchen/kitchen-openstack/commit/ce36bc65))
* from jjasghar/floating_ip_2 ([#141](https://github.com/test-kitchen/kitchen-openstack/pull/141)) ([fb9b0c73](https://github.com/test-kitchen/kitchen-openstack/commit/fb9b0c73))
* 1.0.0.rc1 and dependencies bump ([900c9f9a](https://github.com/test-kitchen/kitchen-openstack/commit/900c9f9a))
* no 1.8.7 ([37ca45fb](https://github.com/test-kitchen/kitchen-openstack/commit/37ca45fb))
* add Travis badge ([74edbe33](https://github.com/test-kitchen/kitchen-openstack/commit/74edbe33))
* add rake devel dep ([960ff909](https://github.com/test-kitchen/kitchen-openstack/commit/960ff909))
* from jjasghar/revert_change ([#6](https://github.com/test-kitchen/kitchen-openstack/pull/6)) ([0fd71e40](https://github.com/test-kitchen/kitchen-openstack/commit/0fd71e40))

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/1.0.0.rc1...1.0.0.rc2)
* Merge branch 'master' into 1.0.0.rc1 ([6f904dba](https://github.com/test-kitchen/kitchen-openstack/commit/6f904dba))
* Add config drive ([#144](https://github.com/test-kitchen/kitchen-openstack/pull/144)) ([a1529101](https://github.com/test-kitchen/kitchen-openstack/commit/a1529101))
* v3.1.0 ([#145](https://github.com/test-kitchen/kitchen-openstack/pull/145)) ([1e874600](https://github.com/test-kitchen/kitchen-openstack/commit/1e874600))

## [0.5.0](https://github.com/test-kitchen/kitchen-openstack/tree/v0.5.0) (2013-09-23)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.8.1...v0.5.0)

**Fixed bugs:**

- Ordering of server.addresses isn't guaranteed [\#17](https://github.com/test-kitchen/kitchen-openstack/issues/17)

**Merged pull requests:**

- Fix \#18 - Limit generated hostnames to 64 characters [\#20](https://github.com/test-kitchen/kitchen-openstack/pull/20) ([RoboticCheese](https://github.com/RoboticCheese))
- Fix \#16 and \#17 - Rewrite get\_ip method [\#19](https://github.com/test-kitchen/kitchen-openstack/pull/19) ([RoboticCheese](https://github.com/RoboticCheese))

## [0.4.0](https://github.com/test-kitchen/kitchen-openstack/tree/v0.4.0) (2013-06-06)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.8.0...v0.4.0)

**Merged pull requests:**

- support get\_ip from user-defined network group [\#12](https://github.com/test-kitchen/kitchen-openstack/pull/12) ([ainoya](https://github.com/ainoya))
- Care about ssh\_key option [\#11](https://github.com/test-kitchen/kitchen-openstack/pull/11) ([ainoya](https://github.com/ainoya))

* Update CHANGELOG, bump version for release ([747efe76](https://github.com/test-kitchen/kitchen-openstack/commit/747efe76))

## [0.2.0](https://github.com/test-kitchen/kitchen-openstack/tree/v0.2.0) (2013-05-11)

[Full Changelog](https://github.com/test-kitchen/kitchen-openstack/compare/v0.7.1...v0.2.0)

**Implemented enhancements:**

- Support an optional region setting [\#8](https://github.com/test-kitchen/kitchen-openstack/issues/8)
- Start building in TravisCI [\#6](https://github.com/test-kitchen/kitchen-openstack/issues/6)
- RSpec Tests\(?\) [\#5](https://github.com/test-kitchen/kitchen-openstack/issues/5)
- Use Project Name in Server Hostname [\#1](https://github.com/test-kitchen/kitchen-openstack/issues/1)

**Fixed bugs:**

- Servers Linger post-destroy [\#3](https://github.com/test-kitchen/kitchen-openstack/issues/3)

**Merged pull requests:**

- Add region and service name support [\#10](https://github.com/test-kitchen/kitchen-openstack/pull/10) ([RoboticCheese](https://github.com/RoboticCheese))
- Working overkill RSpec tests [\#9](https://github.com/test-kitchen/kitchen-openstack/pull/9) ([RoboticCheese](https://github.com/RoboticCheese))
- Jdh assorted enhancements [\#7](https://github.com/test-kitchen/kitchen-openstack/pull/7) ([RoboticCheese](https://github.com/RoboticCheese))
- Allow users to use keys uploaded to Openstack [\#2](https://github.com/test-kitchen/kitchen-openstack/pull/2) ([stevendanna](https://github.com/stevendanna))

* First commit, works in limited testing ([2c85d848](https://github.com/test-kitchen/kitchen-openstack/commit/2c85d848))
* Fix links in CHANGELOG.md ([31d38849](https://github.com/test-kitchen/kitchen-openstack/commit/31d38849))
* Ah, so that's how shortcut links work ([a5352d1c](https://github.com/test-kitchen/kitchen-openstack/commit/a5352d1c))
* Add CodeClimate ([4b7610c1](https://github.com/test-kitchen/kitchen-openstack/commit/4b7610c1))
* Update CHANGELOG ([df7e05d4](https://github.com/test-kitchen/kitchen-openstack/commit/df7e05d4))
