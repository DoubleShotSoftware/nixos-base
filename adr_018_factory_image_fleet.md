# ADR‑018 — Fleet Bootstrapping with a Tiny Factory Image, sops‑nix + age, and Persistent /nix

\*Status  : \****Accepted***\
*Date    : 2025‑07‑06*

---

## 1  Context

We operate \~50 libvirt VMs (“cattle”) plus three pet bare‑metal hosts.  Pain points we wanted to remove:

1. **Tedious release bumps** (24.11 → 25.05) across three flakes (`nix‑base`, `home‑manage`, `nixvim`).
2. **Secrets churn** while migrating from SSH‑PGP to SSH‑age.
3. **QCOW images > 10 GiB & root disks filling up** after a few `nixos‑rebuild`s.

Goals ⇢

- One *tiny* immutable base image reused by every VM.
- Host‑specific config & secrets live on an encrypted second disk.
- Pull‑based GitOps: each guest polls, builds and switches itself.
- Five bootable generations, automatic GC, zero‑touch key rotation.

---

## 2  Decision

1. **Two‑disk layout**
   - `vda` — 2 GiB read‑only *factory* QCOW2 built once from `minimal.nix`.
   - `vdb` — LUKS‑encrypted Btrfs, mounted at **/persist** and available in stage‑1.
2. **Store relocation**
   - On first boot a `seed‑nix-store` oneshot *rsync*s `/nix` → `/persist/nix`, then bind‑mounts it permanently. (OverlayFS is an alternative.)
3. **Secrets via sops‑nix + age**
   - `sops.age.keyFile = "/persist/keys/host.agekey"; generateKey = true;` so fresh VMs self‑bootstrap.
   - Deploy keys & PAT live in an encrypted `secrets/git-creds.yaml` and are rendered to `/run/secrets/*`.
4. **Config pull + self‑upgrade**
   - `sync-config` systemd unit clones / pulls the flake listed in `/persist/config.json`.
   - `system.autoUpgrade` builds `/persist/nixos#${hostname}` nightly, keeps **5** generations and reboots if needed.
5. **House‑keeping**
   - `nix.gc.automatic = true; options = "--delete-older-than 14d";`
   - `nix.optimise.automatic = true; settings.auto-optimise-store = true;`
   - Btrfs uses `compress=zstd`.

---

## 3  Rationale

- A single QCOW2 avoids the 10 GiB per‑VM rebuild pain; image never mutates → perfect for CI caching.
- Moving the store prevents the "split‑head" problem and gives us the full space of the second disk.
- `sops-nix` already in use → trivial to swap PGP out and age in by changing `.sops.yaml` and running `sops updatekeys`.
- Pull‑based timers work even with intermittent laptops; no central orchestrator required.

---

## 4  Consequences

### Positive

- Release bump is \`\`\*\* + wait\*\*; fleet converges within 24 h.
- Key or PAT rotation is one command (`sops updatekeys`); no host rebuild.
- Root image can be refreshed (new kernel, CVE fix) by replacing `vda`; no state loss.

### Negative / Risks

| Risk                        | Mitigation                                                                                 |
| --------------------------- | ------------------------------------------------------------------------------------------ |
| Missing `/persist` at boot  | Bind‑mount fails → falls back to factory store so VM still boots for rescue.               |
| Bad `config.json`           | Service fails; auto‑upgrade skips → previous generation continues running.                 |
| Store still grows unbounded | Daily GC + 5‑generation limit + Btrfs compression keeps usage low.                         |
| Gitea host‑key rotation     | `StrictHostKeyChecking=accept-new` only on first pull; later mismatches abort pull safely. |

---

## 5  Implementation Sketch

```nix
{ lib, ... }: {
  systemd.services.seed-nix-store = {
    description = "Move initial Nix store to /persist, then bind-mount it";
    conditionPathIsDirectory = "!/persist/nix/store";
    after  = [ "local-fs.target" ];
    wantedBy = [ "nixos.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /persist/nix
      rsync -aH --ignore-existing /nix/ /persist/nix/
      mount --bind /persist/nix /nix
    '';
  };
  fileSystems."/nix" = {
    device = "/persist/nix";
    fsType = "none";
    options = [ "bind" ];
  };
}
```

```nix
let cfg = "/persist/config.json"; in {
  systemd.services.sync-config = {
    after = [ "network-online.target" "sops-nix.service" ];
    script = ''
      set -eu
      HOST=$(jq -r .hostname ${cfg})
      REPO=$(jq -r .repo      ${cfg})
      BR=$(jq -r .branch     ${cfg})

      if [ ! -d /persist/nixos/.git ]; then
        git clone --branch "$BR" "$REPO" /persist/nixos
      fi
      git -C /persist/nixos pull --ff-only || true
    '';
  };
  systemd.timers.sync-config.timerConfig = { OnBootSec="10m"; OnUnitActiveSec="1h"; RandomizedDelaySec="10m"; };

  system.autoUpgrade = {
    enable = true;
    flake  = "/persist/nixos#${config.networking.hostName}";
    dates  = "03:30";
    allowReboot = true;
    persistentTimer = true;
  };
}
```

---

## 6  References

- NixOS `system.autoUpgrade` module – upstream docs.
- sops‑nix manual §*age backend* – auto‑generate host key.
- Discussion: “Bind‑mounting /nix on a secondary disk” (Discourse, 2024‑11).
- Local Overlay Store design doc – Nix 2.22 (RFC 0146).

---

## 7  Status & Next Steps

- **Accepted** — rolled to `vm‑42` on 2025‑07‑01; seven days stable.
- Roll out to remaining guests, then remove the legacy per‑VM QCOW pipeline.
- Close ADR‑016/017 as superseded by this consolidated record.

