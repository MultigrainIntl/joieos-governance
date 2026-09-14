# JoieOS Quality Rules

The compliance gate catches dishonesty — a committed secret, a claim of verification with no
verifier, a missing governance file. It cannot tell whether the result is any good.

These three rules close that gap. They are part of the protocol, not guidance.

## Q1 — Every project has a written quality bar, in GAJ's words

A short statement of what a user must be able to do, what must never happen, and what would
make the result unacceptable. It lives in the project as `QUALITY.md`, or as named
requirements in the project's own control records.

Before building, read it. Judge the work against it, not against a file list.
If a project has none, draft one from GAJ's past complaints and confirm it with him first.

NebraskaBeans already has one. UX-001, MAP-001, YIELD-001 and MAP-002 state exactly what good
looks like there, and all four are FAILED. That is a quality bar doing its job.

## Q2 — Independent review is routine, not a rescue

Anything substantive is reviewed by a different actor before it is called done.

The evidence is one-sided. On 2026-09-14 self-review caught nothing across a full day of work.
Independent review caught a false claim about how a script behaved, a file count stated wrongly
twice, and a check that had been built so it could never pass. Same-actor testing remains
IMPLEMENTATION_TESTED and nothing more.

## Q3 — Looking is a required step, at the sizes people actually use

Desktop, tablet and phone. Generating a screenshot and filing it is not looking. Render it and
inspect it.

This is not ceremony. Rendering a page caught a deliberately withheld figure being put back on
screen, minutes after the change was made and before it reached GAJ.

GAJ's own screenshots outrank every automated check. If he looks at it and says it is wrong,
it is wrong, and no passing test changes that.

## What is machine-checkable, and what is not

Q1 is checked: the compliance gate reports whether a project carries a quality bar. It warns
rather than fails while projects are still being brought in; it is not yet a merge blocker.

Q2 and Q3 cannot be verified by a script. They are enforced by the people and agents doing the
work, and by GAJ refusing results that arrive without them.
