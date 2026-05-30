{ }:
''
  [core]
        editor = vim
        hooksPath = /non-existing-path-to-prevent-hooks
        ignorecase = false
  [push]
      default = nothing
  [pull]
      rebase = true
  [branch]
      autosetuprebase = always
  [alias]
      lg = log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
      clean-local-branches  = "!git branch --merged master | grep -v '^* ' | grep -v ' master$' | xargs git branch -d"
      clean-local-branches-main  = "!git branch --merged main | grep -v '^* ' | grep -v ' main$' | xargs git branch -d"
  [user]
      name = Mathias Schreck
      email = mathias.schreck@misterspex.de
      signingkey = ~/.ssh/id_ed25519.pub
  [gpg]
      format = ssh
  [commit]
      gpgsign = true
  [tag]
      gpgsign = true
  [filter "lfs"]
      clean = git-lfs clean -- %f
      smudge = git-lfs smudge -- %f
      process = git-lfs filter-process
      required = true
''
