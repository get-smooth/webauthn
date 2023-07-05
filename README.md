# Foundry Template

[![Open in Github][github-editor-badge]][github-editor-url] [![Github Actions][gha-quality-badge]][gha-quality-url]
[![Github Actions][gha-test-badge]][gha-test-url]
[![Github Actions][gha-static-analysis-badge]][gha-static-analysis-url]
[![Github Actions][gha-release-badge]][gha-release-url] [![Foundry][foundry-badge]][foundry]
[![License: MIT][license-badge]][license]

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
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

A Foundry-based template for developing Solidity smart contracts, with sensible defaults. Based on
[@PaulRBerg](https://github.com/PaulRBerg) [template](https://github.com/PaulRBerg/foundry-template).

## What's Inside

- [Forge](https://github.com/foundry-rs/foundry/blob/master/forge): compile, test, fuzz, format, and deploy smart
  contracts
- [Forge Std](https://github.com/foundry-rs/forge-std): collection of helpful contracts and cheatcodes for testing
- [PRBTest](https://github.com/PaulRBerg/prb-test): modern collection of testing assertions and logging utilities
- [Prettier](https://github.com/prettier/prettier): code formatter for non-Solidity files
- [Solhint Community](https://github.com/solhint-community/solhint-community): linter for Solidity code
- [Make](https://www.gnu.org/software/make/manual/make.html): build automation tool that allows developers to automate
  repetitive tasks
- [Lefthook](https://github.com/evilmartians/lefthook): Fast and powerful Git hooks manager for any type of projects

## Getting Started

### Prerequisites

This repository uses [`make`](https://www.gnu.org/software/make/manual/make.html) to automate repetitive tasks.

`make` is a build automation tool that employs a file known as a makefile to automate the construction of executable
programs and libraries. The makefile details the process of deriving the target program from the source files and other
dependencies. This allows developers to automate repetitive tasks and manage complex build processes efficiently. `make`
is our primary tool in a multi-environment repository. It enables us to centralize all commands into a single file
([the makefile](./makefile)), eliminating the need to deal with `npm` scripts defined in a package.json or remembering
the various commands provided by the `foundry` cli. If you're unfamiliar with `make`, you can read more about it
[here](https://www.gnu.org/software/make/manual/make.html).

> 💡 Running make at the root of the project will display a list of all the available commands. This can be useful to
> know what you can do with the project.

#### Make of Linux

`make` is automatically included in all modern Linux distributions. If you're using Linux, you should be able to use
`make` without any additional steps. If not, you can likely find it in the package tool you usually use.

#### Make on MacOS

MacOS users can install `make` using [Homebrew](https://formulae.brew.sh/formula/make) with the following command:

```sh
brew install make
```

### Installation

Click the [`Use this template`](https://github.com/0x90d2b2b7fb7599eebb6e7a32980857d8/template-foundry/generate) button at the top of the page to
create a new repository with this repo as the initial state.

Or, if you prefer to install the template manually:

```sh
forge init my-project --template https://github.com/0x90d2b2b7fb7599eebb6e7a32980857d8/template-foundry
cd my-project
make install # install the forge dependencies and the npm dependencies
```

If this is your first time with Foundry, check out the
[installation](https://github.com/foundry-rs/foundry#installation) instructions.

> ℹ️ As part of the initialization process, a one-time script, which can be found
> [here](./.github/workflows/setup-template.yml), is utilized to tailor the template to your specific project. This
> script will automatically update the [package.json](./package.json) file with details like your project's name, the
> author's name, the homepage, the repository URL, etc. Additionally, it will remove unnecessary files, such as the
> FUNDING.yml file and the initialization script itself.

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

Executing this will activate all the Git hooks specified in the [lefthook](./lefthook.yml) file, including commands for
linting, formatting, testing, and compiling.

#### Skipping git hooks

If you need to intentionally skip Lefthook, you can pass the `--no-verify` flag to the git push command. For example to
bypass Lefthook when pushing code, use the following command:

```sh
git push origin --no-verify
```

## Features

This template builds upon the frameworks and libraries mentioned above, so for details about their specific features,
please consult their respective documentation.

For example, if you're interested in exploring Foundry in more detail, you should look at the
[Foundry Book](https://book.getfoundry.sh/). In particular, you may be interested in reading the
[Writing Tests](https://book.getfoundry.sh/forge/writing-tests.html) tutorial.

### Sensible Defaults

This template comes with a set of sensible default configurations for you to use. These defaults can be found in the
following files:

```text
├── .gitignore
├── .prettierignore
├── .prettierrc.yml
├── .solhint.json
├── .nvmrc
├── lefthook.yml
├── makefile
├── slither.config.json
└── foundry.toml
```

### GitHub Actions

This template comes with GitHub Actions pre-configured.

- [quality-checks.yml](./.github/workflows/quality-checks.yml): runs the compilation command, the linter and the
  formatter on every push and pull request made to the `main` branch. The size of the contracts is printed in the logs.
- [static-analysis.yml](./.github/workflows/static-analysis.yml): runs the static analysis tool on every push and pull
  request made to the `main` branch. This action uses [slither](https://github.com/crytic/slither) and is only triggered
  when specific files are modified.
- [tests.yml](./.github/workflows/tests.yml): runs the tests onsevery push and pull request made to the `main` branch.
  This action also compare the gas cost between the `main` branch and the pull request branch and post the difference as
  a comment on the pull request.
- [release-package.yml](./.github/workflows/release-package.yml): creates a new release every time you push a new tag to
  the repository. This action is only triggered on tags starting with `v`. Once the release is created, the action is
  also in charge of deploying the documentation to the `gh-pages` branch. **THIS ACTION NEEDS AN ACTION FROM YOUR SIDE
  TO WORK**

You can edit the CI scripts in the [workflows directory](./.github/workflows).

#### Configure the release action

The release action is in charge of deploying the documentation to the `gh-pages` branch. To do so, it needs to have a
personal access token with the right permissions. To create this token, go to the
[settings of your Github account](https://github.com/settings/tokens?type=beta). Make sure to select the permissions
listed below. Once create, copy the token, go to the Github repository of this project and create a secret named
`RELEASE_TOKEN` with the value of the token you just created. Here are the **repositories** permissions required by the
token:

- Actions: Read and write
- Contents: Read and write
- Commit statuses: Read-only
- Metadata: Read-only
- Pull requests: Read-only

## Writing Tests

To write a new test contract, you start by importing [PRBTest](https://github.com/PaulRBerg/prb-test) and inherit from
it in your test contract. PRBTest comes with a pre-instantiated [cheatcodes](https://book.getfoundry.sh/cheatcodes/)
environment accessible via the `vm` property. If you would like to view the logs in the terminal output you can run the
dedicated verbose command and use
[console.log](https://book.getfoundry.sh/faq?highlight=console.log#how-do-i-use-consolelog).

This template comes with an example test contract [Foo.t.sol](./test/Foo.t.sol)

## Usage

You can access a list of all available commands by running `make` in the project's root directory.

```sh
make
```

These commands are outlined in the [makefile](./Makefile).

## Scripts

### Deploy

This script is located in the [script](./script) directory. It deploys the contract to a network. For example, to deploy
to [Anvil](https://book.getfoundry.sh/anvil/), you can run the following command:

```sh
forge script script/Deploy.s.sol --broadcast --fork-url http://localhost:8545
```

For this script to work, you need to have a `MNEMONIC` environment variable set to a valid
[BIP39 mnemonic](https://iancoleman.io/bip39/).

For instructions on how to deploy to a testnet or mainnet, check out the
[Solidity Scripting](https://book.getfoundry.sh/tutorials/solidity-scripting.html) tutorial.

## Notes

1. Foundry uses [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) to manage dependencies. For
   detailed instructions on working with dependencies, please refer to the
   [guide](https://book.getfoundry.sh/projects/dependencies.html) in the book
2. You don't have to create a `.env` file, but filling in the environment variables may be useful when debugging and
   testing against a fork.
3. This template uses [npm](https://www.npmjs.com/) to manage JavaScript dependencies.
4. This template only uses [slither](https://github.com/crytic/slither) in the CI pipeline. If you want to run it
   locally, you need to install it for yourself by following the instructions in the
   [documentation](https://github.com/crytic/slither#how-to-install).
5. This template includes a opiniated [contributing guide](./.github/CONTRIBUTING.md) you free to update.
6. Remappings are configured in the [foundry.toml file](./foundry.toml) file in order to centralize the configuration.
   Feel free to update them.

## Related Efforts

- [abigger87/femplate](https://github.com/abigger87/femplate)
- [cleanunicorn/ethereum-smartcontract-template](https://github.com/cleanunicorn/ethereum-smartcontract-template)
- [foundry-rs/forge-template](https://github.com/foundry-rs/forge-template)
- [FrankieIsLost/forge-template](https://github.com/FrankieIsLost/forge-template)
- [PaulRBerg/foundry-template](https://github.com/PaulRBerg/foundry-template)

## License

This project is licensed under MIT.

## Acknowledgements

This template has been boostrapped using [@PaulRBerg](https://github.com/PaulRBerg)
[template](https://github.com/PaulRBerg/foundry-template). This version is a bit more opinionated (`make`...) and comes
with a few more features. Thanks to him for his valuable contributions to the community.
