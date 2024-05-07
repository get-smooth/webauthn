> This repository is currently under development and not ready for production use ⚠️

# WebAuthn Library

[![Open in Github][github-editor-badge]][github-editor-url] [![Github Actions][gha-quality-badge]][gha-quality-url]
[![Github Actions][gha-test-badge]][gha-test-url]
[![Github Actions][gha-static-analysis-badge]][gha-static-analysis-url]
[![Github Actions][gha-release-badge]][gha-release-url] [![Foundry][foundry-badge]][foundry]
[![License: MIT][license-badge]][license] ![Is it audited?][audit]

[github-editor-url]: https://github.dev/0x90d2b2b7fb7599eebb6e7a32980857d8/webauthn/tree/main
[github-editor-badge]: https://img.shields.io/badge/Github-Open%20the%20Editor-purple?logo=github
[gha-quality-url]: https://github.com/0x90d2b2b7fb7599eebb6e7a32980857d8/webauthn/actions/workflows/quality-checks.yml
[gha-quality-badge]: https://github.com/0x90d2b2b7fb7599eebb6e7a32980857d8/webauthn/actions/workflows/quality-checks.yml/badge.svg?branch=main
[gha-test-url]: https://github.com/0x90d2b2b7fb7599eebb6e7a32980857d8/webauthn/actions/workflows/tests.yml
[gha-test-badge]: https://github.com/0x90d2b2b7fb7599eebb6e7a32980857d8/webauthn/actions/workflows/tests.yml/badge.svg?branch=main
[gha-static-analysis-url]: https://github.com/0x90d2b2b7fb7599eebb6e7a32980857d8/webauthn/actions/workflows/static-analysis.yml
[gha-static-analysis-badge]:
  https://github.com/0x90d2b2b7fb7599eebb6e7a32980857d8/template-foundry/actions/workflows/static-analysis.yml/badge.svg?branch=main
[gha-release-url]: https://github.com/0x90d2b2b7fb7599eebb6e7a32980857d8/webauthn/actions/workflows/release-package.yml
[gha-release-badge]: https://github.com/0x90d2b2b7fb7599eebb6e7a32980857d8/webauthn/actions/workflows/release-package.yml/badge.svg
[foundry]: https://book.getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: ./LICENSE.md
[license-badge]: https://img.shields.io/badge/License-APACHE2-pink.svg
[audit]: https://img.shields.io/badge/Audited-No-red.svg

## Description

`webauthn` is a library designed to validate passkeys. Currently, it supports only the ECDSA signature scheme utilizing the secp256r1 curve. This functionality is provided by the [secp256r1 library](https://github.com/0x90d2b2b7fb7599eebb6e7a32980857d8/secp256r1-verify). Support for additional algorithms is planned for future releases.

## Installation

### Foundry

To install the `webauthn` package in a Foundry project, execute the following command:

```sh
forge install https://github.com/0x90d2b2b7fb7599eebb6e7a32980857d8/webauthn
```

This command will install the latest version of the package in your lib directory. To install a specific version of the
library, follow the instructions in the
[official Foundry documentation](https://book.getfoundry.sh/reference/forge/forge-install?highlight=forge%20install#forge-install).

### Hardhat or Truffle

To install the `webauthn` package in a Hardhat or Truffle project, use `npm` to run the following command:

```sh
npm install @0x90d2b2b7fb7599eebb6e7a32980857d8/webauthn
```

After the installation, import the package into your project and use it to validate a Web Authentication signature.

> ⚠️ Note: This package is not published on the npm registry, and is only available on GitHub Packages. You need to be
> authenticated with GitHub Packages to install it. For more information, please refer to the
> [troubleshooting section](#setup-github-registry). We are willing to deploy it on the npm registry if there is a need.
> Please open an issue if you would like to see this package on the npm registry.

## Usage

This repository supports the verification of Web Authentication signatures using the ECDSA signature scheme with the secp256r1 curve. The non-experimental implementations from the [secp256r1 library](https://github.com/0x90d2b2b7fb7599eebb6e7a32980857d8/secp256r1-verify) are all supported. After you've integrated this library into your project, you can freely import and use the implementation that best suits your specific use cases and requirements. Let's take a more detailed look at each one.

> 🚨 None of the implementations have been audited. DO NOT USE THEM IN PRODUCTION.
### Scripts

This repository includes a [script](./script) directory containing a set of scripts that can be used to deploy the
different implementations on-chain. Each script contains a set of instructions and an example of how to use it. The
scripts are expected to be run using the `forge script` command.

## Gas reports

This gas report was produced using the `0.8.19` version of the Solidity compiler (with 100k optimizer runs), specifically for the [`0.3.0`](https://github.com/0x90d2b2b7fb7599eebb6e7a32980857d8/webauthn/releases/tag/v0.3.0) version of the library.

| test/WebAuthnWrapper.sol:WebAuthnWrapper contract |                 |        |        |        |         |
|---------------------------------------------------|-----------------|--------|--------|--------|---------|
| Deployment Cost                                   | Deployment Size |        |        |        |         |
| 1321776                                           | 6634            |        |        |        |         |
| Function Name                                     | min             | avg    | median | max    | # calls |
| _generateMessage                                  | 5230            | 5261   | 5230   | 5421   | 6       |
| verify                                            | 209257          | 209257 | 209257 | 209257 | 1       |

These costs can be considered end-to-end as they include the cost of the [secp256r1 library](https://github.com/0x90d2b2b7fb7599eebb6e7a32980857d8/secp256r1-verify).
Note the library is wrapped in a contract that exposes the different functions of the library, impacting the gas cost of the benchmark.

> ℹ️ Tests expected to revert are excluded from the gas report

## Contributing

To contribute to the project, you must have Foundry and Node.js installed on your system. You can download them from
their official websites:

- Node.js: https://nodejs.org/
- Foundry: https://book.getfoundry.sh/getting-started/installation

> ℹ️ We recommend using [nvm](https://github.com/nvm-sh/nvm) to manage your Node.js versions. Nvm is a flexible node
> version manager that allows you to switch between different versions of Node.js effortlessly. This repository includes
> a `.nvmrc` file at the root of the project. If you have nvm installed, you can run `nvm use` at the root of the
> project to automatically switch to the appropriate version of Node.js.

Following the installation of Foundry and Node.js, there's an additional dependency called `make` that needs to be
addressed.

`make` is a build automation tool that employs a file known as a makefile to automate the construction of executable
programs and libraries. The makefile details the process of deriving the target program from the source files and other
dependencies. This allows developers to automate repetitive tasks and manage complex build processes efficiently. `make`
is our primary tool in a multi-environment repository. It enables us to centralize all commands into a single file
([the makefile](./makefile)), eliminating the need to deal with `npm` scripts defined in a package.json or remembering
the various commands provided by the `foundry` cli. If you're unfamiliar with `make`, you can read more about it
[here](https://www.gnu.org/software/make/manual/make.html).

`make` is automatically included in all modern Linux distributions. If you're using Linux, you should be able to use
`make` without any additional steps. If not, you can likely find it in the package tool you usually use. MacOS users can
install `make` using [Homebrew](https://formulae.brew.sh/formula/make) with the following command:

```sh
brew install make
```

At this point, you should have all the required dependencies installed on your system.

> 💡 Running make at the root of the project will display a list of all the available commands. This can be useful to
> know what you can do

### Installing the dependencies

To install the project dependencies, you can run the following command:

```sh
make install
```

This command will install the forge dependencies in the `lib/` directory, the npm dependencies in the `node_modules`
directory and the git hooks defined in the project ([refer to the Git hooks section](#git-hooks)s to learn more about
them). These dependencies aren't shipped in production; they're utility dependencies used to build, test, lint, format,
and more, for the project.

> ⚠️ This package uses a dependency installed on the Github package registry, meaning you need to authenticate with
> GitHub Packages to install it. For more information, refer to the [troubleshooting section](#setup-github-registry).
> We're open to deploying it on the npm registry if there's a demand for it. Please open an issue if you'd like to see
> this package on the npm registry.

Next, let's set up the git hooks.

### Git hooks

This project uses `Lefthook` to manage Git hooks, which are scripts that run automatically when certain Git events
occur, such as committing code or pushing changes to a remote repository. `Lefthook` simplifies the management and
execution of these scripts.

After installing the dependencies, you can configure the Git hooks by running the following command in the project
directory:

```sh
make hooks-i
```

This command installs a Git hook that runs Lefthook before pushing code to a remote repository. If Lefthook fails, the
push is aborted.

If you wish to run Lefthook manually, you can use the following command:

```sh
make hooks
```

This will run all the Git hooks defined in the [lefthook](./lefthook.yml) file.

#### Skipping git hooks

Should you need to intentionally skip Lefthook, you can pass the `--no-verify` flag to the git push command. To bypass
Lefthook when pushing code, use the following command:

```sh
git push origin --no-verify
```

## Testing

### Unit tests

The unit tests are stored in the `test` directory. They test individual functions of the package in isolation. These
tests are automatically run by GitHub Actions with every push to the `main` branch and on every pull request targeting
this branch. They are also automatically run by the git hook on every push to a remote repository if you have installed
it ([refer to the Git hooks section](#git-hooks)). Alternatively, you can run them locally by executing the following
command in the project directory:

```sh
make test
```

> ℹ️ By adding the sufix `-v` the test command will run in verbose mode, displaying valuable output for debugging.

For your information, these tests are written using [forge](https://book.getfoundry.sh/forge/tests), and some employ the
property-based testing pattern _(fuzzing)_ to generate random inputs for the functions under test.

The tests use one cheat code` you should be aware of:

- `vm.ffi`: This cheat code allows us to execute an arbitrary command during the test suite. This cheat code is not
  enabled by default when creating a new foundry project, but in our case, it's enabled in our configuration
  ([foundry configuration](./foundry.toml)) for all tests. This cheat code is used to run the computation library that
  calculates 256 points on the secp256r1 elliptic curve from a public key. This is required for the variants that need
  these points to be deployed on-chain. Therefore, even if it's not explicit, every time you run the test suite, a
  Node.js script is executed at least one time. You can learn more about the library we use
  [here](https://github.com/0x90d2b2b7fb7599eebb6e7a32980857d8/secp256r1-computation).

> 📖 Cheatcodes are special instructions exposed by Foundry to enhance the developer experience. Learn more about them
> [here](https://book.getfoundry.sh/cheatcodes/).

> 💡 Run `make` to learn how to run the test in verbose mode, or display the coverage, or even generate a gas report.

### Quality

This repository uses `forge-fmt`, `solhint`, and `prettier` to enforce code quality. These tools are automatically run by
the GitHub Actions on every push to the `main` branch and on every pull request targeting this branch. They are also
automatically run by the git hook on every push to a remote repository if you have installed it
([refer to the Git hooks section](#git-hooks)). Alternatively, you can run them locally by executing the following
command in the project directory:

```sh
make lint # run the linter
make format # run the formatter
make quality # run both
```

> ℹ️ By adding the suffix `-fix` the linter and the formatter will try to fix the issues automatically.

## Troubleshootings

### Setup Github registry

You need to configure npm to use the Github registry. You can do so using the following command in your terminal:

```sh
npm config set @0x90d2b2b7fb7599eebb6e7a32980857d8:registry=https://npm.pkg.github.com
```

This will instruct npm to use the Github registry for packages deployed by `@0x90d2b2b7fb7599eebb6e7a32980857d8`.

Once the Github registry is configured, you have to create a **classic** token on Github. To do so, go to your
[Github settings](https://github.com/settings/tokens). The token must have the read:packages scope. Once you have
created the token, use the following command in your terminal to authenticate to the Github registry:

```sh
npm login --auth-type=legacy --registry=https://npm.pkg.github.com
```

Your Github username is the username, and the password is the token you just created. At this point, your git should be
configured to use the Github Package Registry for our packages.

> ⚠️ For more information, please refer to the
> [GitHub documentation](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry#installing-a-package)

## Acknowledgements

Special thanks to [btchip](https://github.com/btchip) for developing the reference implementation
[here](https://github.com/btchip/Webauthn.sol) and for the invaluable guidance through the WebAuthn specification.
