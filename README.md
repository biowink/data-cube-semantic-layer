# data-cube-semantic-layer

## Running Cube locally

### Prerequisites

- Docker (with Compose)
- AWS CLI, authenticated via SSO (`aws sso login --profile data`)
- `jq`

### Setup

```bash
cd cube
cp .env.example .env   # fill in CUBEJS_AWS_S3_OUTPUT_LOCATION / workgroup if needed
./fetch-secrets.sh      # pulls Athena credentials from Secrets Manager into .env.runtime
docker compose up
```

Re-run `./fetch-secrets.sh` any time the Secrets Manager secret rotates or changes — Compose only reads `.env.runtime` at container start, so a stale file means stale credentials until the next restart.

Cube Playground: http://localhost:4000
SQL API (Postgres-compatible): `psql -h localhost -p 15432 -U cube -d cube`

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
