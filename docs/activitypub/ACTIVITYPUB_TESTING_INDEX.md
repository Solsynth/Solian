# ActivityPub Testing - Complete Guide

This is the complete guide for testing ActivityPub federation in Solar Network.

## 📁 File Overview

| File | Purpose | When to Use |
|------|---------|--------------|
| `setup-activitypub-test.sh` | One-command setup of test environment | First time setup |
| `test-activitypub.sh` | Quick validation of basic functionality | After setup, before detailed tests |
| `ACTIVITYPUB_TESTING_QUICKSTART.md` | Quick start reference | Getting started quickly |
| `ACTIVITYPUB_TESTING_GUIDE.md` | Comprehensive testing scenarios | Full testing workflow |
| `ACTIVITYPUB_TESTING_QUICKREF.md` | Command and query reference | Daily testing |
| `ACTIVITYPUB_TESTING_HELPER_API.md` | Helper API for testing | Programmatic testing |
| `ACTIVITYPUB_TEST_RESULTS_TEMPLATE.md` | Track test results | During testing |
| `ACTIVITYPUB_IMPLEMENTATION.md` | Implementation details | Understanding the code |
| `ACTIVITYPUB_SUMMARY.md` | Feature summary | Reviewing what's implemented |

## 🚀 Quick Start (5 Minutes)

### 1. Setup Test Environment

```bash
./setup-activitypub-test.sh
```

This will:
- ✅ Configure `/etc/hosts`
- ✅ Start Mastodon via Docker
- ✅ Create test Mastodon account
- ✅ Apply database migrations

### 2. Validate Setup

```bash
./test-activitypub.sh
```

This checks:
- ✅ WebFinger endpoint
- ✅ Actor profile
- ✅ Public keys
- ✅ Database tables

### 3. Start Solar Network

```bash
cd DysonNetwork.Sphere
dotnet run
```

### 4. Test Federation

1. Open http://mastodon.local:3001
2. Search for `@solaruser@solar.local`
3. Click Follow
4. Create a post in Solar Network
5. Verify it appears in Mastodon

## 📖 Recommended Reading Order

### For First-Time Testing

1. **Start Here**: `ACTIVITYPUB_TESTING_QUICKSTART.md`
   - Overview of the setup
   - Quick command reference
   - Common commands

2. **Then**: `ACTIVITYPUB_TESTING_GUIDE.md`
   - Detailed test scenarios
   - Step-by-step instructions
   - Troubleshooting

3. **Reference**: `ACTIVITYPUB_TESTING_QUICKREF.md`
   - Command snippets
   - Database queries
   - Response codes

### During Testing

1. **Track Progress**: `ACTIVITYPUB_TEST_RESULTS_TEMPLATE.md`
   - Checklists for each test
   - Results tracking
   - Issue logging

2. **Helper API**: `ACTIVITYPUB_TESTING_HELPER_API.md`
   - Manual testing endpoints
   - Debugging tools
   - Status monitoring

### For Understanding

1. **Implementation**: `ACTIVITYPUB_IMPLEMENTATION.md`
   - Architecture details
   - Service descriptions
   - Data flow diagrams

2. **Features**: `ACTIVITYPUB_SUMMARY.md`
   - What's implemented
   - Model relationships
   - API endpoints

## 🔍 Test Scenarios Summary

### Basic Functionality (All instances must pass)

- [ ] WebFinger discovery works
- [ ] Actor profile is valid JSON-LD
- [ ] Public key is present
- [ ] Outbox returns public posts
- [ ] Inbox accepts activities

### Federation - Follow

- [ ] Remote user can follow local user
- [ ] Local user can follow remote user
- [ ] Accept activity is sent/received
- [ ] Relationship state is correct
- [ ] Unfollow works correctly

### Federation - Content

- [ ] Local posts federate to remote instances
- [ ] Remote posts appear in local database
- [ ] Post content is preserved
- [ ] Timestamps are correct
- [ ] Attachments are handled
- [ ] Content warnings are respected

### Federation - Interactions

- [ ] Likes federate correctly
- [ ] Likes appear in both instances
- [ ] Replies federate correctly
- [ ] Reply threading works
- [ ] Boosts/Announces work
- [ ] Undo activities work

### Security

- [ ] HTTP signatures are verified
- [ ] Invalid signatures are rejected
- [ ] Keys are properly stored
- [ ] Private keys never exposed

## 🐛 Common Issues & Solutions

### Issue: "Failed to verify signature"

**Causes**:
1. Signature header format is wrong
2. Public key doesn't match keyId
3. Date header is too old (>5 minutes)
4. Request body doesn't match digest

**Solutions**:
1. Check signature format: `keyId="...",algorithm="...",headers="...",signature="..."`
2. Verify keyId in actor profile
3. Ensure Date header is recent
4. Check body is exactly what was signed

### Issue: "Target actor or inbox not found"

**Causes**:
1. Actor hasn't been fetched yet
2. Actor URL is incorrect
3. Remote instance is inaccessible

**Solutions**:
1. Manually fetch actor first
2. Verify actor URL is correct
3. Test accessibility with curl

### Issue: Activities not arriving

**Causes**:
1. Network connectivity issue
2. Remote instance is down
3. Activity wasn't queued properly

**Solutions**:
1. Check network connectivity
2. Verify remote instance is running
3. Check fediverse_activities table for status

## 📊 Monitoring During Tests

### Check Logs

```bash
# Solar Network ActivityPub logs
dotnet run --project DysonNetwork.Sphere 2>&1 | grep -i activitypub

# Mastodon federation logs
docker compose -f docker-compose.mastodon-test.yml logs -f web | grep -i federation
```

### Monitor Database

```bash
# Watch activity table
watch -n 2 'psql -d dyson_network -c \
  "SELECT type, status, created_at FROM fediverse_activities ORDER BY created_at DESC LIMIT 5;"'
```

### Test Network

```bash
# Test connectivity between instances
curl -v http://mastodon.local:3001
curl -v http://solar.local:5000

# Test with traceroute (if available)
traceroute mastodon.local
traceroute solar.local
```

## 🎯 Success Criteria

### Minimal Viable Federation

To consider ActivityPub implementation "working", all of these must pass:

- ✅ WebFinger returns actor links
- ✅ Actor profile has all required fields
- ✅ Follow relationships work bidirectionally
- ✅ Public posts federate to followers
- ✅ Incoming posts are stored correctly
- ✅ HTTP signatures are verified
- ✅ Basic interaction types work (Like, Reply)

### Full Production Ready

For production, also need:

- ✅ Activity queue with retry logic
- ✅ Rate limiting on outgoing deliveries
- ✅ Monitoring and alerting
- ✅ Admin interface for federation management
- ✅ Content filtering and moderation
- ✅ Instance blocking capabilities
- ✅ Performance optimization for high volume

## 🔐 Security Checklist

During testing, verify:

- [ ] Private keys are never logged
- [ ] Private keys are never returned in API responses
- [ ] Only public keys are in actor profiles
- [ ] All incoming activities are signature-verified
- [ ] Invalid signatures are rejected with 401
- [ ] TLS is used in production
- [ ] Host header is verified against request URL

## 📈 Performance Metrics

Track these during testing:

| Metric | Target | Actual |
|--------|--------|--------|
| WebFinger response time | <500ms | ___ ms |
| Actor fetch time | <1s | ___ ms |
| Signature verification time | <100ms | ___ ms |
| Activity processing time | <500ms | ___ ms |
| Outgoing delivery success rate | >95% | ___% |
| Outgoing delivery time | <5s | ___ ms |

## 🧪 Testing Checklist

### Self-Hosted Instance Tests

**Setup**:
- [ ] Setup script completed
- [ ] Mast containers running
- [ ] Solar Network running
- [ ] /etc/hosts configured
- [ ] Database migrations applied

**Basic Federation**:
- [ ] WebFinger works
- [ ] Actor profile valid
- [ ] Public key present
- [ ] Outbox accessible

**Follow Flow**:
- [ ] Mastodon → Solar follow works
- [ ] Solar → Mastodon follow works
- [ ] Accept activity sent
- [ ] Relationship state correct

**Content Flow**:
- [ ] Solar posts appear in Mastodon
- [ ] Mastodon posts appear in Solar
- [ ] Content preserved correctly
- [ ] Timestamps correct

**Interactions**:
- [ ] Likes work both ways
- [ ] Replies work both ways
- [ ] Boosts work both ways
- [ ] Undo works

**Security**:
- [ ] HTTP signatures verified
- [ ] Invalid signatures rejected
- [ ] Keys properly managed

### Real Instance Tests

**Discovery**:
- [ ] Domain publicly accessible
- [ ] WebFinger works from public internet
- [ ] Actor discoverable from public instances

**Federation**:
- [ ] Posts federate to public instances
- [ ] Follows work with public instances
- [ ] Interactions work with public instances

## 📝 Testing Notes

### What Worked Well
1. _____________________
2. _____________________
3. _____________________

### What Needs Improvement
1. _____________________
2. _____________________
3. _____________________

### Bugs Found
| # | Description | Severity | Status |
|---|-------------|----------|--------|
| 1 | _____________________ | Low/Medium/High | ☐ Open/☐ Fixed |
| 2 | _____________________ | Low/Medium/High | ☐ Open/☐ Fixed |
| 3 | _____________________ | Low/Medium/High | ☐ Open/☐ Fixed |

## 🎓 Learning Resources

### ActivityPub Specification
- [W3C ActivityPub Recommendation](https://www.w3.org/TR/activitypub/)
- [ActivityStreams 2.0](https://www.w3.org/TR/activitystreams-core/)
- [HTTP Signatures Draft](https://datatracker.ietf.org/doc/html/draft-cavage-http-signatures)

### Implementation Guides
- [Mastodon Federation Guide](https://docs.joinmastodon.org/admin/federation/)
- [ActivityPub Testing Best Practices](https://blog.joinmastodon.org/2018/06/27/how-to-implement-a-basic-activitypub-server/)
- [Federation Testing Checklist](https://docs.joinmastodon.org/spec/activitypub/)

### Tools
- [ActivityPub Playground](https://swicth.github.io/activity-pub-playground/)
- [FediTest](https://feditest.com/)
- [JSONPath Online Evaluator](https://jsonpath.com/)

## 🔄 Next Steps After Testing

### Phase 1: Fix Issues
- Address all bugs found during testing
- Improve error messages
- Add better logging

### Phase 2: Enhance Features
- Implement activity queue
- Add retry logic
- Add rate limiting
- Implement instance blocking

### Phase 3: Production Readiness
- Add monitoring and metrics
- Add admin interface
- Add content filtering
- Implement moderation tools

### Phase 4: Additional Features
- Support more activity types
- Support media attachments
- Support polls
- Support custom emojis

## 📞 Getting Help

If you encounter issues:

1. **Check logs**: See the logs section above
2. **Review troubleshooting**: See `ACTIVITYPUB_TESTING_GUIDE.md` Part 5
3. **Check database queries**: Use queries from `ACTIVITYPUB_TESTING_QUICKREF.md`
4. **Validate signatures**: Use helper API in `ACTIVITYPUB_TESTING_HELPER_API.md`

## ✨ Quick Test Commands

### All-in-One Test Sequence

```bash
# 1. Setup
./setup-activitypub-test.sh

# 2. Validate
./test-activitypub.sh

# 3. Test WebFinger
curl "http://solar.local:5000/.well-known/webfinger?resource=acct:solaruser@solar.local"

# 4. Test Actor
curl -H "Accept: application/activity+json" \
  http://solar.local:5000/activitypub/actors/solaruser

# 5. Test Follow (from Mastodon UI)
# Open http://mastodon.local:3001 and follow @solaruser@solar.local

# 6. Check database
psql -d dyson_network -c "SELECT * FROM fediverse_relationships;"

# 7. Test Post (create in Solar Network UI)
# Should appear in http://mastodon.local:3001

# 8. Verify content
psql -d dyson_network -c "SELECT * FROM fediverse_contents;"

# 9. Test Like (like from Mastodon UI)
# Should appear in fediverse_reactions table

# 10. Check activities
psql -d dyson_network -c "SELECT type, status FROM fediverse_activities;"
```

## 🎉 Conclusion

You now have everything needed to test ActivityPub federation for Solar Network:

- ✅ Self-hosted test environment (Mastodon)
- ✅ Setup automation (setup script)
- ✅ Quick validation (test script)
- ✅ Comprehensive testing guide
- ✅ Helper API for programmatic testing
- ✅ Quick reference for daily use
- ✅ Results template for tracking progress

**Recommended workflow**:
1. Run `setup-activitypub-test.sh`
2. Run `test-activitypub.sh` for validation
3. Follow scenarios in `ACTIVITYPUB_TESTING_GUIDE.md`
4. Use `ACTIVITYPUB_TESTING_HELPER_API.md` for specific tests
5. Track results in `ACTIVITYPUB_TEST_RESULTS_TEMPLATE.md`
6. Reference `ACTIVITYPUB_TESTING_QUICKREF.md` for commands

Good luck with your federation testing! 🚀
