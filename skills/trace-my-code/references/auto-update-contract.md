# Auto-update contract (Mode B)

The hook rewrites docs **without a human edit gate**, so correctness depends entirely
on these rules. Auto-docs fail one way: asserting without verifying. Don't.

## Hard rules

1. **Read before you write.** Read the actual diff (`<base>..HEAD`) for every changed
   file the hook listed, plus the current text of each governing doc. No diff read → no edit.
2. **Surgical, not regenerative.** Edit only the sentences/sections the diff made stale.
   Everything still accurate stays **verbatim**. Never rewrite a whole file.
3. **Ground every change in code.** Each edited claim must correspond to a line in the
   diff. Prefer citing `path/to/file.ts:NN`.
4. **Flag, don't fabricate.** If a section _looks_ affected but you can't confirm the new
   behavior from the diff, leave it and insert
   `<!-- trace-my-code: review — could not verify from diff -->`. Never guess.
5. **Preserve doc shape.** Keep frontmatter, headings, `[[wikilinks]]`, and tone. Update
   `updated:`/`date:` frontmatter when you change a file.
6. **No-op cleanly.** Formatting-only, comment-only, or internal-refactor changes that
   don't alter documented behavior → make NO edit.
7. **One visible commit.** The hook commits your edits as `docs: auto-refresh ...`. Never
   `git commit --amend`, never force, never touch non-doc files.

## What counts as "stale"

A documented **claim** no longer matches code: a renamed/removed function the doc names,
a changed control-flow (the `batch.triggerByTaskAndWait` → `pLimit` class of drift), a
new/removed branch, a moved file path, a changed invariant. NOT: cosmetic code edits,
new tests, comment changes.

## Self-check before committing

- Every edit traces to a diff line? If not, revert that edit or convert it to a review flag.
- Did you delete any still-true content? Restore it.
- Is the change the _minimum_ that makes the doc accurate again? If it grew, trim.
