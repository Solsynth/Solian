# ActivityPub Implementation Summary

## What Has Been Implemented

### 1. Database Models ✅
All models located in `DysonNetwork.Shared/Models/`:

| Model | Purpose | Key Features |
|--------|---------|--------------|
| `SnFediverseInstance` | Track fediverse servers | Domain blocking, metadata, activity tracking |
| `SnFediverseActor` | Remote user profiles | Keys, inbox/outbox URLs, relationships |
| `SnFediverseContent` | Federated posts/notes | Multiple content types, attachments, mentions, tags |
| `SnFediverseActivity` | Activity tracking | All activity types, processing status, raw data |
| `SnFediverseRelationship` | Follow relationships | State machine, muting/blocking |
| `SnFediverseReaction` | Federated reactions | Likes, emoji reactions |

### 2. Database Migrations ✅
- `20251228120000_AddActivityPubModels.cs` - Core ActivityPub tables
- `20251228130000_AddPublisherMetaForActivityPubKeys.cs` - Publisher metadata for keys

### 3. Core Services ✅

#### ActivityPubKeyService
- **Location**: `DysonNetwork.Sphere/ActivityPub/ActivityPubKeyService.cs`
- **Responsibilities**:
  - Generate RSA 2048-bit key pairs
  - Sign data with private key
  - Verify signatures with public key
- **Key Storage**: Keys stored in `SnPublisher.Meta`

#### ActivityPubSignatureService
- **Location**: `DysonNetwork.Sphere/ActivityPub/ActivityPubSignatureService.cs`
- **Responsibilities**:
  - Verify incoming HTTP Signature headers
  - Sign outgoing HTTP requests
  - Build signing strings per ActivityPub spec
  - Manage key retrieval for actors
- **Signature Algorithm**: RSA-SHA256

#### ActivityPubActivityProcessor
- **Location**: `DysonNetwork.Sphere/ActivityPub/ActivityPubActivityProcessor.cs`
- **Supported Activities**:
  - ✅ Follow - Creates relationship, sends Accept
  - ✅ Accept - Updates relationship to accepted
  - ✅ Reject - Updates relationship to rejected
  - ✅ Create - Stores federated content
  - ✅ Like - Records like reaction
  - ✅ Announce - Increments boost count
  - ✅ Undo - Reverts previous actions
  - ✅ Delete - Soft-deletes federated content
  - ✅ Update - Marks content as edited

#### ActivityPubDeliveryService
- **Location**: `DysonNetwork.Sphere/ActivityPub/ActivityPubDeliveryService.cs`
- **Outgoing Activities**:
  - ✅ Follow - Send to remote actors
  - ✅ Accept - Respond to follow requests
  - ✅ Create - Send new posts to followers
  - ✅ Like - Send to remote instances
  - ✅ Undo - Undo previous actions
- **Features**:
  - HTTP signature signing
  - Remote actor fetching
  - Follower discovery

### 4. API Controllers ✅

#### WebFingerController
- **Location**: `DysonNetwork.Sphere/ActivityPub/WebFingerController.cs`
- **Endpoints**:
  - `GET /.well-known/webfinger?resource=acct:<username>@<domain>`
- **Purpose**: Allow remote instances to discover local actors

#### ActivityPubController
- **Location**: `DysonNetwork.Sphere/ActivityPub/ActivityPubController.cs`
- **Endpoints**:
  - `GET /activitypub/actors/{username}` - Actor profile in JSON-LD
  - `GET /activitypub/actors/{username}/outbox` - Public posts
  - `POST /activitypub/actors/{username}/inbox` - Receive activities
- **Features**:
  - Public key in actor profile
  - ActivityPub JSON-LD responses
  - HTTP signature verification on inbox
  - Activity processing pipeline

### 5. Model Updates ✅
- Added `Meta` field to `SnPublisher` for storing ActivityPub keys
- All models follow existing Solar Network patterns

## How It Works

### Incoming Activity Flow
```
1. Remote server sends POST to /inbox
2. HTTP Signature is verified
3. Activity type is identified
4. Specific handler processes activity:
   - Follow: Create relationship, send Accept
   - Create: Store content
   - Like: Record reaction
   - etc.
5. Database is updated
6. Response sent
```

### Outgoing Activity Flow
```
1. Local action occurs (post, like, follow)
2. Activity is created in ActivityPub format
3. Remote followers are discovered
4. HTTP request is signed with publisher's private key
5. Activity sent to each follower's inbox
6. Status logged
```

### Key Management
```
1. Publisher creates post/follows
2. Check if keys exist in Publisher.Meta
3. If not, generate RSA 2048-bit key pair
4. Store keys in Publisher.Meta
5. Use keys for signing
```

## Configuration

Add to `appsettings.json`:
```json
{
  "ActivityPub": {
    "Domain": "your-domain.com",
    "EnableFederation": true
  }
}
```

## API Endpoints

### WebFinger
```bash
GET /.well-known/webfinger?resource=acct:username@domain.com
Accept: application/jrd+json
```

### Actor Profile
```bash
GET /activitypub/actors/username
Accept: application/activity+json
```

### Outbox
```bash
GET /activitypub/actors/username/outbox
Accept: application/activity+json
```

### Inbox
```bash
POST /activitypub/actors/username/inbox
Content-Type: application/activity+json
Signature: keyId="...",algorithm="...",headers="...",signature="..."
```

## Database Schema

### Fediverse Tables
- `fediverse_instances` - Server metadata and blocking
- `fediverse_actors` - Remote actor profiles
- `fediverse_contents` - Federated posts/notes
- `fediverse_activities` - Activity tracking
- `fediverse_relationships` - Follow relationships
- `fediverse_reactions` - Federated reactions

### Publisher Enhancement
- Added `publishers.meta` JSONB column for key storage

## Next Steps

### Immediate (Ready for Testing)
- Apply database migrations
- Test WebFinger with a Mastodon instance
- Test follow/unfollow with another instance
- Test receiving posts from federated timeline

### Short Term
- Add HTTP Signature verification middleware
- Implement activity queue with retry logic
- Add background worker for processing queued activities
- Add metrics and monitoring
- Implement local content display in timelines

### Long Term
- Add Media support for federated content
- Implement content filtering
- Add moderation tools for federated content
- Support more activity types
- Implement instance block list management

## Compatibility

The implementation follows:
- ✅ [ActivityPub W3C Recommendation](https://www.w3.org/TR/activitypub/)
- ✅ [ActivityStreams 2.0](https://www.w3.org/TR/activitystreams-core/)
- ✅ [WebFinger RFC 7033](https://tools.ietf.org/html/rfc7033)
- ✅ [HTTP Signatures](https://datatracker.ietf.org/doc/html/draft-cavage-http-signatures)

## Testing

### Local Testing
```bash
# 1. Apply migrations
cd DysonNetwork.Sphere
dotnet ef database update

# 2. Test WebFinger
curl "http://localhost:5000/.well-known/webfinger?resource=acct:username@localhost"

# 3. Test Actor
curl -H "Accept: application/activity+json" http://localhost:5000/activitypub/actors/username
```

### Federation Testing
1. Set up a Mastodon instance (or use a public one)
2. Follow a Mastodon user from Solar Network
3. Create a post on Solar Network
4. Verify it appears on Mastodon timeline

## Architecture Decisions

1. **Key Storage**: Using `SnPublisher.Meta` JSONB field for flexibility
2. **Content Storage**: Federated content stored separately from local posts
3. **Relationship State**: Implemented with explicit states (Pending, Accepted, Rejected)
4. **Signature Algorithm**: RSA-SHA256 for compatibility
5. **Activity Processing**: Synchronous for now, can be made async with queue
6. **Content Types**: Support for Note, Article initially (can expand)

## Notes

- All ActivityPub communication uses HTTP Signatures
- Private keys never leave the server
- Public keys are published in actor profiles
- Soft delete is enabled on all federated models
- Failed activity deliveries are logged but not retried (future enhancement)
- Content is federated only when visibility is Public

## Files Created/Modified

### New Files
- `DysonNetwork.Shared/Models/FediverseInstance.cs`
- `DysonNetwork.Shared/Models/FediverseActor.cs`
- `DysonNetwork.Shared/Models/FediverseContent.cs`
- `DysonNetwork.Shared/Models/FediverseActivity.cs`
- `DysonNetwork.Shared/Models/FediverseRelationship.cs`
- `DysonNetwork.Shared/Models/FediverseReaction.cs`
- `DysonNetwork.Sphere/ActivityPub/WebFingerController.cs`
- `DysonNetwork.Sphere/ActivityPub/ActivityPubController.cs`
- `DysonNetwork.Sphere/ActivityPub/ActivityPubKeyService.cs`
- `DysonNetwork.Sphere/ActivityPub/ActivityPubSignatureService.cs`
- `DysonNetwork.Sphere/ActivityPub/ActivityPubActivityProcessor.cs`
- `DysonNetwork.Sphere/ActivityPub/ActivityPubDeliveryService.cs`
- `DysonNetwork.Sphere/Migrations/20251228120000_AddActivityPubModels.cs`
- `DysonNetwork.Sphere/Migrations/20251228130000_AddPublisherMetaForActivityPubKeys.cs`

### Modified Files
- `DysonNetwork.Shared/Models/Publisher.cs` - Added Meta field
- `DysonNetwork.Sphere/AppDatabase.cs` - Added DbSets for ActivityPub
- `DysonNetwork.Sphere/Startup/ServiceCollectionExtensions.cs` - Registered ActivityPub services

## References

- [ActivityPub Implementation Guide](./ACTIVITYPUB_IMPLEMENTATION.md)
- [ActivityPub Plan](./ACTIVITYPUB_PLAN.md)
- [Solar Network Architecture](./README.md)
