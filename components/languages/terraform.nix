# Terraform/OpenTofu language configuration function
# Note: tofu.nix is the canonical module; this file re-exports it.
args:
(import ./tofu.nix) args
