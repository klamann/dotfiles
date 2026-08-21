# klamann's dotfiles

managed with [chezmoi](https://www.chezmoi.io/).

Install dotfiles on a new machine with

    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply klamann

## goals

* one-liner for any linux terminal
* includes oh my zsh & powerlevel10k
* setup script is compatible with all major linux distributions
* tested via Docker on GitHub Actions
* retrieval of personal data is optional & all personal data is encrypted

## windows

Windows applies only the Claude Code config under `~/.claude` (user CLAUDE.md, rules, agents, and the orchestrate skill); the zsh stack and the setup scripts are Linux-only.

    scoop install chezmoi
    chezmoi init git@github.com:klamann/dotfiles.git --apply

## random notes

* [Chezmoi Docs](https://www.chezmoi.io/quick-start/)
* [Template Variables](https://www.chezmoi.io/reference/templates/variables/)
* [Awesome dotfiles](https://github.com/webpro/awesome-dotfiles)
* [dotfiles.github.io](https://dotfiles.github.io/)
