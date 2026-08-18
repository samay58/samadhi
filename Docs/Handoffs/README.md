# Handoff intake

Use this directory for large project handoffs that must remain traceable from source through execution.

Each handoff gets one dated directory:

~~~text
Docs/Handoffs/YYYY-MM-DD-short-name/
    original/
    MANIFEST.md
    MAP.md
    WORKPLAN.md
    VERIFICATION.md
~~~

## Original

Save the received material under `original/` before analysis or editing.

- Preserve attachment bytes and filenames.
- Preserve pasted text verbatim as UTF-8 Markdown.
- Split multi-message text only at message boundaries.
- Never edit, reformat, annotate, or replace an original file.
- Put corrections or later additions in new source files.

`MANIFEST.md` records receipt time, source filenames, byte counts, and SHA-256 checksums. It also records whether the handoff arrived as one artifact or several ordered parts.

## Map

`MAP.md` turns the handoff into a usable model without flattening its meaning. Every important derived item points back to its source file and section.

Required sections:

- Intended outcome and completion test
- Product promise and non-negotiables
- Current state, with verified facts separated from claims
- System boundaries and affected code or documentation
- Decisions already made
- Constraints and explicit exclusions
- Dependencies and ordering
- Risks and assumptions
- Contradictions with live repository truth
- Open questions, limited to answers that change execution

Do not force the source into preset categories when its natural structure differs. Build the map around the handoff's actual argument.

## Workplan

`WORKPLAN.md` converts the map into bounded work packets. A packet exists only when it has a distinct result, meaningful context cost, and a concrete stop condition.

Each packet contains:

- Result
- Why it belongs in this order
- Source pointer
- Files or systems in scope
- Dependencies
- Implementation notes
- Done check
- Verification method
- Status

Order work by dependency and product risk. Prove uncertain load-bearing assumptions before polishing dependent work. Keep unrelated cleanup outside the packet.

## Verification

`VERIFICATION.md` is the proof ledger.

For each completed packet, record:

- What changed
- Exact checks run
- Result
- Physical or human judgment still required
- Evidence path
- Remaining limits

Simulator, automated tests, physical-device evidence, listening judgment, and inference stay separate. Never promote one into another.

## Operating loop

1. Save and checksum the complete original.
2. Read the full handoff before implementation.
3. Compare it with live code, canonical docs, tests, evidence, and Git state.
4. Build `MAP.md` around intent, system shape, dependencies, and contradictions.
5. Build `WORKPLAN.md` from the map. Give every packet a done check.
6. Execute one packet at a time. Build or test after each coherent change.
7. Update `VERIFICATION.md` with observed proof.
8. Update canonical project docs only at real milestone boundaries.
9. Stop when the handoff's completion test passes. New ideas become explicit new scope.

## Continuity

`MAP.md`, `WORKPLAN.md`, and `VERIFICATION.md` are living files. Original source is not. Another session should be able to recover current truth from those three files without rereading the full source, while still having the untouched source available when nuance matters.
