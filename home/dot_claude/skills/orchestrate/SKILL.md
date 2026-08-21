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
4. Commit policy: the implementer commits progress on the run's branch in reasonable chunks as standing policy of this workflow, and pushes only where the plan calls for it (for example so CI can verify a gate). The orchestrator creates the run branch and, when desired, the draft PR. Never push anywhere else or mark the PR ready for review without explicit user approval.
5. Models: implementer and validator run on the latest Opus model (their definitions set `model: opus`) unless the user specifies otherwise at kickoff. Never pick a model more capable than your own.
6. Isolation: worktree or in place, following the project's convention.
7. Create a run directory in your scratchpad holding `status.md` (the status log) and any handover files. Pass absolute paths to every agent; agents may have different scratchpads than you.
8. Budget control: read `~/.claude/rate-limits.json` (written by the statusline script on every render). If it is missing, stale, or carries a percentage outside 0 to 100 (a known quirk when the window has no data yet), tell the user that budget pausing is unavailable right now and continue without it.

## Standing rules for all agents

- The implementer commits progress on the run's branch in reasonable chunks with honest messages, and pushes only where the plan calls for it (for example to let CI verify a gate). Everything else in git belongs to the orchestrator: branches, the draft PR, anything beyond the run branch. Agents never rewrite history, never force-push, and never create or modify PRs.
- Agents write all artifacts inside the workspace they were given, never into unrelated directories.
- When reality disagrees with the plan, agents do the right thing and record a numbered departure in the plan document rather than silently diverging or blindly complying.

## Status log protocol

One `status.md` per run. Agents append entries and never rewrite history, one line per entry:

    [HH:MM] <step> | done|in-progress|blocked | ctx <NN>% | <one line of substance>

Agents append at every milestone, blocker, and surprising discovery. The orchestrator reads the log at check-ins instead of interrupting the agent. The ctx field is the agent's own context window usage; the orchestrator has no other live view of it, so it must be present in every entry.

## Supervision loop

Schedule a check-in every 20 minutes (ScheduleWakeup). At each check-in: read the status log, judge whether the agent is on plan, post a brief progress update to the user, and course-correct via SendMessage if needed. Never fabricate agent results; if nothing has arrived, say the agent is still running.

When the status log shows context usage above 60 percent, or the agent reports that its handover rule triggered, let it finish the current step and write a handover file, then boot a successor with three paths: the plan, the handover, and the status log.

At every check-in, also read `~/.claude/rate-limits.json`. Above 75 percent of the five hour window, halve the check-in interval; the pause threshold is only safe if you look often enough. Above 90 percent, run the budget pause below.

## Budget pause and resume

Running out of the five hour usage window force-stops agents wherever they are; the controlled pause prevents that.

1. Tell every running agent (SendMessage) to pause: finish the current step, write the handover (implementer) or report findings so far with an explicit unreviewed list (validator), append a final status entry, and stop.
2. When they have stopped, or after a reasonable wait if one does not answer, write the session handover to the run directory, including what was running, where it stopped, and the planned resume time.
3. Schedule a one-shot resumption (CronCreate with recurring false) a few minutes after `five_hour.resets_at`, converted to local time and off the full minute. The prompt must be self-contained: run name, run directory, the instruction to confirm from the rate limits file that the window has reset, respawn agents from their handovers, and restart the check-in loop.
4. Tell the user: paused at what percentage, resuming at what local time.

On resumption, confirm the window has actually reset; if it has not, schedule another one-shot 30 minutes out and stop again. Then respawn agents from their handovers and resume check-ins. If the session was closed in the meantime the cron died with it; the session handover in the run directory is the recovery path after a resume.

## Handover file

Written by the outgoing agent, read by its successor. Sections: Done (with evidence), In flight (exact current state), Departures so far, Next steps in order, Traps (things that look wrong but are right, and the reverse).

## Validation loop

When the implementer declares done with green gates, start a fresh `validator` with no shared context. Give it the plan path, the diff scope (branch or commit range), the gates, and the previous round's findings if this is not round one.

Finding taxonomy: MAJOR means wrong behavior, a broken contract, or an unmet plan requirement, and blocks completion. MINOR means style, documentation, or a small hazard, and is either fixed or recorded as a decline with reasoning in the plan document. Every round after the first starts by verifying the previous round's fixes.

Iterate implementer (or a dedicated fixer agent) and validator until a round reports zero majors. Record each round's outcome in the plan document. Give the validator a fixed commit range, so commits made after its round started do not shift the diff under review.

## Wrap-up

Stop the wakeup loop. Run the gates one final time yourself and spot-check the diff; do not take the last agent's word for it. Commit per the kickoff policy. Confirm nothing is left running. Then report to the user: what shipped, measured results, validation history (rounds, majors and minors, recorded declines), the commits made, and open items.

Finally, write a session handover to the run directory: everything a successor conversation needs to continue where this one ends (state of the work, decisions and their reasons, results, commits, open items, and the paths that matter), written now while the context is fresh and cached. You cannot trigger /compact yourself, and by the time the user returns the prompt cache may be cold, so this file is the cheap substitute: the user can start a fresh session from it instead of paying a full re-read of this one. Name the file's path in the final report.
