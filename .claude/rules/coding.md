# Coding

## Plan then implement

For any non-trivial code change, always present me with a plan before proceeding.

For any non-trivial plan, always store that plan in a Markdown file locally so we can pick up where we left off. That Markdown file should not only include the steps to be taken, but the context and any other details you need as an agent to continue the work if restarted from scratch.

Always keep the plan up to date. Record decisions as they're made, mark steps complete as they finish, append discoveries that change the plan. A plan that drifts from reality is worse than no plan - the next session trusts what's written. Update inline as you work, not at the end.

## Use Codex for planning and reviews

For any significant planning AND for code reviews, engage Codex via the `codex-planning` skill (`mcp__codex__codex`). This is mandatory, not optional - load the skill and start a thread before committing to an approach or delivering a review.

## IMPORTANT: verify all bugs before fixing

Don't just trust the output I give you from a bug report. Whenever possible, run the command yourself to observe the failure. If what you ran succeeded or if the failure doesn't match the failure I showed you, then investigate that before proceeding to a fix.

## Do things the right way

Always favor well-designed solutions over hacks, even if that requires extra planning and a little more implementation. Instead of writing code to work around a poor design or misconfigured system, suggest to me how we can improve the surrounding design or configuration first.

## Update CLAUDE.md

For any change, ask yourself if there's an update to the local CLAUDE.md file that should happen at the same time. If one doesn't exist, offer to create it.

## Pushing to remotes

If this is a shared project, I will want to do all pushes and remote actions myself. You will not be allowed.

If this is a personal or green-field project, then you'll be allowed to push changes make remote changes.

Feel free to ask which situation this is.

## Commits

- ALWAYS ALWAYS check the files that have been added (`git status`) before committing. Un-add any files that should not be pushed.
- Keep commits small. Each small batch of useful functionality should be a separate commit, even if it's just a single character change.
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
