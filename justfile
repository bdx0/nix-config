SOPS_FILE := "secrets/secrets.yaml"
# List all the just commands
default:
	# apply
	@just --list

alias b := build
alias a := apply

hostname := `hostname | cut -d "." -f 1`

# build main
build:
	colmena build --show-trace

apply:
	colmena apply --impure --show-trace

mac2014:
	colmena apply --impure --on mac2014 --show-trace

test:
	colmena apply --impure --on "nix-infect.local"

lina:
	colmena apply --impure --on lina --show-trace

lina01:
	colmena apply --impure --on lina01 --show-trace

lina02:
	colmena apply --impure --on lina02 --show-trace

goku:
	colmena apply --impure --on goku --show-trace

goku01:
	colmena apply --impure --on goku01 --show-trace

goku02:
	colmena apply --impure --on goku02 --show-trace

bobo:
	colmena apply --impure --on bobo --show-trace

bobo01:
	colmena apply --impure --on bobo01 --show-trace

bobo02:
	colmena apply --impure --on bobo02 --show-trace

nix01:
	colmena apply --impure --on nix01 --show-trace

nix02:
	colmena apply --impure --on nix02 --show-trace

nix03:
	colmena apply --impure --on nix03 --show-trace

dev:
	colmena apply --impure --on dev --show-trace

scratchHost:
	nix run .#remoteInstall -- scratchHost --debug -L

update:
	nix flake update

gc HOST generations="5":
	#!/usr/bin/env sh
	ssh root@{{HOST}} cat /etc/hostname &&
		nix-env --delete-generations {{generations}} &&
		nix-store --gc &&
		nix-collect-garbage -d


k8s_bootstrap:
	nix run nixpkgs#kubectl -- apply -f k8s/cloudflared.yaml

# Garbage collect old OS generations and remove stable packages from the nix store
gclocal generations="5":
	nix-env --delete-generations {{generations}}
	nix-store --gc
	nix-collect-garbage -d


# alias j := `just --justfile ./containers/docker/justfile --working-directory ./containers/docker`
j *args:
	cd ./containers/docker && nix run nixpkgs#just -- {{args}}

drive:
	just j deploy lina01
	just j deploy nix01
	just j deploy bobo01

repair:
	nix-store --verify --repair --check-contents