require File.dirname(__FILE__) + '/../../../spec_helper'

describe "modern distro target data" do
  let(:config) { Pkgr::Config.new }

  it "loads ubuntu 26.04 runtime and build dependencies" do
    distribution = Pkgr::Distributions::Ubuntu.new("26.04", config)

    expect(distribution.dependencies).to include("libssl3", "libev4")
    expect(distribution.build_dependencies).to include("libssl3")
    expect(distribution.buildpacks.last).to_not be_empty
  end

  it "loads centos 10 runtime and build dependencies" do
    distribution = Pkgr::Distributions::Centos.new("10", config)

    expect(distribution.dependencies).to include("libpq")
    expect(distribution.build_dependencies).to include("mariadb-devel")
    expect(distribution.buildpacks.last).to_not be_empty
  end

  it "loads sles 16 runtime and build dependencies" do
    distribution = Pkgr::Distributions::Sles.new("16", config)

    expect(distribution.dependencies).to include("openssl", "sqlite3")
    expect(distribution.build_dependencies).to include("postgresql-devel")
    expect(distribution.buildpacks.last).to_not be_empty
  end
end
