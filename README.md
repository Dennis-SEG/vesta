Vesta Control Panel
===========================

> **This is a fork of [outroll/vesta](https://github.com/outroll/vesta).**
> It exists because the installers stopped working on current Linux releases.
> The changes here are offered upstream in
> [outroll/vesta#2322](https://github.com/outroll/vesta/pull/2322); this
> repository is where they can be installed from in the meantime.
> Not affiliated with or endorsed by the upstream maintainers.

Supported platforms
----------------------------

Each of these was installed end to end and logged into on the release in
question -- not merely built. See
[v2.1.0](https://github.com/Dennis-SEG/vesta/releases/tag/v2.1.0).

| Platform | Status |
|---|---|
| Ubuntu 20.04, 22.04, 24.04 | working |
| Debian 11, 12 | working |
| Alpine 3.24 | working |
| RHEL / Rocky 8 | **not working** -- package list targets EL6/EL7 |
| Amazon Linux | **not working** -- no package repository |

The last two were already broken upstream and are not addressed here.

How to install
----------------------------

Connect to your server as root and run the installer for your OS:

```bash
git clone https://github.com/Dennis-SEG/vesta.git
cd vesta/install
sudo GITHUB_REPO=Dennis-SEG/vesta bash vst-install-ubuntu.sh
```

Use `vst-install-debian.sh` or `vst-install-alpine.sh` as appropriate, and
`--help` for the available options (admin email/password, which services to
install).

`GITHUB_REPO` tells the installer which repository's GitHub Releases to pull
the `vesta`, `vesta-nginx`, `vesta-php` and `vesta-ioncube` packages from. It
defaults to `outroll/vesta`, which currently publishes no release assets, so
the override is required until upstream tags a release.

What is fixed here
----------------------------

- **Login worked on no modern distribution.** `chpasswd` follows PAM, which
  defaults to yescrypt on Debian 11+ and Ubuntu 22.04+, and PHP's `crypt()`
  cannot verify a `$y$` hash. Installs completed, services ran, the panel
  answered -- and every login was refused.
- **Ubuntu 20.04/22.04 were listed as supported but not installable**; their
  config trees were in a layout the canonical installer does not read.
- **Debian has been broken since Debian 10** -- the release was derived with
  `grep -o [0-9] | head -n1`, so "11.11" became "1". Debian also ships no
  MySQL server, so the database path now uses MariaDB.
- **The published packages could not be installed on Debian 11**, because they
  were zstd-compressed and Debian's dpkg only understands that from 1.21.
- **`bin/v-update-sys-ip` wrote an unvalidated HTTP response into the NAT
  configuration on every boot.** This affects existing installations.
- **The panel served a UI three major React versions behind its own source.**

License
----------------------------
Vesta is licensed under  [GPL v3 ](https://github.com/outroll/vesta/blob/master/LICENSE) license

