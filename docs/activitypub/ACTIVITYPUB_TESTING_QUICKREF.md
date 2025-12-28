# ActivityPub Testing Quick Reference

## Quick Test Commands

### 1. Test WebFinger
```bash
curl "http://solar.local:5000/.well-known/webfinger?resource=acct:username@solar.local"
```

### 2. Fetch Actor Profile
```bash
curl -H "Accept: application/activity+json" \
  http://solar.local:5000/activitypub/actors/username
```

### 3. Get Outbox
```bash
curl -H "Accept: application/activity+json" \
  http://solar.local:5000/activitypub/actors/username/outbox
```

### 4. Send Test Follow (from remote)
```bash
curl -X POST http://solar.local:5000/activitypub/actors/username/inbox \
  -H "Content-Type: application/activity+json" \
  -d '{
    "@context": "https://www.w3.org/ns/activitystreams",
    "id": "https://mastodon.local:3001/follow-123",
    "type": "Follow",
    "actor": "https://mastodon.local:3001/users/remoteuser",
    "object": "https://solar.local:5000/activitypub/actors/username"
  }'
```

### 5. Send Test Create (post)
```bash
curl -X POST http://solar.local:5000/activitypub/actors/username/inbox \
  -H "Content-Type: application/activity+json" \
  -d '{
    "@context": "https://www.w3.org/ns/activitystreams",
    "id": "https://mastodon.local:3001/post-123",
    "type": "Create",
    "actor": "https://mastodon.local:3001/users/remoteuser",
    "object": {
      "id": "https://mastodon.local:3001/objects/post-123",
      "type": "Note",
      "content": "Hello from Mastodon! @username@solar.local",
      "attributedTo": "https://mastodon.local:3001/users/remoteuser",
      "to": ["https://www.w3.org/ns/activitystreams#Public"]
    }
  }'
```

### 6. Send Test Like
```bash
curl -X POST http://solar.local:5000/activitypub/actors/username/inbox \
  -H "Content-Type: application/activity+json" \
  -d '{
    "@context": "https://www.w3.org/ns/activitystreams",
    "id": "https://mastodon.local:3001/like-123",
    "type": "Like",
    "actor": "https://mastodon.local:3001/users/remoteuser",
    "object": "https://solar.local:5000/activitypub/objects/post-id"
  }'
```

## Database Queries

### Check Actors
```sql
SELECT id, uri, username, display_name, instance_id 
FROM fediverse_actors;
```

### Check Contents
```sql
SELECT id, uri, type, content, actor_id, created_at 
FROM fediverse_contents 
ORDER BY created_at DESC 
LIMIT 20;
```

### Check Relationships
```sql
SELECT r.id, a1.uri as actor, a2.uri as target, r.state, r.is_following
FROM fediverse_relationships r
JOIN fediverse_actors a1 ON r.actor_id = a1.id
JOIN fediverse_actors a2 ON r.target_actor_id = a2.id;
```

### Check Activities
```sql
SELECT type, status, error_message, created_at 
FROM fediverse_activities 
ORDER BY created_at DESC 
LIMIT 20;
```

### Check Reactions
```sql
SELECT r.type, c.uri as content_uri, a.uri as actor_uri
FROM fediverse_reactions r
JOIN fediverse_contents c ON r.content_id = c.id
JOIN fediverse_actors a ON r.actor_id = a.id;
```

## Check Keys in Publisher
```sql
SELECT id, name, meta 
FROM publishers 
WHERE meta IS NOT NULL;
```

## Docker Commands

### Start Mastodon
```bash
docker-compose -f docker-compose.mastodon-test.yml up -d
```

### View Mastodon Logs
```bash
docker-compose -f docker-compose.mastodon-test.yml logs -f web
```

### Stop Mastodon
```bash
docker-compose -f docker-compose.mastodon-test.yml down
```

### Start GoToSocial
```bash
docker-compose -f docker-compose.gotosocial.yml up -d
```

## Solar Network Commands

### Run Migrations
```bash
cd DysonNetwork.Sphere
dotnet ef database update
```

### Run with Debug Logging
```bash
dotnet run --project DysonNetwork.Sphere -- --logging:LogLevel:DysonNetwork.Sphere.ActivityPub=Trace
```

## Common Response Codes

| Code | Meaning |
|------|---------|
| 200  | Success |
| 202  | Accepted (activity queued) |
| 401  | Unauthorized (invalid signature) |
| 404  | Not found (user/post doesn't exist) |
| 400  | Bad request (invalid activity) |

## Activity Status Codes

| Status | Code | Meaning |
|--------|------|---------|
| Pending | 0 | Activity waiting to be processed |
| Processing | 1 | Activity being processed |
| Completed | 2 | Activity successfully processed |
| Failed | 3 | Activity processing failed |

## Relationship States

| State | Code | Meaning |
|--------|------|---------|
| Pending | 0 | Follow request sent, waiting for Accept |
| Accepted | 1 | Follow accepted, relationship active |
| Rejected | 2 | Follow rejected |

## Troubleshooting

### "Failed to verify signature"

**Check**: Signature header format
```bash
# Should be:
Signature: keyId="...",algorithm="rsa-sha256",headers="...",signature="..."
```

**Check**: Public key in actor profile
```bash
curl -H "Accept: application/activity+json" \
  http://solar.local:5000/activitypub/actors/username | jq '.publicKey'
```

### "Actor not found"

**Check**: Actor exists in database
```bash
psql -d dyson_network -c \
  "SELECT * FROM fediverse_actors WHERE uri = '...';"
```

**Check**: Actor URL is accessible
```bash
curl -v http://remote-instance.com/users/username
```

### "Content already exists"

This is normal behavior - the system is deduplicating.

### "Target publisher not found"

**Check**: Publisher exists
```bash
psql -d dyson_network -c \
  "SELECT * FROM publishers WHERE name = '...';"
```

## Quick Test Sequence

### Full Federation Test

```bash
# 1. Start both instances
docker-compose -f docker-compose.mastodon-test.yml up -d
dotnet run --project DysonNetwork.Sphere

# 2. Test WebFinger
curl "http://solar.local:5000/.well-known/webfinger?resource=acct:solaruser@solar.local"

# 3. Get Actor
curl -H "Accept: application/activity+json" \
  http://solar.local:5000/activitypub/actors/solaruser

# 4. Send Follow from Mastodon
# (Do this in Mastodon UI or use curl above)

# 5. Check database
psql -d dyson_network -c "SELECT * FROM fediverse_relationships;"

# 6. Send Create (post) from Mastodon
# (Use curl command above)

# 7. Check content
psql -d dyson_network -c "SELECT * FROM fediverse_contents;"

# 8. Send Like from Mastodon
# (Use curl command above)

# 9. Check reactions
psql -d dyson_network -c "SELECT * FROM fediverse_reactions;"

# 10. Check activities
psql -d dyson_network -c "SELECT type, status FROM fediverse_activities;"
```

## Test URLs

| Instance | Web | API | ActivityPub |
|----------|-----|-----|-----------|
| Solar Network | http://solar.local:5000 | http://solar.local:5000/api | http://solar.local:5000/activitypub |
| Mastodon | http://mastodon.local:3001 | http://mastodon.local:3001/api/v1 | http://mastodon.local:3001/inbox |

## Environment Variables

### Solar Network
```bash
export SOLAR_DOMAIN="solar.local"
export SOLAR_URL="http://solar.local:5000"
```

### Mastodon
```bash
export MASTODON_DOMAIN="mastodon.local"
export MASTODON_URL="http://mastodon.local:3001"
```

## Useful jq Commands

### Extract Actor ID
```bash
curl ... | jq '.id'
```

### Extract Inbox URL
```bash
curl ... | jq '.inbox'
```

### Extract Public Key
```bash
curl ... | jq '.publicKey.publicKeyPem'
```

### Pretty Print Activity
```bash
curl ... | jq '.'
```

### Extract Activity Type
```bash
curl ... | jq '.type'
```

## Network Setup

### /etc/hosts
```
127.0.0.1  solar.local
127.0.0.1  mastodon.local
127.0.0.1  gotosocial.local
```

### Ports Used
- Solar Network: 5000
- Mastodon: 3001 (web), 4000 (streaming)
- GoToSocial: 3002
- PostgreSQL: 5432
- Redis: 6379
- Elasticsearch: 9200

## File Locations

### Docker Compose Files
- `docker-compose.mastodon-test.yml`
- `docker-compose.gotosocial.yml`

### Environment Files
- `.env.mastodon`

### Data Volumes
- `./mastodon-data/`
- `./gotosocial-data/`

## Clean Up Commands

```bash
# Reset database
psql -d dyson_network <<EOF
TRUNCATE fediverse_activities CASCADE;
TRUNCATE fediverse_relationships CASCADE;
TRUNCATE fediverse_reactions CASCADE;
TRUNCATE fediverse_contents CASCADE;
TRUNCATE fediverse_actors CASCADE;
TRUNCATE fediverse_instances CASCADE;
UPDATE publishers SET meta = NULL WHERE meta IS NOT NULL;
EOF

# Reset everything
docker-compose -f docker-compose.mastodon-test.yml down -v
docker-compose -f docker-compose.gotosocial.yml down -v
psql -d dyson_network <<EOF
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
EOF
dotnet ef database drop
dotnet ef database update
```
