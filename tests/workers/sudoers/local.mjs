import test from 'node:test';
import assert from 'node:assert/strict';

test('fetch local', async () => {
  assert.match(await fetch("http://localhost:8787")
    .then(response => response.text()), /system or development \${REPO} repository installer/);
});

