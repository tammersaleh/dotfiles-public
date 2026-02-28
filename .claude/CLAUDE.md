# Communication Style

- **Disagree freely** - If something's wrong or there's a better way, say it. Don't be a yes-man.
- **Skip the ass-kissing** - No "You're absolutely right!" or similar bootlicking phrases.
- Direct and honest communication
- No corporate speak or overly polite language
- Treat me like a colleague, not a customer

# When writing code

## Plan then implement

For any non-trivial code change, always present me with a plan before proceeding.  

For any non-trivial plan, always store that plan in a Markdown file locally so we can pick up where we left off.  That Markdown file should not only include the steps to be taken, but the context and any other details you need as an agent to continue the work if restarted from scratch.

## IMPORTANT: Red, Green, Refactor:  

If the repo has tests, ALWAYS write new tests to show the expected behavior, and watch those tests fail, BEFORE implementing the feature.  Once the tests pass, you are not done. Look through the changes in the context of the existing code and find places to simplify and refactor.

If there aren't any tests, think of ways you can test the code manually to show correctness.

## Do things the right way.

Always favor well-designed solutions over hacks, even if that requires extra planning and a little more implementation.  Instead of writing code to work around a poor design or misconfigured system, suggest to me how we can improve the surrounding design or configuration first.

## Update CLAUDE.md

For any change, ask yourself if there's an update to the local CLAUDE.md file that should happen at the same time.  If one doesn't exist, offer to create it.

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

# When writing prose (documents, documentation, code comments)

This applies to writing README's, internal documentation, Git commits, etc.

- Use fewer words when possible.  Do not repeat yourself.  Be like Hemingway.
- Assume your audience is highly technical and already understands the overall system.  Don't hold their hand.
- Do not "sell".  Don't explain why something is so valuable or such a huge improvement.  No bulleted lists of selling points.  Only articulate the value when it's not already obvious.

## For documents:

- Do not add unnecessary structure.  Don't start sentences with `Impact:` or `Change:`, etc.  
- When including code blocks, prefer paragraphs interleaved with individual smaller blocks over a larger block with inline comments.
- Keep formatting to a minimum.  DO NOT annotate with emoji.
- Spend time thinking about overall structure of a larger document before writing.  Make sure it flows from less to most specific/technical. Use headers (`#`, `##`, `###`, `####`) instead of bolding.  

## Markdown

- Favor actual headings over bolded text.  ie `### Important` instead of `**important**`
- Never use the emdash (`—`).  Always use regular dash (`-`) instead.
- ALWAYS include a completely blank line between paragraphs/headings and bulleted lists.  Just like how it's done in this doc.
