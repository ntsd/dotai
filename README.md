# DotAI

My DotAI files (like dotfiles) provide a preconfigured AI workflow and agent setup for a new machine.
Works on Unix-based systems: macOS, Ubuntu, and WSL.

## Focus on

This AI setup focuses on these pillars:

- Productivity & automation: Build efficient multi-agent workflows and automate routine, low-priority tasks.
- Quality & performance: Deliver high-quality, maintainable code with fast, high-throughput performance.
- Reliability & security: Prioritize stable, dependable, and secure software outcomes.
- Cost efficiency: Reduce cost by optimizing token usage and keeping workflows to as few steps as possible.

## Installation

On fresh macOS, install Xcode Command Line Tools (`git` and `make`).

```sh
sudo softwareupdate -i -a
xcode-select --install
```

Option 1: Install with `curl`:

```sh
bash -c "`curl -fsSL https://raw.githubusercontent.com/ntsd/dotai/master/remote-install.sh`"
```

This clones or downloads the repo to `~/dotai`.

Option 2: Clone manually:

```sh
git clone https://github.com/ntsd/dotai.git ~/dotai
```

Then install everything:

```sh
cd ~/dotai && make
```

## Tools

I use multiple tools for different purposes, and I like to try something new for more experience.

- opencode: The main AI agent for background tasks and multi-agent workflows.
- GitHub Copilot in VS Code (extension): For hands-on coding, autocompletion, unit test generation, and code reviews.
- Antigravity: For frontend development, with integrated browser testing.

## Large language models

I only use monthly subscription models to avoid high costs from pay-per-use pricing.

- Gemini (Google One)
- Github Copilot

## Programming Languages

I prefer the AI to generate code in these languages because I am most familiar with them, which helps me review the code more effectively.

- TypeScript: For frontend development (web, mobile, desktop), CLI tools, and Bun backend servers.
- Go: For high-performance, concurrent backend servers and CLI tools.

## Conventions

### Git Commits

Git commit messages should follow the Conventional Commits format and include issue tracking IDs when applicable.

Examples:
- Jira issue: `feat(scope): [IN-999] change something` (where `IN-999` is a Jira ID)
- GitHub issue: `feat(scope): [#999] change something` (where `#999` is a GitHub issue ID)
