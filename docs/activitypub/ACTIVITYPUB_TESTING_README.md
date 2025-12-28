# ActivityPub Testing Guide

Complete guide for testing ActivityPub federation in Solar Network.

## 📚 Documentation Files

| File | Description | Size |
|------|-------------|-------|
| `ACTIVITYPUB_TESTING_INDEX.md` | **START HERE** - Master guide with overview | 12K |
| `ACTIVITYPUB_TESTING_QUICKSTART.md` | Quick reference for common tasks | 7K |
| `ACTIVITYPUB_TESTING_GUIDE.md` | Comprehensive testing scenarios (10 parts) | 19K |
| `ACTIVITYPUB_TESTING_QUICKREF.md` | Command and query reference | 8K |
| `ACTIVITYPUB_TESTING_HELPER_API.md` | Helper API for programmatic testing | 12K |
| `ACTIVITYPUB_TESTING_RESULTS_TEMPLATE.md` | Template to track test results | 10K |

## 🚀 Quick Start

### Option A: One-Command Setup (Recommended)

```bash
# 1. Run setup script
./setup-activitypub-test.sh

# 2. Run validation
./test-activitypub.sh

# 3. Start Solar Network
cd DysonNetwork.Sphere
dotnet run
```

### Option B: Manual Setup

1. **Read**: `ACTIVITYPUB_TESTING_QUICKSTART.md`
2. **Configure**: Copy `.env.testing.example` to `.env` and adjust
3. **Follow**: Step-by-step in `ACTIVITYPUB_TESTING_GUIDE.md`

## 🎯 What You Can Test

### With Self-Hosted Instance
- ✅ WebFinger discovery
- ✅ Actor profile retrieval
- ✅ Follow relationships (bidirectional)
- ✅ Post federation (Solar → Mastodon)
- ✅ Content reception (Mastodon → Solar)
- ✅ Like interactions
- ✅ Reply threading
- ✅ HTTP signature verification
- ✅ Content deletion

### With Real Instance
- ✅ Public domain setup (via ngrok or VPS)
- ✅ Federation with public instances (mastodon.social, etc.)
- ✅ Real-world compatibility testing
- ✅ Performance under real load

## 📋 Testing Workflow

### Day 1: Basic Functionality
- Setup test environment
- Test WebFinger and Actor endpoints
- Verify HTTP signatures
- Test basic follow/unfollow

### Day 2: Content Federation
- Test post creation and delivery
- Test content reception
- Test media attachments
- Test content warnings

### Day 3: Interactions
- Test likes (both directions)
- Test replies and threading
- Test boosts/announces
- Test undo activities

### Day 4: Real Instance
- Set up public domain
- Test with mastodon.social
- Test with other instances
- Verify cross-instance compatibility

### Day 5: Edge Cases
- Test error handling
- Test failed deliveries
- Test invalid signatures
- Test malformed activities

## 🛠️ Setup Scripts

| Script | Purpose |
|--------|---------|
| `setup-activitypub-test.sh` | One-command setup of Mastodon + Solar Network |
| `test-activitypub.sh` | Quick validation of core functionality |

Both scripts are executable (`chmod +x`).

## 🔧 Configuration

### Required Tools
- ✅ Docker (for Mastodon)
- ✅ .NET 10 SDK (for Solar Network)
- ✅ PostgreSQL client (psql)
- ✅ curl (for API testing)

### Quick Setup
```bash
# 1. Install dependencies (Ubuntu/Debian)
sudo apt-get install docker.io docker-compose postgresql-client curl jq

# 2. Run setup
./setup-activitypub-test.sh

# 3. Validate
./test-activitypub.sh
```

## 📊 Progress Tracking

Use the template to track your testing progress:

```bash
# Copy the template
cp ACTIVITYPUB_TESTING_RESULTS_TEMPLATE.md my-test-results.md

# Edit as you test
nano my-test-results.md
```

## 🐛 Troubleshooting

### Quick Fixes

**Mastodon won't start**:
```bash
# Check logs
docker compose -f docker-compose.mastodon-test.yml logs -f

# Restart containers
docker compose -f docker-compose.mastodon-test.yml restart
```

**Can't reach Solar Network**:
```bash
# Check if running
curl http://solar.local:5000

# Check /etc/hosts
cat /etc/hosts | grep solar.local
```

**Activities not arriving**:
```bash
# Check database
psql -d dyson_network -c "SELECT * FROM fediverse_activities;"

# Check logs
dotnet run --project DysonNetwork.Sphere | grep -i activitypub
```

For detailed troubleshooting, see `ACTIVITYPUB_TESTING_GUIDE.md` Part 5.

## 📖 Learning Path

### For Developers
1. Read `ACTIVITYPUB_IMPLEMENTATION.md` to understand the architecture
2. Read `ACTIVITYPUB_SUMMARY.md` to see what's implemented
3. Follow test scenarios in `ACTIVITYPUB_TESTING_GUIDE.md`
4. Use helper API in `ACTIVITYPUB_TESTING_HELPER_API.md` for testing

### For Testers
1. Start with `ACTIVITYPUB_TESTING_QUICKSTART.md`
2. Use command reference in `ACTIVITYPUB_TESTING_QUICKREF.md`
3. Track results with `ACTIVITYPUB_TESTING_RESULTS_TEMPLATE.md`
4. Report issues with details from logs

## 🎓 Success Criteria

### Minimum Viable
- WebFinger works
- Actor profile valid
- Follow relationships work
- Posts federate correctly
- HTTP signatures verified

### Production Ready
- Activity queue with retry
- Rate limiting
- Monitoring/alerting
- Admin interface
- Instance blocking
- Content moderation

## 🚨 Common Pitfalls

### Don't Forget
- ✅ Update `/etc/hosts` with both instances
- ✅ Run migrations before testing
- ✅ Check both instances are accessible
- ✅ Verify PostgreSQL is running
- ✅ Check logs when something fails

### Watch Out For
- ❌ Using `localhost` instead of `solar.local`
- ❌ Forgetting to restart after config changes
- ❌ Not waiting for Mastodon to start (2-5 minutes)
- ❌ Ignoring CORS errors in browser testing
- ❌ Testing with deleted/invisible posts

## 📚 Additional Resources

### Official Specs
- [ActivityPub W3C](https://www.w3.org/TR/activitypub/)
- [ActivityStreams](https://www.w3.org/TR/activitystreams-core/)
- [HTTP Signatures](https://datatracker.ietf.org/doc/html/draft-cavage-http-signatures)

### Community Guides
- [Mastodon Federation](https://docs.joinmastodon.org/admin/federation/)
- [Federation Testing](https://docs.joinmastodon.org/spec/activitypub/)

### Tools
- [ActivityPub Playground](https://swicth.github.io/activity-pub-playground/)
- [FediTest](https://feditest.com/)

## 🆘 Support

If you encounter issues:

1. Check logs (both Solar Network and Mastodon)
2. Review troubleshooting section in the guide
3. Validate against success criteria
4. Check database state with queries
5. Review implementation docs

## ✨ Next Steps

After testing with self-hosted instance:

1. Get a public domain or use ngrok
2. Update `ActivityPub:Domain` in appsettings.json
3. Test with public Mastodon instances
4. Add more ActivityPub features (queue, retry, etc.)
5. Implement admin interface
6. Add monitoring and metrics

## 📞 File Reference

All files are in the root of the DysonNetwork project:

```
DysonNetwork/
├── ACTIVITYPUB_TESTING_INDEX.md          # Start here!
├── ACTIVITYPUB_TESTING_QUICKSTART.md     # Quick reference
├── ACTIVITYPUB_TESTING_GUIDE.md        # Full guide
├── ACTIVITYPUB_TESTING_QUICKREF.md      # Commands
├── ACTIVITYPUB_TESTING_HELPER_API.md    # Test API
├── ACTIVITYPUB_TESTING_RESULTS_TEMPLATE.md
├── setup-activitypub-test.sh            # Setup script
├── test-activitypub.sh                  # Test script
└── .env.testing.example                 # Config template
```

**Documentation files** (for reference):
```
DysonNetwork/
├── ACTIVITYPUB_IMPLEMENTATION.md         # How it's implemented
├── ACTIVITYPUB_SUMMARY.md                # Feature summary
└── ACTIVITYPUB_PLAN.md                   # Original plan
```

---

**Start here**: `ACTIVITYPUB_TESTING_INDEX.md`

**Good luck with your testing!** 🚀
