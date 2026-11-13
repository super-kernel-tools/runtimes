<p align="right">
  <strong>English</strong> | <a href="README.zh-CN.md">中文文档</a>
</p>

# SKERNEL Runtimes

Prebuilt PHP runtimes for [SKERNEL](https://github.com/super-kernel-tools/skernel), the command-line project tool of [SuperKernel](https://github.com/super-kernel). SKERNEL builds, runs, and packages a project with a static PHP build of its own. Instead of building that PHP on your machine, it downloads it from the releases of this repository when the one a project needs is published here.

You do not use this repository directly: SKERNEL finds, verifies, and installs the runtimes.

> [!NOTE]
> SKERNEL releases after `1.0.0-beta.1` download these runtimes. `1.0.0-beta.1` and earlier releases build every runtime on the machine.

## What is published

Each release, named `php-<version>`, holds the runtimes of one PHP version. A runtime is one archive, `php-<version>-<platform>-<key>.tar.gz`, with a `.sha256` file beside it that holds the archive's SHA-256 digest. The archive contains:

| File | Content |
| --- | --- |
| `php` | The static PHP CLI. |
| `micro.sfx` | The micro runtime that SKERNEL puts in front of a packaged application. |
| `manifest.json` | The PHP version, the platform, the extensions and the versions selected for them, the static-php-cli release, and the SHA-256 digests of both binaries. |

The key is the name SKERNEL gives the runtime's directory in its home. It is a hash of the extensions, the versions selected for them, the static-php-cli and Zig releases, and the build options, and SKERNEL computes it from the project. So SKERNEL downloads exactly the runtime that it would otherwise build.

Runtimes are published for `linux-x86_64`, `linux-aarch64`, `macos-aarch64`, and `macos-x86_64`, for the latest release of the PHP branch that a new SuperKernel project requires, and for these extension sets:

- a project that `skernel new` creates, with its development requirements installed, which `build` and `run` use;
- the same project without its development requirements, which `package` uses;
- both of them with `super-kernel/redis` added;
- the PHP that runs SKERNEL's own Composer when it finds no Composer on the machine.

A project with another PHP version or other extensions is not covered. SKERNEL builds its runtime on the machine, as it does for every runtime of a project whose `skernel.json` sets `"prebuilt": false`.

## How the runtimes are built

The `Publish` workflow checks every hour whether a SKERNEL, PHP, or PECL release changed what SKERNEL would build, and then runs the latest SKERNEL release on GitHub-hosted runners of each platform; it also runs on demand. It creates the projects above with SKERNEL and lets SKERNEL build their runtimes as it would on your machine, with its pinned releases of static-php-cli and, on Linux, Zig. It then packs each runtime that is not published yet and uploads it. A published runtime is never replaced.

## How SKERNEL verifies a runtime

Before SKERNEL installs a downloaded runtime, it checks that:

1. the archive matches the digest in its `.sha256` file;
2. the manifest names the PHP version, the platform, and the extensions that the project needs;
3. both binaries match the digests in the manifest;
4. the PHP runs on the machine, reports that version, and has no extension version that the project does not accept.

A runtime that fails a check is not installed, and the command stops. The digests guard against a damaged or incomplete download. They are published in the same releases as the archives, so the trust in a runtime rests on this repository and its workflow. To build every runtime yourself, set `"prebuilt": false` in the project's `skernel.json`.

## License

The scripts and the workflow of this repository are released under the [MIT License](LICENSE). The runtimes are builds of PHP, its extensions, and the libraries they link, each under its own license.
