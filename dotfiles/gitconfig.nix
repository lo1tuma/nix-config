{}: ''
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
  [user]
      name = Mathias Schreck
      email = schreck.mathias@googlemail.com
  [filter "lfs"]
      clean = git-lfs clean -- %f
      smudge = git-lfs smudge -- %f
      process = git-lfs filter-process
      required = true
''
