from contextlib import redirect_stdout
import io
import os
from pathlib import Path
import subprocess
import tempfile
import time
import unittest

from cleanup import cleanup, git


class WorktreeCleanupTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.directory = Path(self.temporary.name).resolve()
        self.repo = self.directory / "repository"
        self.repo.mkdir()
        git(self.repo, "init", "--initial-branch=main")
        git(self.repo, "config", "user.name", "Cleanup Test")
        git(self.repo, "config", "user.email", "cleanup@example.com")
        (self.repo / ".gitignore").write_text("node_modules/\n.env\n")
        (self.repo / "source.txt").write_text("source\n")
        git(self.repo, "add", "--", ".gitignore", "source.txt")
        git(self.repo, "commit", "-m", "Initial source")
        git(self.repo, "update-ref", "refs/remotes/origin/main", "HEAD")
        git(self.repo, "symbolic-ref", "refs/remotes/origin/HEAD", "refs/remotes/origin/main")
        self.root = self.directory / "worktrees"
        self.path = self.root / "repository" / "finished"
        git(self.repo, "worktree", "add", "-b", "finished", str(self.path))

    def run_cleanup(self, apply):
        with redirect_stdout(io.StringIO()):
            return cleanup(self.root, 0, apply)

    def test_removes_clean_merged_worktree_with_dependencies_and_preserves_branch(self):
        dependencies = self.path / "node_modules"
        dependencies.mkdir()
        (dependencies / "package.js").write_text("downloaded dependency")
        head = git(self.repo, "rev-parse", "finished")

        self.assertEqual(self.run_cleanup(True), 1)
        self.assertFalse(self.path.exists())
        self.assertEqual(git(self.repo, "rev-parse", "finished"), head)
        self.assertNotIn(str(self.path), os.fsdecode(git(self.repo, "worktree", "list")))
        self.assertEqual((self.repo / "source.txt").read_text(), "source\n")

    def test_preview_preserves_eligible_worktree(self):
        self.assertEqual(self.run_cleanup(False), 0)
        self.assertTrue(self.path.exists())

    def test_keeps_unmerged_commits(self):
        (self.path / "source.txt").write_text("unfinished\n")
        git(self.path, "add", "--", "source.txt")
        git(self.path, "commit", "-m", "Unmerged work")

        self.assertEqual(self.run_cleanup(True), 0)
        self.assertEqual((self.path / "source.txt").read_text(), "unfinished\n")

    def test_keeps_tracked_changes(self):
        (self.path / "source.txt").write_text("unfinished\n")
        self.assertEqual(self.run_cleanup(True), 0)
        self.assertTrue(self.path.exists())

    def test_keeps_untracked_notes(self):
        (self.path / "notes.txt").write_text("personal notes\n")
        self.assertEqual(self.run_cleanup(True), 0)
        self.assertTrue(self.path.exists())

    def test_keeps_ignored_environment(self):
        (self.path / ".env").write_text("PERSONAL_SETTING=keep\n")
        self.assertEqual(self.run_cleanup(True), 0)
        self.assertTrue(self.path.exists())

    def test_keeps_locked_worktree(self):
        git(self.repo, "worktree", "lock", str(self.path))
        self.assertEqual(self.run_cleanup(True), 0)
        self.assertTrue(self.path.exists())

    def test_keeps_detached_head(self):
        git(self.path, "switch", "--detach")
        self.assertEqual(self.run_cleanup(True), 0)
        self.assertTrue(self.path.exists())

    def test_keeps_recent_nested_dependency_changes(self):
        nested = self.path / "node_modules"
        nested.mkdir()
        downloaded = nested / "package.js"
        downloaded.write_text("downloaded dependency")
        future = time.time() + 60
        os.utime(downloaded, (future, future))

        self.assertEqual(self.run_cleanup(True), 0)
        self.assertTrue(self.path.exists())

    def test_keeps_recent_git_activity(self):
        admin = Path(os.fsdecode(git(self.path, "rev-parse", "--absolute-git-dir")).strip())
        future = time.time() + 60
        os.utime(admin / "index", (future, future))

        self.assertEqual(self.run_cleanup(True), 0)
        self.assertTrue(self.path.exists())

    def test_keeps_process_working_directory(self):
        process = subprocess.Popen(["/bin/sleep", "60"], cwd=self.path)
        try:
            self.assertEqual(self.run_cleanup(True), 0)
            self.assertTrue(self.path.exists())
        finally:
            process.terminate()
            process.wait()

    def test_keeps_open_file_without_process_working_directory(self):
        with (self.path / "source.txt").open() as opened:
            process = subprocess.Popen(["/bin/sleep", "60"], pass_fds=(opened.fileno(),))
        try:
            self.assertEqual(self.run_cleanup(True), 0)
            self.assertTrue(self.path.exists())
        finally:
            process.terminate()
            process.wait()

    def test_keeps_worktree_when_remote_default_is_unknown(self):
        (self.path / "source.txt").write_text("unfinished\n")
        git(self.path, "add", "--", "source.txt")
        git(self.path, "commit", "-m", "Unmerged work")
        git(self.repo, "symbolic-ref", "--delete", "refs/remotes/origin/HEAD")
        self.assertEqual(self.run_cleanup(True), 0)
        self.assertTrue(self.path.exists())

    def start_from_unmerged_branch(self):
        git(self.repo, "switch", "-c", "feature")
        (self.repo / "source.txt").write_text("existing feature\n")
        git(self.repo, "add", "--", "source.txt")
        git(self.repo, "commit", "-m", "Existing feature work")
        git(self.repo, "worktree", "remove", str(self.path))
        git(self.repo, "branch", "-D", "finished")
        git(self.repo, "worktree", "add", "-b", "finished", str(self.path), "feature")

    def test_removes_untouched_worktree_from_unmerged_branch_and_preserves_history(self):
        self.start_from_unmerged_branch()
        head = git(self.repo, "rev-parse", "finished")

        self.assertEqual(self.run_cleanup(True), 1)
        self.assertFalse(self.path.exists())
        self.assertEqual(git(self.repo, "rev-parse", "finished"), head)
        self.assertEqual(git(self.repo, "show", "finished:source.txt"), b"existing feature\n")

    def test_keeps_untouched_worktree_with_untracked_notes(self):
        self.start_from_unmerged_branch()
        (self.path / "notes.txt").write_text("unfinished plan\n")
        self.assertEqual(self.run_cleanup(True), 0)
        self.assertTrue(self.path.exists())

    def test_keeps_untouched_worktree_until_age_threshold(self):
        self.start_from_unmerged_branch()
        with redirect_stdout(io.StringIO()):
            self.assertEqual(cleanup(self.root, 14, True), 0)
        self.assertTrue(self.path.exists())

    def test_keeps_unmerged_worktree_after_commits_are_reset(self):
        self.start_from_unmerged_branch()
        head = git(self.path, "rev-parse", "HEAD").strip().decode()
        (self.path / "source.txt").write_text("started work\n")
        git(self.path, "add", "--", "source.txt")
        git(self.path, "commit", "-m", "Started work")
        git(self.path, "reset", "--hard", head)

        self.assertEqual(self.run_cleanup(True), 0)
        self.assertTrue(self.path.exists())

    def test_keeps_unmerged_worktree_with_expired_creation_reflog(self):
        self.start_from_unmerged_branch()
        git(self.path, "reflog", "expire", "--expire=all", "HEAD")

        self.assertEqual(self.run_cleanup(True), 0)
        self.assertTrue(self.path.exists())

    def test_keeps_unmerged_worktree_after_switching_branches(self):
        self.start_from_unmerged_branch()
        git(self.path, "switch", "-c", "other-feature")

        self.assertEqual(self.run_cleanup(True), 0)
        self.assertTrue(self.path.exists())

    def test_keeps_group_symlink(self):
        outside = self.directory / "outside"
        outside.mkdir()
        (self.root / "outside").symlink_to(outside, target_is_directory=True)
        self.assertEqual(self.run_cleanup(True), 1)
        self.assertTrue(outside.exists())


if __name__ == "__main__":
    unittest.main()
