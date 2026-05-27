@~/Work/basecamp/shipyard/share/AGENTS.md

## In general

Follow instructions carefully. Don't be stupid.

## Programming guidelines

Do the simplest thing that could work:
- Don't do additional work you weren't asked to do.
- If you think something should be added, then let's write a failing test describing that behavior.

Make it green, then make it clean:
- Write code to make the tests pass.
- Once the test goes green, then simplify the code as much as possible.

When fixing a bug or adding a feature, always start with a test.
- Feature: Demonstrate the behavior we want to implement.
- Bug: Demonstrate the bug with the simplest scenario possible.

## Testing guidelines

Tests are INCREDIBLY IMPORTANT to get right. They reveal the domain language and the API design. Make sure you get the tests simple, right, and high quality before continuing on to the implementation phase.

When writing tests, first check existing test files for patterns, naming conventions, and helper methods before writing new tests.

Important: do not write comments in tests unless it is to reveal a non-obvious fact. Try to write tests that clearly express the intent of the test and thus do not need many comments.

## Git

### Creating a worktree

When creating git worktrees:

- Branch name: meaningful and likely unique. Do not use a "/" in the branch name.
- Directory: `<reponame>--<branchname>` in the same parent directory as the repo.

**Never** create a worktree that tracks a remote branch. Always use this syntax:

    git worktree add $path $branch

or

    git worktree add -b $branch $path

where $branch **MUST** be a local branch (and not an origin branch).

### Pushing a worktree

If the remote tracking branch is `origin/main` or `origin/master` DO NOT PUSH. STOP. Unset tracking first.

If there is no remote tracking branch, push with the `--set-upstream` option to create one.

## Temporary files

When creating temporary files and directories always use `./tmp/`
