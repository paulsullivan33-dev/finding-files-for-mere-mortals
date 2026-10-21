"""Fixture builders can replace only their own completed trees."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

BASH = os.environ.get('BASH_EXECUTABLE') or shutil.which('bash')
ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'examples' / 'build-tree.sh'


@unittest.skipUnless(BASH, 'Bash required')
class FixtureSafetyTests(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.cwd = Path(directory.name)

    def build(self, target):
        return subprocess.run([BASH, str(SCRIPT), str(target)], cwd=self.cwd,
                              capture_output=True, text=True, timeout=30)

    def test_existing_unowned_data_is_never_removed(self):
        target = self.cwd / 'important'
        target.mkdir()
        keep = target / 'keep.txt'
        keep.write_text('unrelated data', encoding='utf-8')
        result = self.build('important')
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertEqual(keep.read_text(encoding='utf-8'), 'unrelated data')

    def test_protected_paths_are_rejected(self):
        keep = self.cwd / 'keep.txt'
        keep.write_text('keep', encoding='utf-8')
        for value in ('.', '..', str(self.cwd), str(self.cwd / 'missing' / '..')):
            with self.subTest(value=value):
                self.assertNotEqual(self.build(value).returncode, 0)
                self.assertEqual(keep.read_text(encoding='utf-8'), 'keep')

    def test_wrong_ownership_marker_is_rejected(self):
        target = self.cwd / 'wrong'
        target.mkdir()
        (self.cwd / 'wrong.mere-mortals-fixture').write_text('another-project:v1\n', encoding='utf-8')
        self.assertNotEqual(self.build('wrong').returncode, 0)
        self.assertTrue((self.cwd / 'wrong.mere-mortals-fixture').exists())

    def test_marker_lives_outside_the_tree(self):
        # The chapters print exact find counts for the tree, so the
        # ownership marker must never become one of its entries.
        first = self.build('tree')
        self.assertEqual(first.returncode, 0, first.stderr)
        self.assertFalse((self.cwd / 'tree' / '.mere-mortals-fixture').exists())
        self.assertTrue((self.cwd / 'tree.mere-mortals-fixture').is_file())

    def test_new_tree_and_owned_rebuild_succeed_with_spaces(self):
        target = self.cwd / 'owned lab'
        first = self.build('owned lab')
        self.assertEqual(first.returncode, 0, first.stderr)
        self.assertTrue((self.cwd / 'owned lab.mere-mortals-fixture').is_file())
        (target / 'stale.txt').write_text('old fixture', encoding='utf-8')
        second = self.build('owned lab')
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertFalse((target / 'stale.txt').exists())

    def test_overlapping_build_lock_is_respected(self):
        (self.cwd / 'busy.build-lock').mkdir()
        self.assertNotEqual(self.build('busy').returncode, 0)
        self.assertFalse((self.cwd / 'busy').exists())


if __name__ == '__main__':
    unittest.main()
