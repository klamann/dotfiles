---
name: orchestrate
description: Supervise a multi-agent implement-and-validate loop for a planned feature. Use when the user asks to orchestrate implementation with subagents, hand a plan to an implementer agent, or run an implementer and validator loop until review passes.
argument-hint: [path to plan document]
---

# Orchestrate: a supervised implementer and validator loop

You are the orchestrator: the main session that plans, spawns background agents, supervises them, relays progress to the user, and owns all git operations. The worker roles are the `implementer` and `validator` agent definitions in `~/.claude/agents/`; this skill is the playbook that wires them together.

## When to use this, and when not

Use it for feature-sized work with a written plan, where implementation should run in background agents and the result gets adversarial review before it counts as done. Do not use it for small tasks (do those inline) or for deterministic fan-out over many similar items (that is what the Workflow tool is for).

## Kickoff checklist

Work through this before spawning anything, and echo the outcome to the user as the kickoff summary.

1. The contract is a plan document, committed to the repository. If none exists, write one and get it committed first, with the user's approval. Agents receive its path and cite it; every deviation from it gets a sequential number and is recorded in the plan document with reasoning, so the plan stays the single source of truth.
2. Gates: the exact test, lint, and format commands that define done. Take them from the project's CLAUDE.md; ask the user only for what is missing.
3. Safety constraints: what agents must never do in this repository (elevated commands, external services, shared machines or resources, anything destructive). Combine the project's rules with the standing rules below.
4. Commit policy: propose committing each validated milestone during the run and have the user approve that scope once, at kickoff. Never push without explicit approval.
5. Model and effort per role, only if the agent definitions' defaults are wrong for this run.
6. Isolation: worktree or in place, following the project's convention.
7. Create a run directory in your scratchpad holding `status.md` (the status log) and any handover files. Pass absolute paths to every agent; agents may have different scratchpads than you.

## Standing rules for all agents

- Agents never commit, stage, or push, and never rewrite git state. The orchestrator owns git.
- Agents write all artifacts inside the workspace they were given, never into unrelated directories.
- When reality disagrees with the plan, agents do the right thing and record a numbered departure in the plan document rather than silently diverging or blindly complying.

## Status log protocol

One `status.md` per run. Agents append entries and never rewrite history, one line per entry:

    [HH:MM] <step> | done|in-progress|blocked | <one line of substance>

Agents append at every milestone, blocker, and surprising discovery. The orchestrator reads the log at check-ins instead of interrupting the agent.

## Supervision loop

Schedule a check-in every 25 to 30 minutes (ScheduleWakeup). At each check-in: read the status log, judge whether the agent is on plan, post a brief progress update to the user, and course-correct via SendMessage if needed. Never fabricate agent results; if nothing has arrived, say the agent is still running.

When an agent reports its remaining context is low (the handover rule in its definition), let it finish the current step and write a handover file, then boot a successor with three paths: the plan, the handover, and the status log.

## Handover file

Written by the outgoing agent, read by its successor. Sections: Done (with evidence), In flight (exact current state), Departures so far, Next steps in order, Traps (things that look wrong but are right, and the reverse).

## Validation loop

When the implementer declares done with green gates, start a fresh `validator` with no shared context. Give it the plan path, the diff scope (branch or commit range), the gates, and the previous round's findings if this is not round one.

Finding taxonomy: MAJOR means wrong behavior, a broken contract, or an unmet plan requirement, and blocks completion. MINOR means style, documentation, or a small hazard, and is either fixed or recorded as a decline with reasoning in the plan document. Every round after the first starts by verifying the previous round's fixes.

Iterate implementer (or a dedicated fixer agent) and validator until a round reports zero majors. Record each round's outcome in the plan document. Do not commit while a validator is mid-review of the diff it was given; commit between rounds.

## Wrap-up

Stop the wakeup loop. Run the gates one final time yourself and spot-check the diff; do not take the last agent's word for it. Commit per the kickoff policy. Confirm nothing is left running. Then report to the user: what shipped, measured results, validation history (rounds, majors and minors, recorded declines), the commits made, and open items.
