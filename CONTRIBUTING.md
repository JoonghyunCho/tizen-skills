# Contributing to Tizen Agent Skills

Thank you for your interest in contributing! This repo packages procedural knowledge about Tizen .NET development as [Agent Skills](https://agentskills.io) that work across AI coding agents.

## What makes a good skill

Skills here should:

1. **Encode Tizen-specific knowledge** that general-purpose AI models don't reliably have
2. **Be portable** — avoid agent-specific features; write to the agentskills.io standard
3. **Be progressive** — keep `SKILL.md` under 500 lines; push detail into `references/` files
4. **Be testable** — include enough context (error signatures, version strings, commands) that you can tell when the skill fires correctly

## Repository layout

```
plugins/
└── <plugin-name>/
    ├── plugin.json               # Plugin manifest
    └── skills/
        └── <skill-name>/
            ├── SKILL.md          # Required
            ├── scripts/          # Optional — executable helpers
            ├── references/       # Optional — detail files loaded on demand
            └── assets/           # Optional — templates, data tables
```

### Plugin vs skill

- A **plugin** is a domain-scoped bundle (e.g., `tizen`, `tizen-nui`, `tizen-maui`). Mirrors the `dotnet/skills` convention.
- A **skill** is a single task-focused unit inside a plugin (e.g., `tizen-doctor`, `nui-layout-debug`).

Pick the smallest plugin that fits. If unsure, open a discussion before adding a new plugin.

## Adding a new skill

1. Create the folder: `plugins/<plugin>/skills/<skill-name>/`
2. Write `SKILL.md` with required frontmatter:
   ```markdown
   ---
   name: <skill-name>                 # must match parent folder name
   description: <what + when to use>  # max 1024 chars, include keywords
   license: MIT
   ---
   ```
3. Add scripts/references/assets as needed
4. Validate:
   ```bash
   skills-ref validate ./plugins/<plugin>/skills/<skill-name>
   ```
5. Register the skill in `plugins/<plugin>/plugin.json` if using an explicit skill list (otherwise `./skills/` glob picks it up)
6. Open a PR with:
   - Short description of what the skill does and why it's needed
   - Example prompts that should activate it
   - Platforms tested (Linux / Windows / macOS)

## SKILL.md style

- **Frontmatter**: keep `description` specific and keyword-rich. Agents match on it.
- **Body**: write in English. Use short sentences and tables for decision matrices.
- **No nitpicks**: don't encode subjective style preferences; focus on factual Tizen behavior.
- **Version-aware**: mention Tizen API Level floors and .NET TFM requirements explicitly.

## Keeping reference data fresh

Reference tables (TFM ↔ Workload version mapping, API Level feature introduction, privilege lists) go stale. Add a **Last reviewed** date at the top of each reference file, and update it when you verify.

## Testing a skill locally

```bash
# Claude Code — point at local path
claude plugin install ./plugins/tizen

# Or load an individual SKILL.md directly, depending on your agent
```

Then prompt the agent with the example scenarios from your PR.

## Code of Conduct

Be respectful. This is a small, friendly community. Disagree with ideas, not people.

## License

All contributions are licensed under MIT. By submitting a PR, you agree to license your contribution under the same terms.
