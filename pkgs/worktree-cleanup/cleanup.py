import argparse
import os
from pathlib import Path
import stat
import subprocess
import time


GENERATED_PATHS = {
    "node_modules", "build", "dist", "coverage", "target", ".build",
    ".cache", ".next", ".nuxt", ".output", ".turbo", ".nyc_output", ".DS_Store",
}
GIT_ENV = {**os.environ, "GIT_OPTIONAL_LOCKS": "0", "GIT_TERMINAL_PROMPT": "0"}


def git(path, *arguments):
    return subprocess.run(
        ["git", "-C", str(path), *arguments],
        check=True, capture_output=True, env=GIT_ENV,
    ).stdout


def open_paths():
    result = subprocess.run(
        ["/usr/sbin/lsof", "-nP", "-a", "-u", str(os.getuid()), "-F0n"],
        check=True, capture_output=True,
    )
    return {
        os.fsdecode(field.lstrip(b"\n")[1:])
        for field in result.stdout.split(b"\0")
        if field.lstrip(b"\n").startswith(b"n/")
    }


def worktrees(root):
    for group in sorted(root.iterdir()):
        if not group.is_dir() or group.is_symlink():
            continue
        if (group / ".git").is_file():
            yield group
            continue
        for path in sorted(group.iterdir()):
            if path.is_dir() and not path.is_symlink() and (path / ".git").is_file():
                yield path


def changed_since(path, cutoff):
    metadata = path.lstat()
    if max(metadata.st_mtime, metadata.st_ctime) >= cutoff:
        return True
    pending = [path]
    while pending:
        current = pending.pop()
        with os.scandir(current) as entries:
            for entry in entries:
                metadata = entry.stat(follow_symlinks=False)
                if max(metadata.st_mtime, metadata.st_ctime) >= cutoff:
                    return True
                if stat.S_ISDIR(metadata.st_mode):
                    pending.append(entry.path)
    return False


def unchanged_since_creation(path, admin):
    history = admin / "logs/HEAD"
    if not history.is_file():
        return False
    entries = [line.partition(b"\t") for line in history.read_bytes().splitlines()]
    if len(entries) not in (1, 2):
        return False
    head = git(path, "rev-parse", "HEAD").strip()
    creation, _, action = entries[0]
    if creation.split(b" ", 2)[:2] != [b"0" * len(head), head] or action:
        return False
    if len(entries) == 1:
        return True
    reset, _, action = entries[1]
    return reset.split(b" ", 2)[:2] == [head, head] and action == b"reset: moving to HEAD"


def keep_reason(path, cutoff, opened):
    if any(name == str(path) or name.startswith(str(path) + "/") for name in opened):
        return "open in a process"
    if changed_since(path, cutoff):
        return "recent file changes"
    admin = Path(os.fsdecode(git(path, "rev-parse", "--absolute-git-dir")).strip())
    common = Path(os.fsdecode(git(path, "rev-parse", "--path-format=absolute", "--git-common-dir")).strip())
    if common.is_relative_to(path) or admin == common:
        return "repository history is inside this worktree"
    if (admin / "locked").exists():
        return "locked"
    if changed_since(admin, cutoff):
        return "recent Git activity"
    if git(path, "rev-parse", "--abbrev-ref", "HEAD").strip() == b"HEAD":
        return "detached HEAD"
    if git(path, "status", "--short", "--untracked-files=all"):
        return "uncommitted or untracked files"
    ignored = git(path, "ls-files", "--others", "--ignored", "--directory", "--exclude-standard", "-z")
    if any(os.fsdecode(name).split("/")[0] not in GENERATED_PATHS for name in ignored.split(b"\0") if name):
        return "ignored files outside generated directories"
    if unchanged_since_creation(path, admin):
        return None
    default = git(path, "symbolic-ref", "refs/remotes/origin/HEAD").strip()
    ancestry = subprocess.run(
        ["git", "-C", str(path), "merge-base", "--is-ancestor", "HEAD", os.fsdecode(default)],
        capture_output=True, env=GIT_ENV,
    )
    if ancestry.returncode == 1:
        return "branch is not merged into origin's default branch"
    ancestry.check_returncode()
    return None


def cleanup(root, days, apply):
    cutoff = time.time() - days * 86400
    opened = open_paths()
    removed = 0
    for path in worktrees(root):
        try:
            reason = keep_reason(path, cutoff, opened)
            if reason:
                print(f"Keep {path}: {reason}", flush=True)
                continue
            if not apply:
                print(f"Would remove {path}", flush=True)
                continue
            reason = keep_reason(path, cutoff, open_paths())
            if reason:
                print(f"Keep {path}: {reason}", flush=True)
                continue
            common = os.fsdecode(git(path, "rev-parse", "--path-format=absolute", "--git-common-dir")).strip()
            subprocess.run(
                ["git", "--git-dir", common, "worktree", "remove", str(path)],
                check=True, capture_output=True, env=GIT_ENV,
            )
            removed += 1
            print(f"Removed {path}; branch preserved", flush=True)
        except (OSError, subprocess.CalledProcessError) as error:
            detail = os.fsdecode(error.stderr) if isinstance(error, subprocess.CalledProcessError) else str(error)
            print(f"Keep {path}: {detail.strip()}", flush=True)
    return removed


def main():
    parser = argparse.ArgumentParser(description="Remove inactive, clean worktrees that are merged or unchanged since creation.")
    parser.add_argument("--root", type=Path, default=Path.home() / "projects/.worktrees")
    parser.add_argument("--days", type=int, default=14)
    parser.add_argument("--apply", action="store_true", help="Remove eligible worktrees; otherwise only report.")
    arguments = parser.parse_args()
    if arguments.days < 0:
        parser.error("--days must be nonnegative")
    root = arguments.root.expanduser().resolve()
    if root.exists():
        cleanup(root, arguments.days, arguments.apply)


if __name__ == "__main__":
    main()
