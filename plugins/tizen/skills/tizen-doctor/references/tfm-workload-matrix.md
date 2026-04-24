# Tizen TFM ↔ Workload ↔ API Level matrix

**Last reviewed:** 2026-04-24

Quick lookup for matching a project's target framework moniker (TFM) with the
right .NET SDK band, Tizen Workload version, Tizen platform version, and the
`Tizen.NET.APInn` package it implicitly depends on.

Use this to diagnose `NETSDK1139` (target platform not recognized) and
`NETSDK1147` (workload missing) errors, and to tell whether a machine's
current install can build a given project.

## TFM naming convention

Tizen TFMs have the form:

```
net<dotnet-version>-tizen<tizen-platform-version>
```

The platform suffix is **required** for formal projects — `net8.0-tizen` without
a version suffix resolves to a generic moniker that does not pin a Tizen.NET.API
version and should be avoided in shipping code. The formal, versioned forms are:

| TFM                 | .NET SDK band | Tizen Workload band | Tizen platform | API Level | Implicit `Tizen.NET.API*` package |
|---------------------|---------------|---------------------|----------------|-----------|-----------------------------------|
| `net6.0-tizen8.0`   | .NET 6 SDK    | `6.0.*`             | 8.0            | 11        | `Tizen.NET.API11`                 |
| `net6.0-tizen9.0`   | .NET 6 SDK    | `6.0.*`             | 9.0            | 12        | `Tizen.NET.API12`                 |
| `net8.0-tizen10.0`  | .NET 8 SDK    | `8.0.*`             | 10.0           | 13        | `Tizen.NET.API13`                 |
| `net8.0-tizen11.0`  | .NET 8 SDK    | `8.0.*`             | 11.0           | 14        | `Tizen.NET.API14`                 |

Unversioned fallbacks that still resolve (via `Tizen.NET.nuspec` dependency groups)
but are not recommended for new project files:

| TFM           | Resolves to |
|---------------|-------------|
| `net6.0-tizen` | latest `net6.0-tizen*` group — currently `Tizen.NET.API12` |
| `net8.0-tizen` | latest `net8.0-tizen*` group — currently `Tizen.NET.API14` |
| `net6.0`       | `Tizen.NET.API12` |
| `net8.0`       | `Tizen.NET.API14` |

(Derived from the `<group targetFramework="…">` entries in `pkg/Tizen.NET/Tizen.NET.nuspec`.)

The Workload version tracks the .NET SDK band — picking `net8.0-tizen11.0` means
the Tizen Workload for the .NET 8 SDK band must be installed; the `tizen11.0`
suffix is a **platform binding**, not a workload selector.

## Installing / updating the Workload

```bash
# Install for the currently active SDK band
dotnet workload install tizen

# Update installed workloads to the latest matching version
dotnet workload update

# See what's installed
dotnet workload list
```

If the project targets `net8.0-tizen11.0` and the machine has both .NET 6 and
.NET 8 SDKs, the workload must be installed for **the .NET 8 SDK**. Running
`dotnet workload install tizen` resolves against the currently active `dotnet`
(the one `dotnet --version` prints) — check `dotnet --info` to confirm which
SDK will be patched before running the install.

## Common mismatches and their signatures

| Symptom                                                                                                      | Likely cause                                                                                                       |
|--------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|
| `NETSDK1139 The target platform identifier tizen was not recognized`                                         | Workload for the active SDK band is not installed.                                                                 |
| `NETSDK1147 To build this project, the following workloads must be installed: tizen`                         | Same as above; .NET 7+ gives a more explicit message.                                                              |
| Build succeeds locally but CI fails with `Tizen.NET.Sdk not found`                                           | CI image is on a different SDK band than local; install the matching workload in the pipeline.                    |
| `Package Tizen.NET.API13 is not compatible with net6.0-tizen9.0`                                             | API Level package version is tied to the TFM's platform suffix — API13 is for `net8.0-tizen10.0`, not `net6.0-*`.  |
| `dotnet workload list` shows `tizen` but `dotnet build` still errors with NETSDK1139                         | `dotnet` on PATH resolves to a *different* SDK than the one the workload was installed against.                    |
| `net8.0-tizen` resolves to the wrong API package                                                             | Unversioned TFM — pin to `net8.0-tizen10.0` or `net8.0-tizen11.0` instead.                                         |

## Cross-references

- Agent workflow that uses this table: [`../SKILL.md`](../SKILL.md)
- Upstream Workload release notes: <https://github.com/dotnet/sdk/releases>
- TizenFX API Level contract & Tizen.NET.nuspec: <https://github.com/Samsung/TizenFX/blob/main/pkg/Tizen.NET/Tizen.NET.nuspec>

## Maintenance

This reference goes stale whenever a new Tizen Workload or platform version
ships. When updating:

1. Bump the **Last reviewed** date at the top.
2. Cross-check against `pkg/Tizen.NET/Tizen.NET.nuspec` in TizenFX — each
   `<group targetFramework="…">` entry there is the source of truth for the
   TFM ↔ API package mapping.
3. Add a new row to the TFM matrix when a new `net<N>.0-tizen<M>.0` pair is
   published.
4. Capture any newly-observed error signatures in the "Common mismatches" table.
