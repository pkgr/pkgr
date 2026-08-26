require "spec_helper"
require "open3"

describe "buildcurl recipes" do
  it "uses the hosted compiler when BUILDCURL_URL is not set" do
    Dir.mktmpdir do |directory|
      fake_bin = File.join(directory, "bin")
      arguments = File.join(directory, "curl-arguments")
      FileUtils.mkdir_p(fake_bin)
      File.write(File.join(fake_bin, "curl"), <<~SH)
        #!/usr/bin/env bash
        printf '%s\n' "$@" > "$CURL_ARGUMENTS"
      SH
      FileUtils.chmod(0o755, File.join(fake_bin, "curl"))

      wrapper = File.expand_path("../../images/buildcurl/bin/buildcurl", __dir__)
      _stdout, stderr, status = Open3.capture3(
        {
          "BUILDCURL_URL" => nil,
          "CURL_ARGUMENTS" => arguments,
          "PREFIX" => "/usr/local",
          "TARGET" => "ubuntu:24.04",
          "PATH" => "#{fake_bin}:#{ENV.fetch('PATH')}"
        },
        "/bin/bash",
        wrapper,
        "ruby",
        "3.3.10"
      )

      expect(status).to be_success, stderr
      expect(File.readlines(arguments, chomp: true)).to include(
        "https://buildcurl.com",
        "recipe=ruby",
        "version=3.3.10",
        "target=ubuntu:24.04",
        "prefix=/usr/local"
      )
    end
  end

  it "does not send a nested build token to the hosted compiler" do
    Dir.mktmpdir do |directory|
      fake_bin = File.join(directory, "bin")
      curl_called = File.join(directory, "curl-called")
      FileUtils.mkdir_p(fake_bin)
      File.write(File.join(fake_bin, "curl"), <<~SH)
        #!/usr/bin/env bash
        touch "$CURL_CALLED"
      SH
      FileUtils.chmod(0o755, File.join(fake_bin, "curl"))

      wrapper = File.expand_path("../../images/buildcurl/bin/buildcurl", __dir__)
      _stdout, stderr, status = Open3.capture3(
        {
          "BUILDCURL_URL" => nil,
          "CURL_CALLED" => curl_called,
          "PKGR_BUILDCURL_NESTED" => "1",
          "PKGR_BUILDCURL_TOKEN" => "secret",
          "TARGET" => "ubuntu:24.04",
          "PATH" => "#{fake_bin}:#{ENV.fetch('PATH')}"
        },
        "/bin/bash",
        wrapper,
        "ruby",
        "3.3.10"
      )

      expect(status).not_to be_success
      expect(stderr).to include("BUILDCURL_URL is required for nested builds")
      expect(File).not_to exist(curl_called)
    end
  end

  it "rejects SQLite versions that the recipe cannot build" do
    recipe = File.expand_path("../../images/buildcurl/recipes/sqlite", __dir__)
    stdout, stderr, status = Open3.capture3(
      { "VERSION" => "3.8.0", "TARGET" => "ubuntu:24.04" },
      "/bin/bash",
      recipe,
      Dir.mktmpdir
    )

    expect(status.exitstatus).to eq(2)
    expect(stdout).to be_empty
    expect(stderr).to include("Unsupported SQLite version: 3.8.0")
  end
end
