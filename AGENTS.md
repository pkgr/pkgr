# AGENTS.md

## Buildpack references

- Buildpack release references in `data/buildpacks/*` may be mutable branches.
- Keep the Python buildpack on `v221-1`. Push compatible fixes to that branch instead of creating a new reference for every fix.
- Update every target file together when changing a buildpack reference.
- Confirm reference changes with `rg 'heroku-buildpack-python' data/buildpacks`.

## Image publishing

- The publish workflow runs automatically for `master`, `feature/*`, and `fix/*`. Use `workflow_dispatch` for other branches.
- Commit-addressed image tags use `<target-version>-<commit-sha>`, such as `24.04-<sha>`.
- The `master` alias is published only from `master`.
- Pin `pkgr/action` E2Es to an exact published image commit. Update that pin whenever the `pkgr` commit changes.
- Keep `FROM barebuild/$TARGET` until the base-image migration is handled separately.

## Local buildcurl recipes

- `/opt/pkgr/buildcurl/compile` must emit a prefix-relative gzip archive containing `compile.log`.
- Reject unknown recipes, invalid inputs, and target mismatches in the local compiler. The local compiler never proxies rejected requests upstream.
- Default non-nested `buildcurl` calls to `https://buildcurl.com` when `BUILDCURL_URL` is unset so released actions remain compatible.
- Require an explicit `BUILDCURL_URL` for nested recipes. Never send `X-Pkgr-Nested-Token` to the hosted default.
- Source `/etc/profile.local` before recipes so target-provided tools such as Rust are available.
- The SQLite recipe builds only `3.7.9` and must reject every other requested version to preserve cache identity.
- Nested recipes must call the injected `BUILDCURL_URL` through the image-owned `buildcurl` wrapper.

## Validation

Run these checks for recipe changes:

```bash
bundle exec rspec spec/images/buildcurl_spec.rb
shellcheck images/buildcurl/compile images/buildcurl/bin/buildcurl images/buildcurl/recipes/*
bash -n images/buildcurl/compile images/buildcurl/bin/buildcurl images/buildcurl/recipes/*
git diff --check
```
