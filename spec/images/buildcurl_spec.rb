require "spec_helper"
require "open3"

describe "buildcurl recipes" do
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
