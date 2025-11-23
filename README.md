# VSCodium Packaging for loong64

This repository automates the creation of Debian packages (.deb) for [VSCodium](https://github.com/VSCodium/vscodium) targeting the loong64 architecture.

## Overview

VSCodium is a community-driven, freely-licensed binary distribution of Microsoft's VS Code editor. This packaging repository downloads official VSCodium releases and repackages them into Debian-compatible packages specifically for loong64 systems.

## Features

- **Automated Packaging**: GitHub Actions workflow automatically builds .deb packages
- **Architecture-Specific**: Optimized for loong64 architecture
- **Version Control**: Tracks VSCodium versions via `VERSION` file
- **Release Management**: Automatically uploads packages as GitHub releases
- **Full Desktop Integration**: Includes desktop entries, MIME types, and shell completions

## Prerequisites

To build packages locally, you need:

- Bash shell
- `curl` for downloading
- `jq` for JSON parsing
- `wget` for file downloads
- `tar` for extraction
- `dpkg` and `fakeroot` for package creation

## Usage

### Automated Build (GitHub Actions)

The repository automatically builds packages when:
- A new tag is pushed
- Manual workflow dispatch is triggered

The workflow is defined in `.github/workflows/build.yml`.

### Manual Build

To build a package locally:

```bash
# Build for loong64 architecture
bash download_and_extract.sh loong64
```

The script will:
1. Read the version from the `VERSION` file
2. Download the corresponding VSCodium release from GitHub
3. Extract and prepare the package structure
4. Create a `.deb` package in the current directory

### Package Output

The generated package will be named: `codium_<version>_loong64.deb`

## Installation

After building or downloading the package:

```bash
# Install the package
sudo dpkg -i codium_<version>_loong64.deb

# Install dependencies if needed
sudo apt-get install -f
```

To launch VSCodium after installation:

```bash
codium
```

## Repository Structure

```
.
├── VERSION                      # Current VSCodium version to package
├── download_and_extract.sh      # Main build script
├── official/                    # Debian package template
│   ├── DEBIAN/                  # Package control files
│   │   ├── control.in          # Package metadata template
│   │   ├── postinst            # Post-installation script
│   │   ├── prerm               # Pre-removal script
│   │   └── postrm              # Post-removal script
│   └── usr/                     # Package content structure
│       └── share/               # Shared resources
│           ├── applications/    # Desktop entries
│           ├── appdata/        # AppStream metadata
│           ├── bash-completion/ # Bash completions
│           ├── mime/           # MIME type definitions
│           ├── pixmaps/        # Application icon
│           └── zsh/            # Zsh completions
└── .github/
    └── workflows/
        └── build.yml            # CI/CD workflow
```

## Version Management

To update the target VSCodium version:

1. Edit the `VERSION` file with the desired release tag
2. Commit and push changes
3. Create a new tag to trigger the build workflow

Example:
```bash
# Use the VSCodium release tag format (e.g., "1.95.3.24312")
echo "1.95.3.24312" > VERSION
git add VERSION
git commit -m "Bump version to 1.95.3.24312"
git push
```

## Package Details

The generated Debian package includes:

- **Package Name**: `codium`
- **Installation Path**: `/usr/share/codium/`
- **Binary Symlink**: `/usr/bin/codium`
- **Desktop Integration**: Application menu entries, MIME type handlers
- **Shell Completions**: Bash and Zsh completion scripts

### Dependencies

The package depends on standard desktop libraries including:
- GTK 3/4
- Cairo, Pango
- ALSA (audio)
- Various system libraries (libc6, libx11, etc.)

See `official/DEBIAN/control.in` for the complete dependency list.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests for:

- Bug fixes
- Support for additional architectures
- Improvements to the build process
- Documentation enhancements

## License

This packaging repository contains scripts and configuration files for packaging VSCodium.

- VSCodium itself is licensed under the MIT License
- Package maintenance scripts in this repository include copyright notices from the original VS Code project

## Related Projects

- [VSCodium](https://github.com/VSCodium/vscodium) - The upstream project
- [Visual Studio Code](https://code.visualstudio.com/) - The original editor by Microsoft

## Maintainer

- Elysia (<39023210+elysia-best@users.noreply.github.com>)

## Support

For issues specific to this packaging:
- Open an issue in this repository

For VSCodium application issues:
- Visit the [VSCodium repository](https://github.com/VSCodium/vscodium/issues)
