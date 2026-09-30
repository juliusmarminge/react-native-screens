import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const output = process.argv[2];
if (!output) throw new Error('Usage: yarn pack:t3 <output-directory>');
const destination = resolve(output);
const run = (program, args, options = {}) =>
  execFileSync(program, args, { cwd: root, encoding: 'utf8', ...options });
const pkg = JSON.parse(readFileSync(join(root, 'package.json'), 'utf8'));
if (!/^5\.0\.0-t3\.\d+$/.test(pkg.version)) {
  throw new Error('Set a unique 5.0.0-t3.N package version before packaging.');
}
if (run('git', ['status', '--porcelain']).trim()) {
  throw new Error('Commit source changes before packaging.');
}
const provenance = {
  repository: 'https://github.com/juliusmarminge/react-native-screens',
  commit: run('git', ['rev-parse', 'HEAD']).trim(),
  upstreamCommit: run('git', ['merge-base', 'HEAD', 'refs/remotes/origin/main']).trim(),
  version: pkg.version,
};
const yarn = ['.yarn/releases/yarn-4.1.1.cjs'];
run(process.execPath, [...yarn, 'install', '--immutable', '--mode=skip-build'], { stdio: 'inherit' });
run(process.execPath, [...yarn, 'bob', 'build'], { stdio: 'inherit' });
mkdirSync(destination, { recursive: true });
const metadata = join(root, 't3-fork.json');
try {
  writeFileSync(metadata, JSON.stringify(provenance, null, 2) + '\n');
  const [packed] = JSON.parse(run('npm', [
    'pack', '--ignore-scripts', '--json', '--pack-destination', destination,
  ]));
  const artifact = join(destination, packed.filename);
  console.log(JSON.stringify({
    ...provenance,
    artifact,
    sha256: createHash('sha256').update(readFileSync(artifact)).digest('hex'),
  }, null, 2));
} finally {
  rmSync(metadata, { force: true });
}
