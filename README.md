<div align="center">

# asdf-just [![Build](https://github.com/olofvndrhr/asdf-just/actions/workflows/build.yml/badge.svg)](https://github.com/olofvndrhr/asdf-just/actions/workflows/build.yml) [![Lint](https://github.com/olofvndrhr/asdf-just/actions/workflows/lint.yml/badge.svg)](https://github.com/olofvndrhr/asdf-just/actions/workflows/lint.yml)


[just](https://just.systems/man/en/) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

**TODO: adapt this section**

- `bash`, `curl`, `tar`: generic POSIX utilities.
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add just
# or
asdf plugin add just https://github.com/olofvndrhr/asdf-just.git
```

just:

```shell
# Show all installable versions
asdf list-all just

# Install specific version
asdf install just latest

# Set a version globally (on your ~/.tool-versions file)
asdf global just latest

# Now just commands are available
just --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/olofvndrhr/asdf-just/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Ivan Schaller](https://github.com/olofvndrhr/)
