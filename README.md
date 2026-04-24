# Tizen Agent Skills

A curated collection of [Agent Skills](https://agentskills.io) for Tizen .NET development.
Help AI coding agents (Claude Code, GitHub Copilot, VS Code, Cursor, Codex, …) understand the Tizen .NET ecosystem: build setup, Workloads, NUI patterns, API Level compatibility, emulator / `sdb`, packaging, and more.

> Inspired by and modeled after [`dotnet/skills`](https://github.com/dotnet/skills). Adheres to the open [agentskills.io](https://agentskills.io) specification, so a single skill bundle works across all compatible agents.

## Why this exists

Tizen .NET has specific conventions — `build.sh` entry points, `net*-tizen` TFMs requiring the Tizen Workload, Tizen API Level compatibility, `sdb` tooling, privilege manifests — that general-purpose AI coding assistants don't know out of the box. Bundling this procedural knowledge as Agent Skills gives any compatible agent instant Tizen .NET expertise without model retraining.

## Plugins

| Plugin | Description | Status |
|---|---|---|
| [`tizen`](./plugins/tizen) | Core Tizen .NET skills: environment diagnosis, build, Workload setup, packaging | 🟢 initial |
| `tizen-nui` | NUI framework patterns, layout, migration from Xamarin.Forms | 📝 planned |
| `tizen-api` | Tizen API Level compatibility, privilege manifest, capability lookup | 📝 planned |
| `tizen-emulator` | Emulator / `sdb` / certificate profile setup | 📝 planned |
| `tizen-maui` | .NET MAUI on Tizen: setup, head configuration, troubleshooting | 📝 planned |

### Current skills in `tizen` plugin

- **`tizen-doctor`** — Diagnose a Tizen .NET development environment and guide the user through fixing missing or misconfigured components (SDKs, Workloads, `sdb`, certificates). Cross-platform (Linux / Windows / macOS).

## Installation

### Claude Code

```bash
# Add this repo as a marketplace, then install a plugin
claude plugin marketplace add JoonghyunCho/tizen-skills
claude plugin install tizen
```

### GitHub Copilot (CLI / VS Code)

Follow [Copilot Agent Skills install docs](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills) — point it at this repo.

### Other agents (Cursor, Codex, Gemini CLI, Goose, …)

Because the skills conform to the [agentskills.io](https://agentskills.io) standard, any compatible client can load them. See the [Client Showcase](https://agentskills.io/clients) for per-tool instructions.

### Local (manual)

```bash
git clone https://github.com/JoonghyunCho/tizen-skills.git
# Point your agent at plugins/tizen/skills/ to load skills directly
```

## Using a skill

Skills are loaded via **progressive disclosure** — agents only pull in the full instructions when a task matches. A few examples that should activate `tizen-doctor`:

- "Why does `dotnet build` fail with NETSDK1139 on my Tizen project?"
- "Set up a fresh machine for TizenFX development on WSL."
- "The Tizen Workload shows as installed but `net8.0-tizen11.0` still fails to resolve."

The agent then runs environment-collection scripts, interprets the result against the Tizen .NET reference tables, and gives a prioritized fix list.

## Repository layout

```
tizen-skills/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── .claude-plugin/
│   └── marketplace.json      # Marketplace entry for Claude Code
└── plugins/
    └── tizen/
        ├── plugin.json       # Plugin manifest
        └── skills/
            └── tizen-doctor/
                ├── SKILL.md
                ├── scripts/
                └── references/
```

Each plugin is a self-contained bundle that can be installed independently.

## Compatibility

- **Tizen TFMs**: `net6.0-tizen8.0` (API 11), `net6.0-tizen9.0` (API 12), `net8.0-tizen10.0` (API 13), `net8.0-tizen11.0` (API 14) — see [`tfm-workload-matrix`](./plugins/tizen/skills/tizen-doctor/references/tfm-workload-matrix.md) for the full table including unversioned fallbacks
- **.NET SDK bands**: 6.0 and 8.0
- **Tizen API Level**: 11 – 14 (platform 8.0 / 9.0 / 10.0 / 11.0)
- **OS**: Linux (Ubuntu 20.04+ / WSL2), Windows 10+, macOS 12+

## Contributing

Contributions welcome — new skills, refinements to existing ones, platform-specific fixes. See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines, and validate your skill with the [`skills-ref`](https://github.com/agentskills/agentskills/tree/main/skills-ref) tool before submitting:

```bash
skills-ref validate ./plugins/tizen/skills/tizen-doctor
```

## License

MIT. See [LICENSE](./LICENSE).

## Acknowledgements

- [Agent Skills](https://agentskills.io) standard, originally released by Anthropic
- [`dotnet/skills`](https://github.com/dotnet/skills) for the reference plugin layout
- The TizenFX maintainer community for the conventions this codifies
