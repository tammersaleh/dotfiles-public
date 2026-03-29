This is where I checkout and write source code.  

The directory structure mirrors the Git repository URL. The Terraform project, for example, would be found under ~/src/github.com/hashicorp/terraform.  This structure is made easy through [my `git grab` command](https://github.com/tammersaleh/dotfiles-public/tree/master/bin/git-grab).

# When writing code

## Plan then implement

For any non-trivial code change, always present me with a plan before proceeding.  

For any non-trivial plan, always store that plan in a Markdown file locally so we can pick up where we left off.  That Markdown file should not only include the steps to be taken, but the context and any other details you need as an agent to continue the work if restarted from scratch.

## IMPORTANT: Red, Green, Refactor:

If the repo has tests, ALWAYS write new tests to show the expected behavior, and watch those tests fail, BEFORE implementing the feature.  

Once the tests pass, YOU ARE NOT DONE. Look through the changes in the context of the existing code and find places to simplify and refactor.

If there aren't any tests, think of ways you can test the code manually to show correctness.

## Do things the right way.

Always favor well-designed solutions over hacks, even if that requires extra planning and a little more implementation.  Instead of writing code to work around a poor design or misconfigured system, suggest to me how we can improve the surrounding design or configuration first.

## Update CLAUDE.md

For any change, ask yourself if there's an update to the local CLAUDE.md file that should happen at the same time.  If one doesn't exist, offer to create it.

## Shell scripts

Follow the template in `~/dotfiles/public/.config/nvim/templates/sh` for all new bash scripts. It includes strict mode, error trapping, debug support, and `cd "$(dirname "$0")"` so scripts work from any directory.

## Preferred tooling

- Prefer Mise over Makefiles, but always default to whatever is already in place.
- If there's a locally configured tool runner, use that instead of running the underlying commands. For example `mise tests` instead of `go test ./...`
- When writing greenfield CLIs, prefer Golang, and prefer Kong over Cobra.
- Prefer `uv` for Python.
- If writing a Python script makes use of the `uv` [shebang-with-dependencies pattern](https://docs.astral.sh/uv/guides/scripts/#declaring-script-dependencies)

## Searching codebases

Prefer LSP over Grep/Read for code navigation — it's faster, precise, and avoids reading entire files:

- `workspaceSymbol` to find where something is defined
- `findReferences` to see all usages across the codebase
- `goToDefinition` / `goToImplementation` to jump to source
- `hover` for type info without reading the file

Use Grep only when LSP isn't available or for text/pattern searches (comments, strings, config). Even then, suggest I install the missing LSP for you.

After writing or editing code, check LSP diagnostics and fix errors before proceeding.

# Git

## Github

If this is a shared project, I will want to do all pushes and remote actions myself.  You will not be allowed.

If this is a personal or green-field project, then you'll be allowed to push changes make remote changes.

Feel free to ask which situation this is.

## Commits

- ALWAYS ALWAYS check the files that have been added (`git status`) before committing.  Un-add any files that should not be pushed.
- Keep commits small.  Each small batch of useful functionality should be a separate commit, even if it's just a single character change.
- Use a light [conventional commit](http://conventionalcommits.org/en/v1.0.0/) format:
    
    ```
    feat: allow provided config object to extend other configs
    chore!: drop support for Node 6
    fix: fix broken timeout parser
    docs: update url for latest version
    ```

    (`!` means a breaking change)

- Keep the commit description (body) short and to the point.
    - Start with "what", then briefly explain "why"
    - Use bullets to explain any unrelated changes that are in the same commit. (even better, break those into separate commits)

