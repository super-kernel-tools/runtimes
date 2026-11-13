<p align="right">
  <a href="README.md">English</a> | <strong>中文文档</strong>
</p>

# SKERNEL Runtimes

这里发布 [SKERNEL](https://github.com/super-kernel-tools/skernel) 使用的预构建 PHP 运行时。SKERNEL 是 [SuperKernel](https://github.com/super-kernel) 的命令行项目工具，它用自己的静态 PHP 构建、运行和打包项目。只要项目需要的那个 PHP 已在这里发布，SKERNEL 就从本仓库的 Releases 下载，而不必在你的机器上构建。

你不需要直接使用本仓库：运行时由 SKERNEL 查找、校验并安装。

> [!NOTE]
> `1.0.0-beta.1` 之后发布的 SKERNEL 会下载这些运行时；`1.0.0-beta.1` 及更早的版本仍在本机构建所有运行时。

## 发布的内容

每个名为 `php-<version>` 的发布存放一个 PHP 版本的运行时。一个运行时是一个归档文件 `php-<version>-<platform>-<key>.tar.gz`，旁边的 `.sha256` 文件记录该归档的 SHA-256 摘要。归档中包含：

| 文件 | 内容 |
| --- | --- |
| `php` | 静态 PHP CLI。 |
| `micro.sfx` | micro 运行时，SKERNEL 把它放在打包后的应用前面。 |
| `manifest.json` | PHP 版本、平台、扩展及为其选定的版本、static-php-cli 的版本，以及两个二进制文件的 SHA-256 摘要。 |

其中的 key 是 SKERNEL 在自己的主目录中给该运行时目录起的名字。它是扩展、为扩展选定的版本、static-php-cli 与 Zig 的版本以及构建选项的哈希，由 SKERNEL 根据项目计算。因此 SKERNEL 下载到的，正是它原本要自己构建的那个运行时。

运行时面向 `linux-x86_64`、`linux-aarch64`、`macos-aarch64` 和 `macos-x86_64` 发布，PHP 版本是新建 SuperKernel 项目所要求分支的最新发布，扩展组合如下：

- `skernel new` 创建的项目在安装开发依赖时的组合，供 `build` 和 `run` 使用；
- 同一项目不含开发依赖时的组合，供 `package` 使用；
- 以上两种再加上 `super-kernel/redis`；
- 机器上找不到 Composer 时，运行 SKERNEL 自带 Composer 的 PHP。

使用其他 PHP 版本或其他扩展的项目不在覆盖范围内。SKERNEL 会在本机构建它的运行时；项目的 `skernel.json` 设置了 `"prebuilt": false` 时，所有运行时也都这样构建。

## 运行时如何构建

`Publish` 工作流每六小时运行一次，也可以手动触发。它在每个平台的 GitHub 托管 Runner 上运行最新发布的 SKERNEL，用 SKERNEL 创建上述项目，并让 SKERNEL 像在你的机器上一样构建它们的运行时，使用的是 SKERNEL 固定版本的 static-php-cli，在 Linux 上还有固定版本的 Zig。随后它把尚未发布的运行时打包上传。已发布的运行时不会被替换。

## SKERNEL 如何校验运行时

安装下载到的运行时之前，SKERNEL 会检查：

1. 归档与其 `.sha256` 文件中的摘要一致；
2. 清单中的 PHP 版本、平台和扩展与项目需要的一致；
3. 两个二进制文件与清单中的摘要一致；
4. 其中的 PHP 能在本机运行、报告的正是该版本，并且没有项目不接受的扩展版本。

任何一项不通过，运行时都不会被安装，命令随之停止。摘要用于防范下载损坏或不完整。它们与归档发布在同一个 Release 中，所以对运行时的信任建立在本仓库及其工作流之上。如果想自己构建所有运行时，请在项目的 `skernel.json` 中设置 `"prebuilt": false`。

## 许可证

本仓库的脚本和工作流以 [MIT 许可证](LICENSE) 发布。运行时是 PHP、其扩展以及所链接库的构建产物，各自遵循自己的许可证。
