# OpenStarbound Agent Instructions

## Repository Overview

**OpenStarbound** is a C++17 modification of Starbound 1.4.4, a 2D space exploration game. This project fixes bugs, adds features, and improves performance of the base game. The codebase is approximately 500MB with extensive C++ source, Lua scripting support, and game assets.

**Languages & Technologies:**
- Primary: C++17
- Build System: CMake 3.23+ with Ninja
- Package Manager: vcpkg for dependencies
- Scripting: Lua (embedded)
- Platforms: Windows (x64), Linux (x64, Clang/GCC), macOS (Intel/ARM64)
- Key Dependencies: SDL3, OpenGL, Opus, Zlib, FreeType, ImGui, libvorbis

## Critical Build Information

### Environment Setup

**ALWAYS set VCPKG_ROOT before building:**
```bash
# Linux/macOS
export VCPKG_ROOT=/path/to/vcpkg

# Windows (PowerShell)
$env:VCPKG_ROOT = "C:\path\to\vcpkg"
```

vcpkg must be installed and bootstrapped before any build attempt. The project uses a pinned vcpkg baseline (commit: `b1b19307e2d2ec1eefbdb7ea069de7d4bcd31f01`).

### Platform-Specific Build Instructions

#### Linux (Ubuntu/Debian)

**Required Packages (install before building):**
```bash
sudo apt-get update
sudo apt-get install -y pkgconf libxmu-dev libgl-dev libglu1-mesa-dev \
  libasound2-dev libpulse-dev libaudio-dev libjack-dev libsndio-dev \
  libx11-dev libxext-dev libxrandr-dev libxcursor-dev libxfixes-dev \
  libxi-dev libxss-dev libxtst-dev libxkbcommon-dev libdrm-dev libgbm-dev \
  libgl1-mesa-dev libgles2-mesa-dev libegl1-mesa-dev libdbus-1-dev \
  libibus-1.0-dev libudev-dev libpipewire-0.3-dev libwayland-dev \
  libdecor-0-dev liburing-dev ninja-build
```

**CMake Version:** Must be 3.23 or newer. Ubuntu 20.04 and older require adding [Kitware's APT repository](https://apt.kitware.com/).

**Build Commands:**
```bash
# From repository root
cd source

# Configure (Clang - default for CI)
export CC=clang
export CXX=clang++
cmake --preset=linux-release-clang

# Or configure (GCC)
cmake --preset=linux-release

# Build (takes 10-20 minutes)
cmake --build --preset=linux-release-clang
# Or: cmake --build --preset=linux-release

# Built binaries appear in: ../dist/
```

**Post-Build Assembly:**
```bash
# From repository root
scripts/ci/linux/assemble.sh
# Creates: client_distribution/ and server_distribution/
# Also creates: client.tar and server.tar
```

**Required Runtime Files:**
- Copy `lib/linux/*.so` files to `dist/` 
- Copy `scripts/ci/linux/sbinit.config` to `dist/`
- Copy Starbound's `packed.pak` to `assets/` (not included, user must provide)

#### Windows

**Prerequisites:**
- Visual Studio 2022 with C++ tools
- CMake 3.23+ and Ninja (add to PATH or use Scoop: `scoop install ninja cmake`)
- vcpkg installed globally (recommended: `C:\src\vcpkg` or `C:\dev\vcpkg`)
- Run `vcpkg integrate install` after vcpkg setup

**Build Commands:**
```powershell
# From repository root, in VS Developer Command Prompt
cd source

# Configure
cmake --preset=windows-release

# Build (takes 15-30 minutes)
cmake --build --preset=windows-release

# Post-build (copy DLLs, remove non-starbound PDBs)
..\scripts\ci\windows\post_build.bat

# Assembly (creates client_distribution/ and server_distribution/)
..\scripts\ci\windows\assemble.bat
```

**Build Output:** `dist/` contains executables and PDBs. DLLs from `lib/windows/` are copied by post_build.bat.

**Required Runtime Files:**
- All DLLs from `lib/windows/` (copied by post_build.bat)
- `scripts/ci/windows/sbinit.config` in `dist/`
- Starbound's `packed.pak` in `assets/`

#### macOS

**Prerequisites:**
```bash
brew install cmake ninja pkg-config autoconf automake libtool
```

**Build Commands:**
```bash
# From repository root
cd source

# Intel Macs
cmake --preset=macos-release
cmake --build --preset=macos-release

# ARM/Apple Silicon Macs
cmake --preset=macos-arm-release
cmake --build --preset=macos-arm-release

# Copy required dylibs
cd ..
# Intel:
cp lib/osx/x64/*.dylib lib/osx/libsteam_api.dylib dist/

# ARM:
cp lib/osx/arm64/*.dylib lib/osx/libsteam_api.dylib dist/
```

**Post-Build Assembly:**
```bash
scripts/ci/macos/assemble.sh
# Creates: client_distribution/ and client.tar
```

**Important:** Rename `libdiscord_game_sdk.dylib` to `discord_game_sdk.dylib` in the appropriate arch folder before running.

**Runtime Setup:**
- Copy `sbinit.config` to `dist/`
- Copy Starbound's `packed.pak` to `assets/`
- May need: `xattr -d com.apple.quarantine starbound` to bypass macOS Gatekeeper

### Testing

**Run Tests:**
```bash
# Linux
cmake --build --preset=linux-release
ctest --preset=linux-release

# Windows
cmake --build --preset=windows-release
ctest --preset=windows-release

# macOS (Intel)
cmake --build --preset=macos-release
ctest --preset=macos-release
```

**Test Configuration:** Tests are defined in `source/test/`. Test preset filters for `NoAssets` label (tests that don't require game assets). Test framework is Google Test (gtest), included in `source/test/gtest/`.

**Typical Test Duration:** 5-30 seconds for NoAssets tests.

## Project Structure

### Key Directories

```
OpenStarbound/
├── source/              # All C++ source code
│   ├── application/     # Application framework
│   ├── base/           # Base utilities
│   ├── client/         # Game client code
│   ├── core/           # Core engine (largest directory)
│   ├── extern/         # External dependencies
│   ├── frontend/       # UI frontend
│   ├── game/           # Game logic (second largest)
│   ├── platform/       # Platform-specific code
│   ├── rendering/      # Rendering engine
│   ├── server/         # Game server code
│   ├── test/           # Unit tests
│   ├── utility/        # Utility libraries
│   ├── windowing/      # Window management
│   ├── CMakeLists.txt  # Main build configuration
│   ├── CMakePresets.json  # Build presets
│   ├── vcpkg.json      # Dependency manifest
│   └── vcpkg-configuration.json  # vcpkg baseline pin
├── assets/             # Game assets (opensb/ subdirectory has mod assets)
├── lib/                # Platform-specific libraries (windows/, linux/, osx/)
├── scripts/            # Build and utility scripts
│   ├── ci/            # CI-specific scripts (linux/, windows/, macos/)
│   ├── linux/         # Linux build scripts
│   └── windows/       # Windows build scripts
├── cmake/              # CMake helper modules
├── toolchains/         # CMake toolchain files
├── triplets/           # vcpkg custom triplets
├── doc/                # Lua API documentation
├── dist/               # Build output directory (gitignored)
├── build/              # CMake build directory (gitignored)
├── .clang-format       # Code formatting configuration
└── .github/workflows/  # GitHub Actions CI
    └── build.yml       # Main build workflow
```

### Important Files

- **CMakePresets.json**: Defines build presets for all platforms
- **vcpkg.json**: Lists all C++ dependencies (GLEW, SDL3, Opus, etc.)
- **vcpkg-configuration.json**: Pins vcpkg to specific baseline
- **.clang-format**: LLVM-based formatting (IndentWidth: 2, ColumnLimit: 0)
- **scripts/packing.config**: Asset packing configuration
- **scripts/steam_appid.txt**: Steam App ID (211820)

### Build Artifacts

- **dist/**: Contains built executables (starbound, starbound_server, asset_packer, asset_unpacker, btree_repacker, etc.)
- **client_distribution/**: Assembled client files ready for distribution
- **server_distribution/**: Assembled server files ready for distribution
- Build directories are created under `build/<preset-name>/` (e.g., `build/linux-release-clang/`)

## CI/CD Pipeline

### GitHub Actions Workflow (.github/workflows/build.yml)

**Trigger Conditions:**
- Push/PR to any branch affecting: `assets/**`, `source/**`, `toolchains/**`, `triplets/**`
- Manual workflow_dispatch with platform selection
- Pull requests: Only run linux-clang build
- Push events: Run configured platforms

**Build Jobs:**

1. **build_windows** (windows-latest)
   - Uses MSVC with vcpkg
   - Creates client, server, and installer (.exe via Inno Setup)
   - Artifacts: OpenStarbound-Windows-Client, OpenStarbound-Windows-Server, OpenStarbound-Windows-Installer

2. **build_linux** (ubuntu-22.04, GCC) - Optional
   - Runs tests via `ctest --preset=linux-release`
   - Artifacts: OpenStarbound-Linux-GCC-Client, OpenStarbound-Linux-GCC-Server

3. **build_linux_clang** (ubuntu-22.04, Clang) - Default for all PRs
   - Runs tests via `ctest --preset=linux-release`
   - Artifacts: OpenStarbound-Linux-Clang-Client, OpenStarbound-Linux-Clang-Server

4. **build-mac-intel** (macos-15-intel) - x86_64
   - Artifacts: OpenStarbound-macOS-Intel-Client

5. **build-mac-arm** (macos-14) - ARM64
   - Artifacts: OpenStarbound-macOS-Silicon-Client

**Key CI Steps:**
1. Checkout with submodules
2. Install CMake 3.29.2 and Ninja
3. Setup sccache (compiler cache)
4. Run vcpkg to install dependencies
5. Run CMake configure and build
6. Run tests (Linux only)
7. Post-build processing (Windows: copy DLLs, remove PDBs)
8. Assemble distribution files
9. Upload artifacts

**Build Times (typical):**
- Windows: 20-30 minutes
- Linux (Clang): 15-25 minutes
- Linux (GCC): 20-30 minutes
- macOS: 20-30 minutes

**Cache Strategy:**
- sccache for compiled objects (max 250-1000MB)
- vcpkg binary cache via TAServers/vcpkg-cache@v3

## Common Issues and Workarounds

### vcpkg Issues

**Problem:** CMake can't find vcpkg
- **Solution:** ALWAYS set `VCPKG_ROOT` environment variable before running CMake
- Verify: `echo $VCPKG_ROOT` (Linux/macOS) or `echo %VCPKG_ROOT%` (Windows)

**Problem:** vcpkg dependency installation fails
- **Solution:** Ensure vcpkg is bootstrapped (`./bootstrap-vcpkg.sh` or `.\bootstrap-vcpkg.bat`)
- On Fedora: May need additional `-static` and `-devel` packages for system libraries
- On Fedora: libsystemd/meson build errors require vcpkg update (post-May 2024)

### Linux-Specific Issues

**Problem:** CMake version too old
- **Solution:** Add Kitware APT repo or use snap: `snap install cmake --classic`

**Problem:** Fedora audio error: "dsp: No such audio device"
- **Solution:** Install `pulseaudio-utils` and use `padsp` wrapper: `padsp ./starbound`

**Problem:** Server GLIBC version compatibility
- **Solution:** CI applies patchelf to clear symbol versions for exp, exp2, log, log2, pow (see `scripts/ci/linux/assemble.sh`)

### macOS Issues

**Problem:** "Unverified developer" error
- **Solution:** `xattr -d com.apple.quarantine starbound` or `sudo spctl --master-disable`

**Problem:** Discord SDK library not loading
- **Solution:** Rename `libdiscord_game_sdk.dylib` to `discord_game_sdk.dylib` in `lib/osx/arm64/` or `lib/osx/x64/`

### Build Issues

**Problem:** Build fails with missing headers
- **Solution:** Ensure all system dependencies are installed (see platform-specific sections)
- Clean build: delete `build/` and `source/CMakeCache.txt`, reconfigure

**Problem:** Link errors related to Steam or Discord
- **Solution:** Libraries are in `lib/<platform>/`. Ensure paths are correct in CMake configuration

**Problem:** Asset packer/unpacker not found
- **Solution:** These are built during main build. Check `dist/` directory

## Code Formatting

The project uses `.clang-format` with LLVM style:
- IndentWidth: 2 spaces
- No column limit (ColumnLimit: 0)
- Never use tabs (UseTab: Never)
- Run formatter: `clang-format -i <file>`

Manual formatting script: `scripts/format-source.sh`

## Validation Steps

Before submitting changes:

1. **Build the code** for your platform
2. **Run tests** if on Linux (CI will run them)
3. **Check formatting** with clang-format if modifying C++ code
4. **Test runtime**: Copy required libraries and sbinit.config to `dist/`, copy `packed.pak` to `assets/`, run `./starbound` or `starbound.exe`
5. **Verify CI passes**: GitHub Actions must complete successfully

## Additional Notes

- **Assets:** The game requires `packed.pak` from a legitimate Starbound installation. This is NOT included in the repository.
- **Steam Integration:** Enabled by default. Steam App ID is 211820.
- **Discord Integration:** Enabled on Windows/Linux, disabled on macOS by default
- **Memory Allocators:** 
  - Windows: rpmalloc
  - Linux: jemalloc
  - macOS: system allocator
- **Installer:** Windows builds create an Inno Setup installer (see `scripts/inno/setup.iss`)

## For Coding Agents

**Trust these instructions.** Only search for additional information if:
- Instructions are incomplete for your specific task
- Instructions contain errors (validate and report)
- You need to understand specific code behavior beyond build/test

**Priority actions:**
1. Always set `VCPKG_ROOT` before any CMake operation
2. Install platform dependencies first
3. Build from the `source/` directory using presets
4. Run tests on Linux builds
5. Verify runtime setup (libraries, config, assets) before claiming success

**File paths are absolute.** All commands assume you start from the repository root unless stated otherwise.
