# frozen_string_literal: true

require "json"

# These examples deliberately read two files from the repository root, which is
# the one exemption to the "unit tests read nothing outside a Dir.mktmpdir"
# rule in AGENTS.md. The version number is duplicated across four places, and
# nothing but a test keeps them in step -- a release that ships a gemspec
# version disagreeing with the manifest is exactly the failure worth catching
# before it is tagged.
#
# Both reads degrade to a skip rather than a failure, so the suite still runs
# against a packaged gem or a filtered checkout where those files are absent.
RSpec.describe "Kitchen::Driver::OPENSTACK_VERSION" do
  subject(:version) { Kitchen::Driver::OPENSTACK_VERSION }

  # @param name [String] repo-root-relative filename
  # @return [String, nil] absolute path, or nil when it is not present
  def repo_file(name)
    path = File.expand_path("../../../#{name}", __dir__)
    File.exist?(path) ? path : nil
  end

  it "is a semantic version string" do
    expect(version).to match(/\A\d+\.\d+\.\d+\z/)
  end

  it "is what the gemspec publishes" do
    path = repo_file("kitchen-openstack.gemspec")
    skip "gemspec not present; not running from a source checkout" unless path

    expect(Gem::Specification.load(path).version.to_s).to eq(version)
  end

  it "is what the driver reports as its plugin version" do
    expect(Kitchen::Driver::Openstack.instance_variable_get(:@plugin_version)).to eq(version)
  end

  it "matches the release-please manifest" do
    path = repo_file(".release-please-manifest.json")
    skip "release-please manifest not present; not running from a source checkout" unless path

    expect(JSON.parse(File.read(path))["."]).to eq(version)
  end
end
