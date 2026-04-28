# tizen-skills (marketplace mirror)

A Claude Code plugin marketplace mirror of AI agent skills maintained at
[**Samsung/Tizen.NET**](https://github.com/Samsung/Tizen.NET/tree/main/.agents/skills).

This repo exists so Tizen .NET app developers can install the skills with a
single command, without cloning the Workload source repo.

> **Source of truth**: skill content lives in
> [`Samsung/Tizen.NET/.agents/skills/`](https://github.com/Samsung/Tizen.NET/tree/main/.agents/skills).
> Manual edits to `plugins/tizen/skills/` here will be overwritten on the next
> mirror run. Send fixes / new skills as PRs to **Samsung/Tizen.NET**.

## Installation

### Claude Code

```bash
claude plugin marketplace add JoonghyunCho/tizen-skills
claude plugin install tizen
```

### Other compatible agents (Cursor, Copilot, Codex, …)

The skills follow the [agentskills.io](https://agentskills.io) standard and
work with any compliant client. See the
[Client Showcase](https://agentskills.io/clients) for per-tool instructions,
or copy `plugins/tizen/skills/<skill>/` into your own
`~/.agents/skills/<skill>/`.

## Skills currently mirrored

| Skill | What it does |
|---|---|
| [`tizen-doctor`](./plugins/tizen/skills/tizen-doctor/SKILL.md) | Diagnose Tizen .NET build environment failures (NETSDK1139, missing Tizen Workload, `net*-tizen*.0` TFM resolution, `WorkloadManifest.json` Ref pack inspection) and produce a prioritized fix list. Cross-platform (Linux / Windows / macOS / WSL2). |

## How the mirror works

[`.github/workflows/mirror-from-tizen-net.yml`](./.github/workflows/mirror-from-tizen-net.yml)
runs every 4 hours (or on manual trigger), fetches
`Samsung/Tizen.NET/.agents/skills/tizen-doctor/` via sparse checkout,
syncs it under `plugins/tizen/skills/tizen-doctor/`, and commits if anything
changed. The commit message records the upstream SHA for traceability.

Propagation lag from a Samsung/Tizen.NET merge to a successful `claude plugin
install` is typically **0 – 4 hours** (whenever the next scheduled run fires).
For faster propagation after a critical fix, run the workflow manually from
the Actions tab.

## Contributing

**Don't open PRs here.** Send changes to
[Samsung/Tizen.NET](https://github.com/Samsung/Tizen.NET) — the skills live at
`.agents/skills/<name>/`. Once that PR merges, the mirror picks it up
automatically.

The exception is the mirror plumbing itself (this README, the workflow YAML,
plugin manifests). Those are owned by this repo.

## Compatibility

- **Tizen TFMs**: `net6.0-tizen8.0`, `net6.0-tizen9.0`, `net8.0-tizen10.0`,
  `net8.0-tizen11.0` (see the matrix shipped with each skill)
- **OS**: Linux (Ubuntu 20.04+ / WSL2), Windows 10+, macOS 12+
- **Agents**: any agentskills.io-compatible client

## License

Skill content is licensed by Samsung/Tizen.NET (see that repo's LICENSE).
The mirror plumbing (workflow YAML, this README, plugin manifests) is MIT.
