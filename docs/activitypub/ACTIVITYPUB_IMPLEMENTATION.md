# ActivityPub Implementation for Solar Network

## Overview

This document outlines the initial implementation of ActivityPub federation for the Solar Network (DysonNetwork), following the plan outlined in `ACTIVITYPUB_PLAN.md`.

## What Has Been Created

### 1. Database Models (DysonNetwork.Shared/Models)

All ActivityPub-related models are shared across projects and located in `DysonNetwork.Shared/Models/`:

#### FediverseInstance.cs
- Tracks ActivityPub instances (servers) in the fediverse
- Stores instance metadata, blocking status, and activity tracking
- Links to actors and content from that instance

#### FediverseActor.cs
- Represents remote actors (users/accounts) from other instances
- Stores actor information including keys, inbox/outbox URLs
- Links to instance and manages relationships
- Tracks whether the actor is a bot, locked, or discoverable

#### FediverseContent.cs
- Stores content (posts, notes, etc.) received from the fediverse
- Supports multiple content types (Note, Article, Image, Video, etc.)
- Includes attachments, mentions, tags, and emojis
- Links to local posts for unified display

#### FediverseActivity.cs
- Tracks ActivityPub activities (Create, Follow, Like, Announce, etc.)
- Stores raw activity data and processing status
- Links to actors, content, and local entities
- Supports both incoming and outgoing activities

#### FediverseRelationship.cs
- Manages follow relationships between local and remote actors
- Tracks relationship state (Pending, Accepted, Rejected)
- Supports muting and blocking
- Links to local accounts/publishers

#### FediverseReaction.cs
- Stores reactions (likes, emoji) from both local and remote actors
- Links to content and actor
- Supports federation of reactions

### 2. Database Migration

**File**: `DysonNetwork.Sphere/Migrations/20251228120000_AddActivityPubModels.cs`

This migration creates the following tables:
- `fediverse_instances` - Instance tracking
- `fediverse_actors` - Remote actor profiles
- `fediverse_contents` - Federated content storage
- `fediverse_activities` - Activity tracking and processing
- `fediverse_relationships` - Follow relationships
- `fediverse_reactions` - Reactions from fediverse

### 3. API Controllers (DysonNetwork.Sphere/ActivityPub)

#### WebFingerController.cs
- **Endpoint**: `GET /.well-known/webfinger?resource=acct:<username>@<domain>`
- **Purpose**: Allows other instances to discover actors via WebFinger protocol
- **Response**: Returns actor's inbox/outbox URLs and profile page links
- Maps local Publishers to ActivityPub actors

#### ActivityPubController.cs
Provides three main endpoints:

1. **GET /activitypub/actors/{username}**
   - Returns ActivityPub actor profile in JSON-LD format
   - Includes actor's keys, inbox, outbox, followers, and following URLs
   - Maps SnPublisher to ActivityPub Person type

2. **GET /activitypub/actors/{username}/outbox**
   - Returns actor's outbox collection
   - Lists public posts as ActivityPub activities
   - Supports pagination

3. **POST /activitypub/actors/{username}/inbox**
   - Receives incoming ActivityPub activities
   - Supports Create, Follow, Like, Announce activities
   - Placeholder for activity processing logic

## Architecture

### Data Flow

```
Remote Instance           Solar Network (Sphere)
    │                          │
    │  ───WebFinger─────>    │
    │                          │
    │  <───Actor JSON────       │
    │                          │
    │  ───Activity─────>      │  → Inbox Processing
    │                          │
    │  <───Activity──────       │  ← Outbox Distribution
```

### Model Relationships

- `SnFediverseInstance` has many `SnFediverseActor`
- `SnFediverseInstance` has many `SnFediverseContent`
- `SnFediverseActor` has many `SnFediverseContent`
- `SnFediverseActor` has many `SnFediverseActivity`
- `SnFediverseActor` has many `SnFediverseRelationship` (as follower and following)
- `SnFediverseContent` has many `SnFediverseActivity`
- `SnFediverseContent` has many `SnFediverseReaction`
- `SnFediverseContent` optionally links to `SnPost` (local copy)

### Local to Fediverse Mapping

| Solar Network Model | ActivityPub Type |
|-------------------|-----------------|
| SnPublisher | Person (Actor) |
| SnPost | Note / Article |
| SnPostReaction | Like / EmojiReact |
| Follow | Follow Activity |
| SnPublisherSubscription | Follow Relationship |

## Next Steps

### Stage 1: Core Infrastructure ✅ (COMPLETED)
- ✅ Create database models for ActivityPub entities
- ✅ Create database migration
- ✅ Implement basic WebFinger endpoint
- ✅ Implement basic Actor endpoint
- ✅ Implement Inbox/Outbox endpoints

### Stage 2: Activity Processing ✅ (COMPLETED)
- ✅ Implement HTTP Signature verification (ActivityPubSignatureService)
- ✅ Process incoming activities:
  - Follow/Accept/Reject
  - Create (incoming posts)
  - Like/Announce
  - Delete/Update
  - Undo
- ✅ Generate outgoing activities (ActivityPubDeliveryService)
- ✅ Queue and retry failed deliveries (basic implementation)

### Stage 3: Key Management ✅ (COMPLETED)
- ✅ Generate RSA key pairs for each Publisher (ActivityPubKeyService)
- ✅ Store public/private keys in Publisher.Meta
- ✅ Sign outgoing HTTP requests
- ✅ Verify incoming HTTP signatures

### Stage 4: Content Federation (IN PROGRESS)
- ✅ Convert between SnPost and ActivityPub Note/Article (basic mapping)
- ✅ Handle content attachments and media
- ✅ Support content warnings and sensitive content
- ✅ Handle replies, boosts, and mentions
- ⏳ Add local post reference for federated content
- ⏳ Handle media attachments in federated content

### Stage 5: Relationship Management ✅ (COMPLETED)
- ✅ Handle follow/unfollow logic
- ✅ Update followers/following collections
- ✅ Block/mute functionality (data model ready)
- ✅ Relationship state machine (Pending, Accepted, Rejected)

### Stage 6: Testing & Interop (NEXT)
- ⏳ Test with Mastodon instances
- ⏳ Test with Pleroma/Akkoma instances
- ⏳ Test with Lemmy instances
- ⏳ Verify WebFinger and actor discovery
- ⏳ Test activity delivery and processing

## Implementation Details

### Core Services

#### 1. ActivityPubKeyService
- Generates RSA 2048-bit key pairs for ActivityPub
- Signs data with private key
- Verifies signatures with public key
- Key stored in `SnPublisher.Meta["private_key"]` and `["public_key"]`

#### 2. ActivityPubSignatureService
- Verifies incoming HTTP Signature headers
- Signs outgoing HTTP requests
- Manages key retrieval and storage
- Builds signing strings according to ActivityPub spec

#### 3. ActivityPubActivityProcessor
- Processes all incoming activity types
- Follow: Creates relationship, sends Accept
- Accept: Updates relationship to accepted state
- Reject: Updates relationship to rejected state
- Create: Stores federated content
- Like: Records like reaction
- Announce: Increments boost count
- Undo: Reverts previous actions
- Delete: Soft-deletes federated content
- Update: Marks content as edited

#### 4. ActivityPubDeliveryService
- Sends Follow activities to remote instances
- Sends Accept activities in response to follows
- Sends Create activities (posts) to followers
- Sends Like activities to remote instances
- Sends Undo activities
- Fetches remote actor profiles on-demand

### Data Flow

#### Incoming Activity Flow
```
Remote Server → HTTP Signature Verification → Activity Type → Specific Handler
                                                       ↓
                                          Database Update & Response
```

#### Outgoing Activity Flow
```
Local Action → Create Activity → Sign with Key → Send to Followers' Inboxes
                                   ↓
                            Track Status & Retry
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

## Database Migration

To apply the migration:

```bash
cd DysonNetwork.Sphere
dotnet ef database update
```

## Testing

### WebFinger
```bash
curl "https://your-domain.com/.well-known/webfinger?resource=acct:username@your-domain.com"
```

### Actor Profile
```bash
curl -H "Accept: application/activity+json" https://your-domain.com/activitypub/actors/username
```

### Outbox
```bash
curl -H "Accept: application/activity+json" https://your-domain.com/activitypub/actors/username/outbox
```

## Notes

- All models follow the existing Solar Network patterns (ModelBase, NodaTime, JSON columns)
- Controllers use standard ASP.NET Core patterns with dependency injection
- Database uses PostgreSQL with JSONB for flexible metadata storage
- Migration follows existing naming conventions
- Soft delete is enabled on all models

## References

- [ActivityPub W3C Recommendation](https://www.w3.org/TR/activitypub/)
- [ActivityStreams 2.0](https://www.w3.org/TR/activitystreams-core/)
- [WebFinger RFC 7033](https://tools.ietf.org/html/rfc7033)
- [Mastodon Federation Documentation](https://docs.joinmastodon.org/spec/activitypub/)

## TODOs

- [ ] Implement HTTP Signature verification middleware
- [ ] Create activity processor service
- [ ] Implement activity queue and retry logic
- [ ] Add key generation for Publishers
- [ ] Implement content conversion between formats
- [ ] Add inbox background worker
- [ ] Add outbox delivery worker
- [ ] Implement relationship management logic
- [ ] Add moderation tools for federated content
- [ ] Add federation metrics and monitoring
- [ ] Write comprehensive tests
