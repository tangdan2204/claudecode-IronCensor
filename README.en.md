<div align="center">

# IronCensor

### The Iron Censor — Cognitive Agent Framework for Claude Code

#### Transform Claude Code from a passive code editor into an autonomous intelligent engineer with a complete cognitive cycle

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue.svg)]()
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-green.svg)]()

[中文](./README.md) | [日本語](./README.ja.md) | [한국어](./README.ko.md)

**Author: Tangdan / 汤旦**

</div>

---

## Core Innovations

> **You are not a passive code editor. You are an intelligent engineer with a complete cognitive cycle.**

IronCensor injects a complete autonomous agent system into Claude Code through **pure configuration** (zero code modification):

| Capability | Description | Traditional Claude Code |
|------------|-------------|------------------------|
| **7-Stage Cognitive Cycle** | Perceive→Think→Plan→Execute→Verify→Reflect→Evolve | Receive→Execute→Done |
| **8-Layer Defense-in-Depth** | Hard intercept + Monitoring + Soft constraints, AI cannot bypass | Prompt-only constraints |
| **Self-Learning Evolution** | Error tracking→Global audit→Rule hardening→Automation | No learning mechanism |
| **Three Departments Governance** | Decision/Review/Execution separation with veto power | No governance framework |
| **Evidence-Driven Verification** | Must provide actual test/build/lint output | "Should be fine" |
| **Unattended Execution** | Auto-routing + Auto-supervision + Auto-circuit-breaking | Requires constant human intervention |

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│                Claude Code Agent System                       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─ Hard Security Layer (Hooks + settings.json) ─────────┐  │
│  │  Layer 0: settings.json deny (24 absolute rules)       │  │
│  │  Layer 1: safety-guard.sh  (meta-cmd + danger ops      │  │
│  │           + bypass detection)                           │  │
│  │  Layer 2: sensitive-filter.sh (24 secret patterns)     │  │
│  │  [exit 2 hard block — AI CANNOT bypass]                │  │
│  └────────────────────────────────────────────────────────┘  │
│  Rules externalized: rules/dangerous-commands.txt            │
│                      rules/sensitive-patterns.txt            │
│                                                              │
│  ┌─ Auxiliary Monitor Layer (Hooks) ─────────────────────┐  │
│  │  Layer 3: pre-compact-save.sh    (state snapshot)      │  │
│  │  Layer 4: post-compact-restore.sh (context recovery)   │  │
│  │  Layer 5: post-edit-audit.sh     (audit + breaker)     │  │
│  │  Layer 6: verify-before-stop.sh  (4-point checklist)   │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ Behavioral Layer (CLAUDE.md) ────────────────────────┐  │
│  │  Layer 7: Intelligent OS v1                            │  │
│  │  ├─ 7-Stage Cognitive Cycle                            │  │
│  │  ├─ Three Departments Governance Framework             │  │
│  │  ├─ Decision Tree Routing                              │  │
│  │  └─ 4-Layer Self-Learning Model                        │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ Memory Persistence Layer ────────────────────────────┐  │
│  │  MEMORY.md + recurring-patterns.md + compact-state.md  │  │
│  │  hook-stats.jsonl (interception statistics)             │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ Configuration Hub ─────────────────────────────────────┐  │
│  │  configs/env.sh (unified paths/thresholds,              │  │
│  │                  single point of change)                │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

---

## Key Innovations

### 1. Seven-Stage Cognitive Cycle

Every task goes through a complete cognitive loop: **Perceive** (intent recognition + context awareness + memory recall + risk assessment) → **Think** (proactively invoke specialist agents) → **Plan** (decision tree routes to optimal execution path) → **Execute** (test-as-you-go + report every 3 steps) → **Verify** (must provide actual test/build output) → **Reflect** (pattern detection + extrapolation) → **Evolve** (correction upgrade chain: 1x→record, 2x→rule, 3x→automation).

### 2. Eight-Layer Defense-in-Depth

- **Layers 0-2 (Hard Intercept)**: `settings.json` deny rules (24 rules including sudo, eval, force push, curl|bash) + `safety-guard.sh` (five-layer detection: meta-commands → Base64/heredoc/xargs bypass → L4 absolute block → L3 high risk → credential leak; rules externalized to rules/dangerous-commands.txt) + `sensitive-filter.sh` (24 sensitive patterns: API Key/Token/password/private key/JWT/cloud credentials/DB connections; rules externalized to rules/sensitive-patterns.txt). These use `exit 2` — **AI cannot bypass**.
- **Layers 3-6 (Auxiliary)**: State preservation, context recovery, edit auditing with circuit breaker + flock concurrent protection (5x warning / 8x hard block), completion verification (4 checks).
- **Layer 7 (Soft Constraints)**: CLAUDE.md behavioral instructions with L1-L4 security classification.

### 3. Three Departments Governance (三省六部)

Inspired by ancient Chinese governance:
- **Zhongshu Province (Decision)**: planner, architect, analyst, explore — drafts proposals only
- **Menxia Province (Review)**: critic, verifier, reviewers, hooks — has **veto power**
- **Shangshu Province (Execution)**: executor, deep-executor — executes approved plans only
- **Censorate (Independent Audit)**: safety-guard + sensitive-filter + post-edit-audit + verify-before-stop

### 4. Four-Layer Self-Learning Model

| Layer | Trigger | Action |
|-------|---------|--------|
| Fix & Audit | Every bug fix | Search same file/module for similar issues |
| Global Audit | Same pattern ≥2x | Grep entire project + create defense rules |
| Deep Reflection | Same pattern ≥3x | Root cause chain analysis + rule hardening + propose automation |
| Extrapolation | Pattern matured | Analogical reasoning + cross-project migration |

---

## Real-World Scenarios: Before vs After

### Scenario 1: Fixing an API Bug

**Vanilla Claude Code:**
```
User: "Fix the 500 error on /api/users"
Claude: Opens file → sees error → changes one line → "Done, should be fine"
Result: No tests run, new bug introduced; same issue exists in /api/orders but nobody noticed
```

**With this configuration:**
```
User: "Fix the 500 error on /api/users"
Claude:
  [Perceive] Read recurring-patterns.md → found pattern P003 in API layer
  [Think] Invoke explore agent to locate all related files + debugger for root cause
  [Plan] "3 files involved, medium path" → present plan to user
  [Execute] executor fixes code + tests run after each change → quality-reviewer audits
  [Verify] ✅ npm test passed ✅ tsc clean ✅ reviewer approved
  [Reflect] Grep entire project → found same issue in /api/orders → fixed both
  [Evolve] Written to recurring-patterns.md + knowledge graph; auto-warns next time
```

### Scenario 2: Refactoring the Auth Module

**Vanilla Claude Code:**
```
User: "Refactor the auth module"
Claude: Starts massive changes → 15 files modified → build fails → fix loops → worse
     → User discovers SSH key accidentally exposed in logs → security incident
```

**With this configuration:**
```
User: "Refactor the auth module"
Claude:
  [Plan] >10 files → complex path → ralplan consensus planning
         → planner + architect + critic three-way review
         → dry-run validation: executor simulates + debugger predicts risks
  [Execute] Parallel dispatch: executor(core) ∥ test-engineer(tests) ∥ security-reviewer
         → progress report every 3 steps → step 5: potential key leak detected
         → sensitive-filter.sh hard block (exit 2) → write prevented
         → security-reviewer recommends key sanitization layer
  [Verify] Full test suite + build + ReACT deep review (5 rounds of reason-act)
  [Reflect] Agent interviews → executor/debugger/test-engineer each provide feedback
         → test coverage gap discovered → boundary tests added
```

### Scenario 3: Context Window Compression

**Vanilla Claude Code:**
```
[Compression happens] → all prior work forgotten
User: "Continue the previous task"
Claude: "Sorry, I don't remember what we were doing. Please explain again."
```

**With this configuration:**
```
[Before compression] pre-compact-save.sh auto-saves Git state + task progress
[After compression] post-compact-restore.sh injects recovery context
Claude: "Compression recovery detected. Running 7-step recovery checklist..."
  → Read notepad → Read project_memory → Read MEMORY.md
  → Restore Git branch state → Confirm task progress
  → "Context restored. Last completed step 3 of 5. Continuing with step 4..."
```

---

## Quick Start

### Prerequisites

- macOS or Linux
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed
- `jq` (`brew install jq`)
- [oh-my-claudecode (OMC)](https://github.com/anthropics/claude-code) plugin (optional, for multi-agent orchestration)

### One-Line Install

```bash
git clone https://github.com/tangdan2204/ironcensor.git
cd ironcensor
chmod +x install.sh && ./install.sh
```

### Manual Install

```bash
# 1. Create directories
mkdir -p ~/.claude/hooks ~/.claude/logs ~/.claude/rules

# 2. Deploy configs
cp configs/settings.json ~/.claude/settings.json
cp configs/hooks.json ~/.claude/hooks/hooks.json
cp configs/CLAUDE.md ~/.claude/CLAUDE.md
cp configs/env.sh ~/.claude/hooks/env.sh

# 3. Deploy rules
cp rules/dangerous-commands.txt ~/.claude/rules/
cp rules/sensitive-patterns.txt ~/.claude/rules/

# 4. Deploy hook scripts
cp hooks/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh

# 5. Deploy memory files
mkdir -p ~/.claude/projects/-Users-$(whoami)/memory
cp memory/*.md ~/.claude/projects/-Users-$(whoami)/memory/

# 6. Verify
claude  # Start Claude Code and test
```

---

## File Structure

```
IronCensor/
├── configs/
│   ├── settings.json         # Permission config + 24 deny rules
│   ├── hooks.json            # Hook routing table (7 lifecycle events)
│   ├── env.sh                # Unified path/threshold config (shared by all hooks)
│   └── CLAUDE.md             # Core behavioral instructions
├── hooks/
│   ├── safety-guard.sh       # Bash command security (exit 2 block)
│   ├── sensitive-filter.sh   # Sensitive info filter (exit 2 block)
│   ├── pre-compact-save.sh   # Pre-compression state save
│   ├── post-compact-restore.sh # Post-compression context recovery
│   ├── post-edit-audit.sh    # Edit audit + circuit breaker + flock concurrent protection
│   ├── verify-before-stop.sh # Pre-completion 4-point check
│   └── macos-notify.sh       # macOS desktop notifications
├── rules/
│   ├── dangerous-commands.txt # Dangerous command rules (26 rules, dynamically loaded)
│   └── sensitive-patterns.txt # Sensitive info patterns (24 patterns, dynamically loaded)
├── memory/
│   ├── MEMORY.md             # Core memory index template
│   └── recurring-patterns.md # Pattern tracking table template
├── install.sh                # Auto-install script
├── PRD.md                    # Product Requirements Document
├── RESEARCH-REPORT.md        # 6-Dimension Scientific Research Report
├── AUDIT-REPORT.md           # Security Audit Report
├── QUICK-START.md            # Quick Start Guide
└── ONE-LINER.md              # One-liner setup prompt
```

---

## Design Philosophy

- **Pure Configuration**: No Claude Code source code modifications. Uses only official config mechanisms (`settings.json`, `hooks/`, `CLAUDE.md`, `memory/`).
- **Defense in Depth**: Intentional redundancy between layers. Even if prompts are bypassed, hard hooks (exit 2) still block dangerous operations.
- **SSOT Principle**: Every rule defined once. Detection rules externalized to `rules/` directory (dynamically loaded by hooks). Unified configuration in `configs/env.sh` (single point of change for all paths and thresholds). Memory files use pointer references, not copies.
- **Zero Invasion**: Fully compatible with Claude Code updates. Deploy in 5 minutes. Remove completely at any time.

---

## License

[MIT License](./LICENSE)

---

<div align="center">

**Designed and maintained by [Tangdan / 汤旦](https://github.com/tangdan2204)**

*The Iron Censor that never sleeps.*

</div>
