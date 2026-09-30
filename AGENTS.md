# Agents Context: nix-config

## Project Overview
NixOS configuration repository for multiple hosts (bobo, lina, goku, etc.).
Canonical checkout: /Users/dd/Library/Mobile Documents/com~apple~CloudDocs/Documents/00-Project/00-code/GitHub/nix-config

## Folder Structure
- `hosts/` : Per-host configurations (e.g., `hosts/cephbobo/default.nix`).
- `modules/` : Shared NixOS modules.
    - `common/` : Base system, hardware, network, vfio, and libvirtd modules.
    - `hosts/` : Host-specific module definitions (e.g., `modules/hosts/bobo.nix`).
    - `containers/` : Configuration for containers and microVMs.
- `secrets/` : Secret management (Agenix).
- `shells/` : Development shell configurations.
- `scripts/` : Utility scripts for system inspection and management.
- `flake.nix` : Entry point for Nix Flakes.

## Workdir
workdir: .

## Host Map
- bobo: Main server (AMD)
- lina: Server (Intel)
- goku: Server (Intel)
- dev: Local development host

## Key Workflows
- Deployment: Use Colmena (`just bobo`, etc.).
- Recovery: Boot via NixOS USB, mount target disks, run `nixos-install --flake .#<host>`.
- VFIO/Passthrough: Managed via `modules/common/vfio.nix` and host-specific `bdx0.vfio` options.

## Critical Constraints
- Bobo recovery: Avoid `vfio_pci` in initrd to prevent boot hangs. If `bdx0.libvirtd.enable = true`, it forces `bdx0.vfio.enable = true` which pulls VFIO into initrd. Disable both for recovery.
- Disk layout: Preserve existing LVM/NVMe layouts on bobo; no destructive `disko` unless explicitly requested.
- Mounts: Use `nofail` for auxiliary NTFS mounts (e.g., Data1T) to prevent boot hangs.
- Target Store: When installing from USB live, use `--store "local?root=/mnt"` to avoid I/O bottlenecks on the USB medium.
