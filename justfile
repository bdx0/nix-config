# List all the just commands
default:
	# apply
	@just --list

alias b := build
alias a := apply

hostname := `hostname | cut -d "." -f 1`

# build main
build:
	colmena build

apply:
	colmena apply --impure

mac2014:
	colmena apply --impure --on mac2014

lina:
	colmena apply --impure --on lina --show-trace

test:
	colmena apply --impure --on "nix-infect.local"

bobo:
	colmena apply --impure --on bobo

update:
	nix flake update

gc HOST generations="5":
	#!/usr/bin/env sh
	ssh root@{{HOST}} cat /etc/hostname &&
		nix-env --delete-generations {{generations}} &&
		nix-store --gc &&
		nix-collect-garbage -d


# Garbage collect old OS generations and remove stable packages from the nix store
gclocal generations="5":
	nix-env --delete-generations {{generations}}
	nix-store --gc
	nix-collect-garbage -d

repair:
	nix-store --verify --repair --check-contents