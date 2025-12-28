# ActivityPub Testing - Quick Start

This directory contains everything you need to test ActivityPub federation for Solar Network.

## Quick Start

### 1. Run the Setup Script

```bash
./setup-activitypub-test.sh
```

This will:
- ✅ Check prerequisites (Docker, PostgreSQL)
- ✅ Update `/etc/hosts` with test domains
- ✅ Generate Mastodon environment file
- ✅ Create Docker Compose file
- ✅ Start Mastodon containers
- ✅ Create test Mastodon account
- ✅ Apply Solar Network migrations

### 2. Start Solar Network

```bash
cd DysonNetwork.Sphere
dotnet run
```

### 3. Test Federation

Follow the scenarios in [ACTIVITYPUB_TESTING_GUIDE.md](ACTIVITYPUB_TESTING_GUIDE.md)

## Test Instances

| Service | URL | Notes |
|---------|-----|-------|
| Solar Network | http://solar.local:5000 | Your implementation |
| Mastodon | http://mastodon.local:3001 | Test instance |
| Mastodon Streaming | http://mastodon.local:4000 | WebSocket |

## Test Accounts

### Solar Network
- Create via UI or API
- Username: `solaruser` (or your choice)

### Mastodon
- Username: `testuser@mastodon.local`
- Password: `TestPassword123!`
- Role: Admin

## Quick Test Commands

### Test WebFinger
```bash
curl "http://solar.local:5000/.well-known/webfinger?resource=acct:solaruser@solar.local"
```

### Test Actor
```bash
curl -H "Accept: application/activity+json" \
  http://solar.local:5000/activitypub/actors/solaruser
```

### Test Outbox
```bash
curl -H "Accept: application/activity+json" \
  http://solar.local:5000/activitypub/actors/solaruser/outbox
```

### Test Follow (from Mastodon)
1. Open http://mastodon.local:3001
2. Log in as `testuser@mastodon.local`
3. Search for `@solaruser@solar.local`
4. Click Follow

### Test Follow (from Solar Network to Mastodon)
```bash
# Send Follow activity to Solar Network
curl -X POST http://solar.local:5000/activitypub/actors/solaruser/inbox \
  -H "Content-Type: application/activity+json" \
  -d '{
    "@context": "https://www.w3.org/ns/activitystreams",
    "id": "http://solar.local:5000/follow-1",
    "type": "Follow",
    "actor": "https://solar.local:5000/activitypub/actors/solaruser",
    "object": "http://mastodon.local:3001/users/testuser"
  }'
```

## Documentation Files

| File | Purpose |
|------|---------|
| `ACTIVITYPUB_TESTING_GUIDE.md` | Comprehensive testing guide |
| `ACTIVITYPUB_TESTING_QUICKREF.md` | Quick command reference |
| `ACTIVITYPUB_IMPLEMENTATION.md` | Implementation details |
| `ACTIVITYPUB_SUMMARY.md` | Feature summary |
| `ACTIVITYPUB_PLAN.md` | Original implementation plan |

## Database Checks

### Connect to Database
```bash
psql -d dyson_network
```

### View Actors
```sql
SELECT uri, username, display_name, created_at 
FROM fediverse_actors;
```

### View Contents
```sql
SELECT uri, type, content, actor_id, created_at 
FROM fediverse_contents 
ORDER BY created_at DESC 
LIMIT 10;
```

### View Relationships
```sql
SELECT state, is_following, is_followed_by, created_at 
FROM fediverse_relationships;
```

### View Activities
```sql
SELECT type, status, error_message, created_at 
FROM fediverse_activities 
ORDER BY created_at DESC 
LIMIT 10;
```

## Logs

### Solar Network Logs
```bash
# Live logs
dotnet run --project DysonNetwork.Sphere

# Follow ActivityPub activity
dotnet run --project DysonNetwork.Sphere 2>&1 | grep -i activitypub

# Debug logging
dotnet run --project DysonNetwork.Sphere --logging:LogLevel:DysonNetwork.Sphere.ActivityPub=Trace
```

### Mastodon Logs
```bash
# All services
docker compose -f docker-compose.mastodon-test.yml logs -f

# Web service only
docker compose -f docker-compose.mastodon-test.yml logs -f web

# Filter for federation
docker compose -f docker-compose.mastodon-test.yml logs -f web | grep -i federation
```

## Stopping Everything

```bash
# Stop Mastodon
docker compose -f docker-compose.mastodon-test.yml down

# Stop with volume cleanup
docker compose -f docker-compose.mastodon-test.yml down -v

# Restore /etc/hosts
sudo mv /etc/hosts.backup /etc/hosts

# Remove test databases (optional)
psql -d dyson_network <<EOF
TRUNCATE fediverse_activities CASCADE;
TRUNCATE fediverse_relationships CASCADE;
TRUNCATE fediverse_reactions CASCADE;
TRUNCATE fediverse_contents CASCADE;
TRUNCATE fediverse_actors CASCADE;
TRUNCATE fediverse_instances CASCADE;
UPDATE publishers SET meta = NULL WHERE meta IS NOT NULL;
EOF
```

## Troubleshooting

### Mastodon won't start

```bash
# Check logs
docker compose -f docker-compose.mastodon-test.yml logs -f web

# Restart
docker compose -f docker-compose.mastodon-test.yml restart

# Recreate
docker compose -f docker-compose.mastodon-test.yml down
docker compose -f docker-compose.mastodon-test.yml up -d
```

### Can't connect to Solar Network

```bash
# Check if running
curl http://solar.local:5000

# Check logs
dotnet run --project DysonNetwork.Sphere 2>&1 | grep -i error

# Restart
# Ctrl+C in terminal and run again
```

### Activities not arriving

```bash
# Check database
psql -d dyson_network -c "SELECT * FROM fediverse_activities WHERE status = 3;"

# Check signature verification logs
dotnet run --project DysonNetwork.Sphere 2>&1 | grep -i "signature"

# Verify actor keys
curl -H "Accept: application/activity+json" \
  http://solar.local:5000/activitypub/actors/solaruser | jq '.publicKey'
```

## Testing Checklist

- [ ] Setup script completed successfully
- [ ] Mastodon is running and accessible
- [ ] Solar Network is running and accessible
- [ ] WebFinger returns correct data
- [ ] Actor profile includes public key
- [ ] Follow from Mastodon to Solar Network works
- [ ] Follow from Solar Network to Mastodon works
- [ ] Posts from Solar Network appear in Mastodon
- [ ] Posts from Mastodon appear in Solar Network database
- [ ] Likes federate correctly
- [ ] Replies federate correctly
- [ ] HTTP signatures are verified
- [ ] No errors in logs
- [ ] Database contains expected data

## Next Steps

1. **Test with a real instance**:
   - Get a public domain or use ngrok
   - Update `ActivityPub:Domain` in appsettings.json
   - Test with mastodon.social or other public instances

2. **Add more features**:
   - Activity queue for async processing
   - Retry logic for failed deliveries
   - Metrics and monitoring
   - Admin interface for federation management

3. **Test with more instances**:
   - Pleroma
   - Pixelfed
   - Lemmy
   - PeerTube

## Getting Help

If something doesn't work:

1. Check the logs (see Logs section above)
2. Review the troubleshooting section in [ACTIVITYPUB_TESTING_GUIDE.md](ACTIVITYPUB_TESTING_GUIDE.md)
3. Verify all prerequisites are installed
4. Check network connectivity between instances
5. Review the [ACTIVITYPUB_IMPLEMENTATION.md](ACTIVITYPUB_IMPLEMENTATION.md) for architecture details

## Useful URLs

### Test Instances
- Mastodon: http://mastodon.local:3001
- Solar Network: http://solar.local:5000

### Documentation
- ActivityPub W3C Spec: https://www.w3.org/TR/activitypub/
- Mastodon Federation Docs: https://docs.joinmastodon.org/admin/federation/
- ActivityPub Playground: https://swicth.github.io/activity-pub-playground/

### Tools
- jq: JSON processor (https://stedolan.github.io/jq/)
- httpie: HTTP client (https://httpie.io/)
- Docker Compose: (https://docs.docker.com/compose/)
