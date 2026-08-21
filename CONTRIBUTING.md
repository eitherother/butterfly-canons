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

Optional: install the pre-commit hooks so lint/format run automatically on
`git commit`:

```
uv run pre-commit install
```

## SuperCollider

There's no formal linter for `.scd`/`.sc` files. CI does a best-effort
compile-only syntax check (`tools/check_scd_syntax.scd`) that catches parse
errors without needing a booted server, MIDI hardware, or sample files. It
won't catch logic errors — SuperCollider has no real test framework, so
manual testing in the IDE before opening a PR is expected.

## Project structure

Each piece (`piffaro03/`, and future pieces) is self-contained: its own
`conductor.scd`, `synths.scd`, `score.scd`, etc. This is deliberate — pieces
don't share a common engine, so a change to one piece can't silently break
another. Some duplication across pieces is the accepted tradeoff.

If a piece depends on external audio (samples, recordings) that aren't
included in the repo, note that in the piece's own README rather than
committing the audio.
