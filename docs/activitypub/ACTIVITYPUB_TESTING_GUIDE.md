# ActivityPub Testing Guide for Solar Network

This guide will help you test the ActivityPub implementation in Solar Network, starting with a self-hosted instance and then moving to a real instance.

## Prerequisites

- ✅ Solar Network codebase with ActivityPub implementation
- ✅ Docker installed (for running Mastodon/Fediverse instances)
- ✅ PostgreSQL database running
- ✅ `.NET 10` SDK

## Part 1: Set Up a Self-Hosted Test Instance

### Option A: Using Mastodon (Recommended for Compatibility)

#### 1. Create a Docker Compose File

Create `docker-compose.mastodon-test.yml`:

```yaml
version: '3'

services:
  db:
    restart: always
    image: postgres:14-alpine
    environment:
      POSTGRES_USER: mastodon
      POSTGRES_PASSWORD: mastodon_password
      POSTGRES_DB: mastodon
    networks:
      - mastodon_network
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "mastodon"]
      interval: 5s
      retries: 5

  redis:
    restart: always
    image: redis:7-alpine
    networks:
      - mastodon_network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      retries: 5

  es:
    restart: always
    image: docker.elastic.co/elasticsearch:8.10.2
    environment:
      - "discovery.type=single-node"
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - "xpack.security.enabled=false"
    networks:
      - mastodon_network
    healthcheck:
      test: ["CMD-SHELL", "curl -silent http://localhost:9200/_cluster/health || exit 1"]
      interval: 10s
      retries: 10

  web:
    restart: always
    image: tootsuite/mastodon:latest
    env_file: .env.mastodon
    command: bash -c "rm -f /mastodon/tmp/pids/server.pid; bundle exec rails s -p 3000"
    ports:
      - "3001:3000"
    depends_on:
      - db
      - redis
      - es
    networks:
      - mastodon_network
    volumes:
      - ./mastodon-data/public:/mastodon/public/system

  streaming:
    restart: always
    image: tootsuite/mastodon:latest
    env_file: .env.mastodon
    command: node ./streaming
    ports:
      - "4000:4000"
    depends_on:
      - db
      - redis
    networks:
      - mastodon_network

  sidekiq:
    restart: always
    image: tootsuite/mastodon:latest
    env_file: .env.mastodon
    command: bundle exec sidekiq
    depends_on:
      - db
      - redis
    networks:
      - mastodon_network

networks:
  mastodon_network:
    driver: bridge
```

#### 2. Create Environment File

Create `.env.mastodon`:

```bash
# Federation
LOCAL_DOMAIN=mastodon.local
LOCAL_HTTPS=false

# Database
DB_HOST=db
DB_PORT=5432
DB_USER=mastodon
DB_NAME=mastodon
DB_PASS=mastodon_password

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# Elasticsearch
ES_ENABLED=true
ES_HOST=es
ES_PORT=9200

# Secrets (generate these!)
SECRET_KEY_BASE=change_me_to_a_random_string_at_least_32_chars
OTP_SECRET=change_me_to_another_random_string

# Defaults
SINGLE_USER_MODE=false
DEFAULT_LOCALE=en
```

**Generate secrets:**
```bash
# Run these to generate random secrets
openssl rand -base64 32
```

#### 3. Start Mastodon

```bash
docker-compose -f docker-compose.mastodon-test.yml up -d

# Check logs
docker-compose -f docker-compose.mastodon-test.yml logs -f web
```

Wait for the web service to be healthy (may take 2-5 minutes).

#### 4. Create a Mastodon Account

```bash
# Run this command to create an admin account
docker-compose -f docker-compose.mastodon-test.yml exec web \
  bin/tootctl accounts create \
  testuser \
  testuser@mastodon.local \
  --email=test@example.com \
  --confirmed \
  --role=admin \
  --approve
```

Set password: `TestPassword123!`

#### 5. Update Your /etc/hosts

```bash
sudo nano /etc/hosts
```

Add:
```
127.0.0.1   mastodon.local
127.0.0.1   solar.local
```

### Option B: Using GoToSocial (Lightweight Alternative)

Create `docker-compose.gotosocial.yml`:

```yaml
version: '3'

services:
  gotosocial:
    image: superseriousbusiness/gotosocial:latest
    environment:
      - GTS_HOST=gotosocial.local
      - GTS_ACCOUNT_DOMAIN=gotosocial.local
      - GTS_PROTOCOL=http
      - GTS_DB_TYPE=sqlite
      - GTS_DB_ADDRESS=/gotosocial/data/sqlite.db
      - GTS_STORAGE_LOCAL_BASE_PATH=/gotosocial/data/storage
    ports:
      - "3002:8080"
    volumes:
      - ./gotosocial-data:/gotosocial/data

networks:
  default:
```

Start it:
```bash
docker-compose -f docker-compose.gotosocial.yml up -d
```

Create account:
```bash
docker-compose -f docker-compose.gotosocial.yml exec gotosocial \
  /gotosocial/gotosocial admin account create \
  --username testuser \
  --email test@example.com \
  --password TestPassword123!
```

## Part 2: Configure Solar Network for Federation

### 1. Update appsettings.json

Edit `DysonNetwork.Sphere/appsettings.json`:

```json
{
  "ActivityPub": {
    "Domain": "solar.local",
    "EnableFederation": true
  },
  "Kestrel": {
    "Endpoints": {
      "Http": {
        "Url": "http://solar.local:5000"
      }
    }
  }
}
```

### 2. Update /etc/hosts

Add both instances:
```
127.0.0.1   mastodon.local
127.0.0.1   solar.local
127.0.0.1   gotosocial.local
```

### 3. Apply Database Migrations

```bash
cd DysonNetwork.Sphere
dotnet ef database update
```

### 4. Start Solar Network

```bash
dotnet run --project DysonNetwork.Sphere
```

Solar Network should now be running on `http://solar.local:5000`

## Part 3: Create Test Users

### In Solar Network

1. Open http://solar.local:5000 (or your web interface)
2. Create a new account/publisher named `solaruser`
3. Note down the publisher ID for later

**Or via API** (if you have an existing account):

```bash
# First, create a publisher in Solar Network
curl -X POST http://solar.local:5000/api/publishers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "name": "solaruser",
    "nick": "Solar User",
    "bio": "Testing ActivityPub federation!",
    "type": 0
  }'
```

### In Mastodon

Open http://mastodon.local:3001 and log in with:
- Username: `testuser`
- Password: `TestPassword123!`

## Part 4: Test Federation Scenarios

### Test 1: WebFinger Discovery

**Goal**: Verify Solar Network is discoverable

```bash
# Query Solar Network's WebFinger endpoint
curl -v "http://solar.local:5000/.well-known/webfinger?resource=acct:solaruser@solar.local"

# Expected response (200 OK):
{
  "subject": "acct:solaruser@solar.local",
  "links": [
    {
      "rel": "self",
      "type": "application/activity+json",
      "href": "https://solar.local:5000/activitypub/actors/solaruser"
    },
    {
      "rel": "http://webfinger.net/rel/profile-page",
      "type": "text/html",
      "href": "https://solar.local:5000/users/solaruser"
    }
  ]
}
```

### Test 2: Fetch Actor Profile

**Goal**: Get ActivityPub actor JSON

```bash
# Fetch Solar Network actor from Mastodon
curl -H "Accept: application/activity+json" \
  http://solar.local:5000/activitypub/actors/solaruser

# Expected response includes:
{
  "@context": ["https://www.w3.org/ns/activitystreams"],
  "id": "https://solar.local:5000/activitypub/actors/solaruser",
  "type": "Person",
  "preferredUsername": "solaruser",
  "inbox": "https://solar.local:5000/activitypub/actors/solaruser/inbox",
  "outbox": "https://solar.local:5000/activitypub/actors/solaruser/outbox",
  "followers": "https://solar.local:5000/activitypub/actors/solaruser/followers",
  "publicKey": {
    "id": "https://solar.local:5000/activitypub/actors/solaruser#main-key",
    "owner": "https://solar.local:5000/activitypub/actors/solaruser",
    "publicKeyPem": "-----BEGIN PUBLIC KEY-----\n..."
  }
}
```

### Test 3: Follow from Mastodon to Solar Network

**Goal**: Mastodon user follows Solar Network user

1. **In Mastodon**:
   - Go to http://mastodon.local:3001
   - In search bar, type: `@solaruser@solar.local`
   - Click the follow button

2. **Verify in Solar Network**:
```bash
# Check database for relationship
psql -d dyson_network -c \
  "SELECT * FROM fediverse_relationships WHERE is_local_actor = true;"
```

3. **Check Solar Network logs**:
   Should see:
   ```
   Processing activity type: Follow from actor: ...
   Processed follow from ... to ...
   ```

4. **Verify Mastodon receives Accept**:
   - Check Mastodon logs for Accept activity
   - Verify follow appears as accepted in Mastodon

### Test 4: Follow from Solar Network to Mastodon

**Goal**: Solar Network user follows Mastodon user

You'll need to call the ActivityPub delivery service:

```bash
# Via API (you'll need to implement this endpoint):
curl -X POST http://solar.local:5000/api/activitypub/follow \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "targetActorUri": "http://mastodon.local:3001/users/testuser"
  }'
```

**Or test directly with curl** (simulating a Follow activity):

```bash
# Create a Follow activity
curl -X POST http://solar.local:5000/activitypub/actors/solaruser/inbox \
  -H "Content-Type: application/activity+json" \
  -d '{
    "@context": "https://www.w3.org/ns/activitystreams",
    "id": "http://mastodon.local:3001/test-follow-activity",
    "type": "Follow",
    "actor": "http://mastodon.local:3001/users/testuser",
    "object": "https://solar.local:5000/activitypub/actors/solaruser"
  }'
```

### Test 5: Create a Post in Solar Network

**Goal**: Post federates to Mastodon

1. **Create a post via Solar Network API**:
```bash
curl -X POST http://solar.local:5000/api/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "content": "Hello fediverse! Testing ActivityPub from Solar Network! 🚀",
    "visibility": 0,
    "publisherId": "PUBLISHER_ID"
  }'
```

2. **Wait a few seconds**

3. **Check in Mastodon**:
   - Go to http://mastodon.local:3001
   - The post should appear in the federated timeline
   - It should show `@solaruser@solar.local` as the author

4. **Verify Solar Network logs**:
   ```
   Successfully sent activity to http://mastodon.local:3001/inbox
   ```

### Test 6: Like from Mastodon

**Goal**: Mastodon user likes a Solar Network post

1. **In Mastodon**:
   - Find the Solar Network post
   - Click the favorite/like button

2. **Verify in Solar Network**:
```bash
psql -d dyson_network -c \
  "SELECT * FROM fediverse_reactions;"
```

3. **Check Solar Network logs**:
   ```
   Processing activity type: Like from actor: ...
   Processed like from ...
   ```

### Test 7: Reply from Mastodon

**Goal**: Reply federates to Solar Network

1. **In Mastodon**:
   - Reply to the Solar Network post
   - Write: "@solaruser Nice to meet you!"

2. **Verify in Solar Network**:
```bash
psql -d dyson_network -c \
  "SELECT * FROM fediverse_contents WHERE in_reply_to IS NOT NULL;"
```

## Part 5: Debugging and Troubleshooting

### Enable Detailed Logging

Edit `appsettings.json`:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Debug",
      "DysonNetwork.Sphere.ActivityPub": "Trace"
    }
  }
}
```

### Check Database State

```bash
# Check actors
psql -d dyson_network -c \
  "SELECT uri, username, display_name FROM fediverse_actors;"

# Check contents
psql -d dyson_network -c \
  "SELECT uri, type, content FROM fediverse_contents;"

# Check relationships
psql -d dyson_network -c \
  "SELECT * FROM fediverse_relationships;"

# Check activities
psql -d dyson_network -c \
  "SELECT type, status, error_message FROM fediverse_activities;"

# Check failed activities
psql -d dyson_network -c \
  "SELECT * FROM fediverse_activities WHERE status = 3;"  # 3 = Failed
```

### Common Issues

#### Issue: "Failed to verify signature"

**Cause**: HTTP Signature verification failed

**Solutions**:
1. Check the signature header format
2. Verify public key matches actor's keyId
3. Ensure Date header is within 5 minutes
4. Check host header matches request URL

#### Issue: "Target actor or inbox not found"

**Cause**: Remote actor not fetched yet

**Solutions**:
1. Manually fetch the actor first
2. Check actor URL is correct
3. Verify remote instance is accessible

#### Issue: "Content already exists"

**Cause**: Duplicate activity received

**Solutions**:
1. This is normal - deduplication is working
2. Check if content appears correctly

#### Issue: CORS errors when testing from browser

**Cause**: Browser blocking cross-origin requests

**Solutions**:
1. Use curl for API testing
2. Or disable CORS in development
3. Test directly from Mastodon interface

### View HTTP Signatures

For debugging, you can inspect the signature:

```bash
# From Mastodon to Solar Network
curl -v -X POST http://solar.local:5000/activitypub/actors/solaruser/inbox \
  -H "Content-Type: application/activity+json" \
  -d '{"type":"Follow",...}'
```

Look for the `Signature` header in the output.

### Test HTTP Signature Verification Manually

Create a test script `test-signature.js`:

```javascript
const crypto = require('crypto');

// Test signature verification
const publicKey = `-----BEGIN PUBLIC KEY-----
...
-----END PUBLIC KEY-----`;

const signingString = `(request-target): post /activitypub/actors/solaruser/inbox
host: solar.local:5000
date: ${new Date().toUTCString()}
content-length: ...`;

const signature = '...';

const verify = crypto.createVerify('SHA256');
verify.update(signingString);
const isValid = verify.verify(publicKey, signature, 'base64');

console.log('Signature valid:', isValid);
```

## Part 6: Test with a Real Instance

### Preparing for Public Federation

1. **Get a real domain** (e.g., via ngrok or a VPS)

```bash
# Using ngrok for testing
ngrok http 5000

# This gives you: https://random-id.ngrok-free.app
```

2. **Update Solar Network config**:

```json
{
  "ActivityPub": {
    "Domain": "your-domain.com",
    "EnableFederation": true
  }
}
```

3. **Update DNS** (if using real domain):
   - Add A record pointing to your server
   - Configure HTTPS (required for production federation)

4. **Test WebFinger with your domain**:

```bash
curl "https://your-domain.com/.well-known/webfinger?resource=acct:username@your-domain.com"
```

### Test with Mastodon.social

1. **Create a Mastodon.social account**
   - Go to https://mastodon.social
   - Sign up for a test account

2. **Search for your Solar Network user**:
   - In Mastodon.social search: `@username@your-domain.com`
   - Click follow

3. **Create a post in Solar Network**
   - Should appear in Mastodon.social

4. **Reply from Mastodon.social**
   - Should appear in Solar Network

### Test with Other Instances

- **Pleroma**: Similar to Mastodon, good for testing
- **Lemmy**: For testing community features (later)
- **Pixelfed**: For testing media posts
- **PeerTube**: For testing video content (later)

## Part 7: Verification Checklist

### Self-Hosted Instance Tests

- [ ] WebFinger returns correct actor links
- [ ] Actor profile has all required fields
- [ ] Follow from Mastodon to Solar Network works
- [ ] Follow from Solar Network to Mastodon works
- [ ] Accept activity sent back to Mastodon
- [ ] Posts from Solar Network appear in Mastodon timeline
- [ ] Posts from Mastodon appear in Solar Network database
- [ ] Likes from Mastodon appear in Solar Network
- [ ] Replies from Mastodon appear in Solar Network
- [ ] Keys are properly generated and stored
- [ ] HTTP signatures are correctly verified
- [ ] Outbox returns public posts

### Real Instance Tests

- [ ] Domain is publicly accessible
- [ ] HTTPS is working (or HTTP for local testing)
- [ ] WebFinger works with your domain
- [ ] Actor is discoverable from other instances
- [ ] Posts federate to public instances
- [ ] Users can follow across instances
- [ ] Timelines show federated content

## Part 8: Monitoring During Tests

### Check Solar Network Logs

```bash
# Follow logs in real-time
dotnet run --project DysonNetwork.Sphere | grep -i activitypub
```

### Check Mastodon Logs

```bash
docker-compose -f docker-compose.mastodon-test.yml logs -f web | grep -i federation
```

### Monitor Database Activity

```bash
# Watch activity table
watch -n 2 'psql -d dyson_network -c "SELECT type, status, created_at FROM fediverse_activities ORDER BY created_at DESC LIMIT 10;"'
```

### Check Network Traffic

```bash
# Monitor HTTP requests
tcpdump -i lo port 5000 or port 3001 -A
```

## Part 9: Advanced Testing

### Test HTTP Signature Fallbacks

Test with various signature headers:

```bash
# With Date header
curl -H "Date: $(date -u +%a,\ %d\ %b\ %Y\ %T\ GMT)" ...

# With Digest header
curl -H "Digest: SHA-256=$(echo -n '{}' | openssl dgst -sha256 -binary | base64)" ...

# Multiple signed headers
curl -H "Signature: keyId=\"...\",algorithm=\"rsa-sha256\",headers=\"(request-target) host date digest\",signature=\"...\"" ...
```

### Test Rate Limiting

Send multiple requests quickly:

```bash
for i in {1..10}; do
  curl -X POST http://solar.local:5000/activitypub/actors/solaruser/inbox \
    -H "Content-Type: application/activity+json" \
    -d '{"type":"Create",...}'
done
```

### Test Large Posts

Send post with attachments:

```bash
curl -X POST http://solar.local:5000/api/posts \
  -H "Content-Type: application/json" \
  -d '{
    "content": "A post with an image",
    "attachments": [{"id": "file-id"}],
    "visibility": 0
  }'
```

## Part 10: Cleanup

### Stop Test Instances

```bash
# Stop Mastodon
docker-compose -f docker-compose.mastodon-test.yml down

# Stop GoToSocial
docker-compose -f docker-compose.gotosocial.yml down

# Remove data volumes
docker-compose -f docker-compose.mastodon-test.yml down -v
```

### Reset Solar Network Database

```bash
# Warning: This deletes all data!
cd DysonNetwork.Sphere
dotnet ef database drop
dotnet ef database update
```

### Remove /etc/hosts Entries

```bash
sudo nano /etc/hosts

# Remove these lines:
# 127.0.0.1   mastodon.local
# 127.0.0.1   solar.local
# 127.0.0.1   gotosocial.local
```

## Next Steps After Testing

1. **Fix any issues found during testing**
2. **Add retry logic for failed deliveries**
3. **Implement activity queue for async processing**
4. **Add monitoring and metrics**
5. **Test with more instances (Pleroma, Pixelfed, etc.)**
6. **Add support for more activity types**
7. **Improve error handling and logging**
8. **Add admin interface for managing federation**

## Useful Tools

### ActivityPub Testing Tools
- [ActivityPub Playground](https://swicth.github.io/activity-pub-playground/)
- [FediTest](https://feditest.com/)
- [FediVerse.net](https://fedi.net/)

### HTTP Testing
- [curl](https://curl.se/)
- [httpie](https://httpie.io/)
- [Postman](https://www.postman.com/)

### JSON Inspection
- [jq](https://stedolan.github.io/jq/)
- [jsonpath.com](https://jsonpath.com/)

### Network Debugging
- [Wireshark](https://www.wireshark.org/)
- [tcpdump](https://www.tcpdump.org/)

## References

- [ActivityPub W3C Spec](https://www.w3.org/TR/activitypub/)
- [HTTP Signatures Draft](https://datatracker.ietf.org/doc/html/draft-cavage-http-signatures)
- [WebFinger RFC 7033](https://tools.ietf.org/html/rfc7033)
- [Mastodon Federation Documentation](https://docs.joinmastodon.org/admin/federation/)
