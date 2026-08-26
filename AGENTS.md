# AGENTS.md

## Buildpack references

- Buildpack release references in `data/buildpacks/*` may be mutable branches.
- Keep the Python buildpack on `v221-1`. Push compatible fixes to that branch instead of creating a new reference for every fix.
- Update every target file together when changing a buildpack reference.
- Confirm reference changes with `rg 'heroku-buildpack-python' data/buildpacks`.
- Before changing the Node buildpack pin, confirm its inventory contains modern Node `24.13.0` and legacy Node `16.18.1`.

## Image publishing

- The publish workflow runs automatically for `master`, `feature/*`, and `fix/*`. Use `workflow_dispatch` for other branches.
- Commit-addressed image tags use `<target-version>-<commit-sha>`, such as `24.04-<sha>`.
- Publish exact commit tags for every successful matrix run. Promote the complete `master` alias set only after every target succeeds and the run SHA is still the current `master` head.
- Let `pkgr/action` E2Es resolve `master` once to an exact published image commit. Use the manual SHA override while testing unpublished cross-repository changes.
- Keep image publication globally queued and serial while the image bootstrap depends on the hosted compiler. Concurrent bootstrap requests can return truncated archives.
- Before landing publication queue or promotion changes, drain every active Publish run created from the old workflow. Never rerun a pre-promotion `master` run after cutover because it can bypass the queue and overwrite mutable aliases.
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
