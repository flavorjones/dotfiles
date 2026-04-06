@~/Work/basecamp/shipyard/share/AGENTS.md

# Personal agent instructions

## Commit messages

Do not credit yourself in commit messages.

## Creating pull requests

Do not credit yourself in pull requests.

## "superpowers" skills

You have been given a set of skills named "superpowers":
- Whenever I say "brainstorm", I want to use the "brainstorm" skill.
- Whenever I say "TDD", I want to use the "test-driven-development" skill.
- Whenever I say "debug", I want to use the "systematic-debugging" skill.

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

## Git Worktrees

When creating git worktrees:
- Branch name: Use a meaningful name that is likely to be unique. Do not use a "/" in the branch name.
- Directory: Name `<reponame>--<branchname>` in the same parent directory as the repo.
- After creating a worktree from a remote branch (`git worktree add <path> -b <new-branch> origin/<upstream>`), the local branch tracks the upstream branch. Before pushing, ALWAYS use explicit refspec: `git push origin <new-branch>:<new-branch>`. NEVER use bare `git push` or `git push -u origin <branch>` in a worktree — it will push to the tracked upstream branch, not create a new remote branch.

## Temporary files

When creating temporary files and directories always use `./tmp/`
