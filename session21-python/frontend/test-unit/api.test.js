import assert from 'node:assert/strict';
import {test} from 'node:test';
import {request} from '../src/api.js';

test('an unreadable successful mutation response warns about unknown outcome', async t => {
  t.mock.method(globalThis, 'fetch', async () => ({
    ok: true, status: 200,
    json: async () => {throw new SyntaxError('Truncated JSON');},
  }));
  await assert.rejects(request('/api/equipment/1', {method: 'PUT'}), /Request outcome unknown/);
});

test('body timeout during a read produces an actionable error', async t => {
  t.mock.method(globalThis, 'fetch', async () => ({
    ok: true, status: 200,
    json: async () => {throw new DOMException('Timed out', 'TimeoutError');},
  }));
  await assert.rejects(request('/api/equipment'), /server response/);
});

for (const detail of [null, {detail: {}}, {detail: [null, 'unexpected']}]) {
  test(`malformed error payload stays readable: ${JSON.stringify(detail)}`, async t => {
    t.mock.method(globalThis, 'fetch', async () => Response.json(detail, {status: 503}));
    await assert.rejects(request('/api/equipment'), /Request failed/);
  });
}

test('validation errors retain their useful field and message', async t => {
  t.mock.method(globalThis, 'fetch', async () => Response.json({
    detail: [{loc: ['body', 'name'], msg: 'Must not be blank'}],
  }, {status: 422}));
  await assert.rejects(request('/api/equipment', {method: 'POST'}), /name: Must not be blank/);
});

test('204 does not attempt to parse an empty body', async t => {
  t.mock.method(globalThis, 'fetch', async () => new Response(null, {status: 204}));
  assert.equal(await request('/api/equipment/1', {method: 'DELETE'}), null);
});

test('caller cancellation is preserved, not reported as a network failure', async t => {
  const controller = new AbortController();
  controller.abort();
  t.mock.method(globalThis, 'fetch', async () => {throw controller.signal.reason;});
  await assert.rejects(request('/api/equipment', {signal: controller.signal}), {name: 'AbortError'});
});
