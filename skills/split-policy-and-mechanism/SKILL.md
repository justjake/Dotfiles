---
name: split-policy-and-mechanism
description: "Use when designing, refactoring, or reviewing code where business/product rules, permissions, defaults, feature gates, configuration, orchestration, or user-facing choices may be mixed with reusable execution mechanisms, algorithms, adapters, data access, parsers, or other low-level primitives. Apply the Unix-inspired policy/mechanism separation: isolate what should happen from how it is carried out."
---

# Split Policy and Mechanism

Use this skill to separate policy concerns from mechanism concerns, inspired by the Unix tradition of building small reusable mechanisms and keeping policy decisions at the edges.

## Core Distinction

**Policy** decides what should happen.

- Product, business, security, permission, rollout, and UX rules
- Defaults, thresholds, prioritization, ordering, and strategy selection
- Feature gates, experiment choices, environment-specific behavior, and configuration interpretation
- User-facing error interpretation, fallback decisions, and orchestration across steps

**Mechanism** provides a way to make something happen.

- Parsers, formatters, serializers, validators, adapters, clients, storage access, and algorithms
- Deterministic transformations and reusable primitives
- Interfaces for I/O, retries, scheduling, transactions, caching, or network calls
- Factual results and factual errors that callers can interpret

## Workflow

1. Identify decisions in the code path.
   Ask "who chooses?" for every branch, default, fallback, threshold, retry, permission check, and output format.

2. Classify each decision.
   If the decision depends on product intent, user context, business rules, permissions, rollout state, or presentation, treat it as policy. If it describes a general capability or invariant of the underlying operation, treat it as mechanism.

3. Move policy upward or outward.
   Keep policy near the feature, command, endpoint, UI flow, or orchestration layer that owns the user/business intent.

4. Keep mechanism narrow and honest.
   Mechanisms should accept explicit inputs, expose typed results, and avoid importing feature-specific modules, reading hidden global state, or knowing why a caller wants the operation.

5. Name the boundary.
   Use names that reveal intent: `chooseExportFormat` is policy; `serializePageToMarkdown` is mechanism. Avoid generic helper names for code that embeds product decisions.

6. Test each side differently.
   Test mechanisms with direct input/output cases and edge cases. Test policy with scenarios that prove the right mechanism is selected, sequenced, or configured.

## Design Guidance

- Prefer explicit parameters over mechanisms that read global config, current user, experiments, route state, or product mode internally.
- Let mechanisms report facts; let policy decide meaning. For example, a mechanism can return `rateLimited` or `permissionDenied`; policy decides whether to retry, show UI, fall back, or fail.
- Put defaults where ownership is clearest. Reusable libraries can have technical defaults; product defaults belong in policy layers.
- Keep policy thin but visible. A policy layer can be mostly orchestration, but it should be the place a reader goes to understand product behavior.
- Avoid pushing policy into flags on low-level helpers. If options start to encode business modes, introduce a policy wrapper or strategy object at the owning layer.
- Avoid duplicating mechanism in each policy path. Extract shared execution once the repeated code is truly the same operation.
- Do not over-separate trivial code. A boundary is useful when it reduces coupling, improves reuse, clarifies ownership, or makes tests more meaningful.

## Review Smells

- A generic utility imports feature modules, experiment gates, permission helpers, UI copy, route state, or product-specific constants.
- A reusable adapter has branches named after product plans, surfaces, teams, or workflows.
- Tests for a low-level primitive need extensive user/workspace/product setup.
- A feature policy duplicates parsing, transaction, network, or serialization details.
- A caller passes booleans whose names only make sense in one product flow.
- Error handling is hidden inside a mechanism even though different callers need different fallback behavior.

## Useful Questions

- What part of this code would still be useful if the product decision changed?
- What part should change when business rules, UX, permissions, or rollout strategy changes?
- Can the mechanism be described without mentioning a product surface or user story?
- Can the policy be read without understanding low-level operational details?
- Are tests failing because behavior changed, or because policy and mechanism are coupled too tightly?
