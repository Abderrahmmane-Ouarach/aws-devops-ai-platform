import client from 'prom-client';

client.collectDefaultMetrics();

export const httpDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.005, 0.01, 0.05, 0.1, 0.5, 1, 2],
});

export const cacheLookups = new client.Counter({
  name: 'cache_lookups_total',
  help: 'Redis lookups on redirect, by result',
  labelNames: ['result'],
});

export const linksCreated = new client.Counter({
  name: 'links_created_total',
  help: 'Short links created',
});

export const register = client.register;