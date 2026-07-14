# data-cube-semantic-layer

## Prerequisites

- Docker (with Compose)
- AWS CLI, authenticated via SSO (`aws sso login --profile data`)
- `jq`

## Setup

### Cube

```bash
cd cube
cp .env.example .env   # fill in CUBEJS_AWS_S3_OUTPUT_LOCATION / workgroup if needed
./fetch-secrets.sh      # pulls Athena credentials from Secrets Manager into .env.runtime
docker compose up
```

Re-run `./fetch-secrets.sh` any time the Secrets Manager secret rotates or changes — Compose only reads `.env.runtime` at container start, so a stale file means stale credentials until the next restart.

Cube Playground: http://localhost:4000
SQL API (Postgres-compatible): `psql -h localhost -p 15432 -U cube -d cube`

### Metabase

`docker-compose.yml` also runs Metabase alongside Cube, connecting to it through Cube's Postgres-compatible SQL API — this is how any BI tool that speaks Postgres would connect, not just Metabase.

```bash
cd cube
docker compose up -d
```

This brings up three services:
- `cube` — the Cube API (Playground + SQL API), as above
- `metabase-db` (`postgres:15`) — Metabase's own application database (saved connections, users, dashboards). Backed by the `metabase-db-data` named volume, so it survives `docker compose down`/`up` cycles — only a `docker compose down -v` (which removes volumes) wipes it.
- `metabase` — pinned to a specific tag (currently `v0.61.1.x`) in `docker-compose.yml`; bump deliberately rather than tracking `latest`.

Open **http://localhost:3000**, complete the setup wizard (first run only — skipped on subsequent starts since the app DB persists), then add a database:
- Type: **PostgreSQL**
- Host: `cube` (Docker service name, not `localhost` — Metabase and Cube share the `cube_default` network)
- Port: `15432`
- Database name: `cube`
- Username/password: anything, in local dev mode (`CUBEJS_DEV_MODE=true` disables SQL API auth) — use real `CUBEJS_SQL_USER`/`CUBEJS_SQL_PASSWORD` values if testing against a production-mode Cube (see below)

## Testing

### Testing changes to the data model

1. **Restart and watch the logs.** Any broken `joins:`/`views:` reference (typo, missing cube, bad `join_path`) fails at startup, before you can even query anything:
   ```bash
   docker compose down && docker compose up
   ```

2. **Confirm a cube/view registered with the fields you expect:**
   ```bash
   curl -s http://localhost:4000/cubejs-api/v1/meta | python3 -c "
   import json,sys
   d=json.load(sys.stdin)
   c=[c for c in d['cubes'] if c['name']=='sales'][0]
   print([m['name'] for m in c['measures']])
   print([dm['name'] for dm in c['dimensions']])
   "
   ```
   For fields reached through a multi-hop `join_path` in a view, the generated name is prefixed by the **cube name**, not the full path (e.g. `sales.market_mapping_market`, not `sales.user_last_properties_market_mapping_market`).

3. **Run a real query that exercises the join chain** — include at least one field from the base cube, one from a direct join, and one from a multi-hop join, so the generated SQL has to traverse every edge rather than just hitting the base table:
   ```bash
   curl -s -G http://localhost:4000/cubejs-api/v1/load \
     --data-urlencode 'query={"measures":["sales.gross_sales_euro"],"dimensions":["sales.users_account_created_at","sales.market_mapping_market"],"limit":5}'
   ```
   A first response of `{"error":"Continue wait"}` is normal (Cube runs queries as an async job) — just re-issue the same request.

4. Check `transformedQuery.allBackAliasMembers` in the response — it shows the real join path each field resolved through, useful for confirming Cube joined the way you intended.

The same checks can be done visually in the Playground instead of `curl` — pick fields spanning multiple joined cubes/views and hit Run.

### Testing production-mode behavior (visibility, access control)

`CUBEJS_DEV_MODE=true` disables all authentication and visibility enforcement ("Authentication checks are disabled in developer mode"). This means anything that depends on `public: false` — hiding a cube or field from the SQL API, e.g. so Metabase only sees curated views like `sales` and not the raw cubes it's built from — **cannot be verified while running in dev mode**. It'll look like `public: false` does nothing, even when the schema is correct, because dev mode bypasses the check entirely rather than the restriction being broken.

To actually test this, temporarily run Cube the way it would run in production:

1. Edit `cube/.env`:
   ```bash
   # comment out or remove: CUBEJS_DEV_MODE=true
   CUBEJS_DEV_MODE=false
   NODE_ENV=production
   CUBEJS_SQL_USER=testuser
   CUBEJS_SQL_PASSWORD=testpass123
   CUBEJS_PG_SQL_PORT=15432
   # production mode doesn't auto-start the embedded Cube Store dev mode uses;
   # this avoids needing a separate Cube Store deployment for a schema with
   # no pre_aggregations defined
   CUBEJS_CACHE_AND_QUEUE_DRIVER=memory
   ```
2. Restart: `docker compose up -d cube`
3. Verify only intended tables are exposed:
   ```bash
   docker run --rm --network cube_default postgres:16 psql \
     "postgresql://testuser:testpass123@cube:15432/cube" -c "\dt"
   ```
4. Verify querying still works end-to-end (not just table listing):
   ```bash
   docker run --rm --network cube_default postgres:16 psql \
     "postgresql://testuser:testpass123@cube:15432/cube" \
     -c "SELECT market_mapping_market, SUM(gross_sales_euro) AS total FROM sales GROUP BY 1;"
   ```
5. **Revert `cube/.env` back to `CUBEJS_DEV_MODE=true`** (remove the other temporary vars) and restart — otherwise local dev loses the Playground, schema hot-reload, and open auth that make day-to-day iteration fast.

If a field or cube is supposed to be hidden and still shows up in step 3, that's a real schema issue (missing `public: false`, or a view's `excludes:` not covering it) — only trust a "hidden" result observed under this production-mode setup, not under normal dev-mode testing.

### Testing with Metabase

**Re-syncing after a model change:** Metabase caches its own copy of Cube's table/column list. After changing cubes/views, refresh it without touching the connection itself:
**Admin → Databases → your Cube connection → "Sync database schema now"** (or `POST /api/database/:id/sync_schema` with an admin session token).

Renaming or removing a field that's used in an existing saved question breaks that question — a sync only refreshes what Metabase knows exists, it doesn't repair references to fields that no longer do.

**Known Cube/Metabase interaction issues:**

- **`information_schema.columns` lists `public: false` fields even though querying them fails.** Cube's SQL API doesn't filter hidden fields out of its catalog the way the REST/GraphQL API does, so Metabase's schema sync will pick up "hidden" fields and error the moment anything actually queries them (auto X-rays, "browse data", field-value scans). The fix is `excludes:` in the view (see `cube/model/views/sales.yml`), not relying on `public: false` alone — see the production-mode testing section above for why `public: false` looks like it should be enough but isn't sufficient for the SQL API specifically.
- **Metabase's relative-date filters ("yesterday", "previous N days") generate SQL Cube's rewrite engine can't parse.** The generated pattern is `WHERE col >= CAST(CAST((NOW() + INTERVAL '-1 day') AS DATE) AS TIMESTAMP) AND col < CAST(CAST(NOW() AS DATE) AS TIMESTAMP)`, which fails with `Rewrite Error: Can't detect Cube query and it may be not supported yet`. Confirmed still broken on both `v1.6.69` and `v1.7.2` — this isn't fixed by picking a newer Cube version. Workaround: use a native SQL question, or an explicit/fixed date range in the GUI filter instead of a relative-date shortcut.
