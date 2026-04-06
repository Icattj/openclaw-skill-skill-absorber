# ---

> OpenClaw AI Agent Skill

---
name: skill-absorber
description: Analyze any GitHub repo, tool, or AI agent framework and extract its best capabilities into native OpenClaw skills. Use when given a GitHub URL to study, when asked to replicate features from another tool (Hermes, Cursor, Claude Code, Devin, etc.), when asked to "absorb" or "steal" or "extract" capabilities from a project, or when asked to make a skill from an external tool. Also handles pulling skills from Claude's ecosystem or any agent skill marketplace.
---

# Skill Absorber — Universal Capability Extractor

Turn any GitHub repo or AI tool into a native OpenClaw skill.

## Core Workflow

### Phase 1: Reconnaissance
1. Fetch the repo README (web_fetch the GitHub URL)
2. If README is thin, also fetch: `docs/`, `src/` structure, `package.json` or `pyproject.toml`
3. Identify: **what it does**, **how it works**, **what dependencies it needs**, **what APIs it uses**
4. Classify the repo into one or more capability types (see references/capability-types.md)

### Phase 2: Capability Mapping
For each capability found, determine:
- **Can we replicate it?** (Yes / Partial / No — explain why)
- **What's the minimal implementation?** (script, API call, CLI wrapper, or full service)
- **What exists already?** (check installed skills in `~/.openclaw/workspace/skills/`)
- **Dependencies?** (npm packages, Python libs, system tools, API keys)

### Phase 3: Skill Generation
For each extractable capability:
1. Create skill folder: `~/.openclaw/workspace/skills/<skill-name>/`
2. Write `SKILL.md` with proper frontmatter following skill-creator conventions
3. Write scripts in `scripts/` — prefer bash/node/python, keep them executable
4. Write `references/` for any domain knowledge needed
5. If the original tool has an installable CLI, wrap it rather than rewrite it
6. Test the skill by running its core script

### Phase 4: Integration
1. Verify the skill is detected by OpenClaw (check AGENTS.md skill list or restart)
2. Document what was absorbed and what was skipped (with reasons)
3. Log to memory: `memory/YYYY-MM-DD.md` — what was absorbed, from where

## Decision Framework

### When to WRAP (use the original tool)
- Tool is well-maintained, has a CLI, and does something complex (yt-dlp, gh, bird)
- Rewriting would take days and produce an inferior version
- Tool has active maintainers handling edge cases

### When to REPLICATE (build our own)
- The concept is simple but the repo is bloated
- We need tight integration with OpenClaw/Council
- The tool is abandoned or poorly maintained
- License is restrictive

### When to SKIP
- Capability already exists in an installed skill
- Requires infrastructure we don't have (GPU cluster, specific cloud service)
- The "feature" is mostly marketing and adds no real value

## Repo Analysis Checklist

```
□ README — what does it claim to do?
□ Architecture — how is it structured? (monorepo, CLI, library, service)
□ Dependencies — what does it need? (check package.json, requirements.txt, Cargo.toml)
□ License — can we use/wrap it? (MIT/Apache = yes, GPL = wrap only, proprietary = skip)
□ Stars/Activity — is it maintained? (last commit, open issues)
□ Core scripts — what are the key executables?
□ Config format — how is it configured?
□ API surface — does it expose APIs we can call?
□ Skill potential — map each feature → skill
```

## Multi-Repo Absorption

When given multiple repos at once:
1. Analyze each independently
2. Look for overlapping capabilities — deduplicate
3. Pick the best implementation for each capability
4. Generate unified skills (don't create 3 search skills from 3 repos)

## Special Cases

### Absorbing from Agent Frameworks (Hermes, AutoGPT, CrewAI, etc.)
Focus on their UNIQUE features, not generic agent stuff we already have. Extract:
- Novel tool patterns
- Memory/learning architectures
- Workflow orchestration patterns
- Skill/plugin systems (adapt their best plugins)

### Absorbing from Claude/Anthropic Ecosystem
- Check https://github.com/anthropics for official tools
- Check Claude's tool_use patterns for inspiration
- Adapt MCP servers into OpenClaw skills where useful

### Absorbing CLI Tools
Prefer wrapping over rewriting:
```bash
# Good: wrap the CLI
scripts/search.sh → calls `bird` CLI underneath
# Bad: rewrite bird from scratch in Python
```

## Output Format

After absorption, report to user:

```
## Absorbed from [repo-name]

### Skills Created
- **skill-name** — what it does (wrapped/replicated)

### Skipped
- Feature X — reason (already exists / too complex / no value)

### Dependencies Installed
- tool-name (via npm/pip/apt)

### Notes
- Any caveats or limitations
```

## References
- See references/capability-types.md for classification taxonomy
- Follow skill-creator conventions for all generated skills

## Installation

```bash
cp -r skill-absorber/ ~/.openclaw/workspace/skills/skill-absorber/
```

## License

MIT © [Sentra Technology](https://github.com/Icattj)
