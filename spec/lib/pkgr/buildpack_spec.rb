require File.dirname(__FILE__) + '/../../spec_helper'
require 'fileutils'
require 'tmpdir'

describe Pkgr::Buildpack do
  def create_buildpack_repo
    @source_repo_dir = Dir.mktmpdir("buildpack-source")

    Dir.chdir(@source_repo_dir) do
      raise "git init failed" unless system("git init -q --initial-branch=main .")
      raise "git config user.email failed" unless system("git config user.email 'hello@world.com'")
      raise "git config user.name failed" unless system("git config user.name 'John Doe'")

      FileUtils.mkdir_p("bin")
      %w[detect compile release].each do |file|
        File.write("bin/#{file}", "#!/bin/sh\n")
      end
      File.write("TAG_MARKER", "tagged buildpack\n")
      raise "git add failed" unless system("git add bin TAG_MARKER")
      raise "git commit failed" unless system("git commit -q -m 'tag ref'")
      raise "git tag failed" unless system("git tag v1")

      raise "git checkout failed" unless system("git checkout -q -b universal")
      File.write("BRANCH_MARKER", "branch buildpack\n")
      raise "git add failed" unless system("git add BRANCH_MARKER")
      raise "git commit failed" unless system("git commit -q -m 'branch ref'")
      raise "git checkout failed" unless system("git checkout -q main")
    end

    @source_repo_dir
  end

  after do
    FileUtils.remove_entry_secure(@source_repo_dir) if @source_repo_dir && File.directory?(@source_repo_dir)
    Pkgr::Buildpack.buildpacks_cache_dir = nil
  end

  it "initializes with a url" do
    buildpack = Pkgr::Buildpack.new("http://some/url")
    expect(buildpack.url).to eq("http://some/url")
  end

  describe "#install" do
    before do
      Pkgr::Buildpack.buildpacks_cache_dir = Dir.mktmpdir
    end

    it "works with branches" do
      buildpack = Pkgr::Buildpack.new("#{create_buildpack_repo}#universal")
      expect do
        buildpack.install
      end.to_not raise_error
      expect(File.exist?(File.join(buildpack.dir, "BRANCH_MARKER"))).to be(true)
      expect(File.exist?(File.join(buildpack.dir, "TAG_MARKER"))).to be(true)
    end

    it "works with tags" do
      buildpack = Pkgr::Buildpack.new("#{create_buildpack_repo}#v1")
      expect do
        buildpack.install
      end.to_not raise_error
      expect(File.exist?(File.join(buildpack.dir, "TAG_MARKER"))).to be(true)
      expect(File.exist?(File.join(buildpack.dir, "BRANCH_MARKER"))).to be(false)
    end
  end

  describe ".buildpacks_cache_dir" do
    it "should have a default buildpacks cache directory" do
      expect(Pkgr::Buildpack.buildpacks_cache_dir).to eq(File.expand_path("~/.pkgr/buildpacks"))
      expect(File.directory?(Pkgr::Buildpack.buildpacks_cache_dir)).to eq(true)
    end

    it "should overwrite the default buildpacks cache directory" do
      dir = Dir.mktmpdir
      Pkgr::Buildpack.buildpacks_cache_dir = dir
      expect(Pkgr::Buildpack.buildpacks_cache_dir).to eq(dir)
    end
  end
end
