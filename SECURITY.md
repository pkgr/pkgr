# Security policy

## Reporting a vulnerability

Please do not report security problems in public issues or pull requests.

Report them privately through GitHub instead:
<https://github.com/pkgr/pkgr/security/advisories/new>

You can also email <security@packager.io>.

This covers the pkgr gem, the files it generates in packages (the CLI wrapper, init scripts and install hooks), and the build images published at `ghcr.io/pkgr/pkgr`.

Please include:

- the pkgr version or image tag, and the target distribution
- what an attacker needs beforehand, and what they gain
- steps to reproduce, or a proof of concept

## What happens next

- We acknowledge the report and confirm whether we can reproduce it.
- We develop the fix privately and share patched images with you for testing.
- We agree on a disclosure date with you, and with affected downstream packagers when needed, so that fixed packages can be released at the same time.
- We publish a GitHub security advisory, with a CVE when appropriate, and credit you unless you prefer otherwise.

## Supported versions

Fixes go into the latest release and the `master` build images. Applications must be repackaged with a fixed pkgr for users to receive the fix.
