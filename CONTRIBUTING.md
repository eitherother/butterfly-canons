# Contributing

## Branch workflow

`main` is protected: no direct pushes, no force-pushes, no deletions. All
changes go through a pull request.

```
git checkout -b your-branch-name
# make changes
git push -u origin your-branch-name
gh pr create
```

## Python

Dependencies and the dev environment are managed with [uv](https://docs.astral.sh/uv/).

```
uv sync                  # install/update the environment
uv run ruff check .      # lint
uv run ruff format .     # format
```

CI runs `ruff check` and `ruff format --check` on every PR, so run these
locally before pushing.

## SuperCollider

There's no formal linter for `.scd`/`.sc` files, and no CI check for them
yet — SuperCollider has no real test framework, and files here rely on the
convention of multiple independently-evaluated top-level `(...)` blocks,
which rules out a naive whole-file compile check. Manual testing in the IDE
before opening a PR is expected. A real automated check may be added later.

## Project structure

Each piece (`chrysalis-canons/`, and future pieces) is self-contained: its own
`conductor.scd`, `synths.scd`, `score.scd`, etc. This is deliberate — pieces
don't share a common engine, so a change to one piece can't silently break
another. Some duplication across pieces is the accepted tradeoff.

The one exception is `supercollider-utilities/` (and `python-utilities/`):
small, generic helpers with no piece-specific logic — e.g. a recording
start/stop wrapper. Before adding something there, make sure it's genuinely
generic; anything that touches a piece's synths, conductor, or score belongs
in that piece, not shared.

If a piece depends on external audio (samples, recordings) that aren't
included in the repo, note that in the piece's own README rather than
committing the audio.
