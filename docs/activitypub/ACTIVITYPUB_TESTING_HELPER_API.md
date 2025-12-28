# ActivityPub Testing Helper API

This document describes helper endpoints for testing ActivityPub federation.

## Purpose

These endpoints allow you to manually trigger ActivityPub activities for testing purposes without implementing the full UI federation integration yet.

## Helper Endpoints

### 1. Send Follow Activity

**Endpoint**: `POST /api/activitypub/test/follow`

**Description**: Sends a Follow activity to a remote actor

**Request Body**:
```json
{
  "targetActorUri": "http://mastodon.local:3001/users/testuser"
}
```

**Response**:
```json
{
  "success": true,
  "activityId": "http://solar.local:5000/activitypub/activities/...",
  "targetActor": "http://mastodon.local:3001/users/testuser"
}
```

### 2. Send Like Activity

**Endpoint**: `POST /api/activitypub/test/like`

**Description**: Sends a Like activity for a post (can be local or remote)

**Request Body**:
```json
{
  "postId": "POST_ID",
  "targetActorUri": "http://mastodon.local:3001/users/testuser"
}
```

**Response**:
```json
{
  "success": true,
  "activityId": "http://solar.local:5000/activitypub/activities/..."
}
```

### 3. Send Announce (Boost) Activity

**Endpoint**: `POST /api/activitypub/test/announce`

**Description**: Boosts a post to followers

**Request Body**:
```json
{
  "postId": "POST_ID"
}
```

### 4. Send Undo Activity

**Endpoint**: `POST /api/activitypub/test/undo`

**Description**: Undoes a previous activity

**Request Body**:
```json
{
  "activityType": "Like", // or "Follow", "Announce"
  "objectUri": "http://solar.local:5000/activitypub/objects/POST_ID"
}
```

### 5. Get Federation Status

**Endpoint**: `GET /api/activitypub/test/status`

**Description**: Returns current federation statistics

**Response**:
```json
{
  "actors": {
    "total": 5,
    "local": 1,
    "remote": 4
  },
  "contents": {
    "total": 25,
    "byType": {
      "Note": 20,
      "Article": 5
    }
  },
  "relationships": {
    "total": 8,
    "accepted": 6,
    "pending": 1,
    "rejected": 1
  },
  "activities": {
    "total": 45,
    "byStatus": {
      "Completed": 40,
      "Pending": 3,
      "Failed": 2
    },
    "byType": {
      "Create": 20,
      "Follow": 8,
      "Accept": 6,
      "Like": 5,
      "Announce": 3,
      "Undo": 2,
      "Delete": 1
    }
  }
}
```

### 6. Get Recent Activities

**Endpoint**: `GET /api/activitypub/test/activities`

**Query Parameters**:
- `limit`: Number of activities to return (default: 20)
- `type`: Filter by activity type (optional)

**Response**:
```json
{
  "activities": [
    {
      "id": "ACTIVITY_ID",
      "type": "Follow",
      "status": "Completed",
      "actorUri": "http://mastodon.local:3001/users/testuser",
      "objectUri": "http://solar.local:5000/activitypub/actors/solaruser",
      "createdAt": "2024-01-15T10:30:00Z",
      "errorMessage": null
    }
  ]
}
```

### 7. Get Actor Keys

**Endpoint**: `GET /api/activitypub/test/actors/{username}/keys`

**Description**: Returns the public/private key pair for a publisher

**Response**:
```json
{
  "username": "solaruser",
  "hasKeys": true,
  "actorUri": "http://solar.local:5000/activitypub/actors/solaruser",
  "publicKeyId": "http://solar.local:5000/activitypub/actors/solaruser#main-key",
  "publicKey": "-----BEGIN PUBLIC KEY-----\n...",
  "privateKeyStored": true
}
```

### 8. Test HTTP Signature

**Endpoint**: `POST /api/activitypub/test/sign`

**Description**: Test if a signature string is valid for a given public key

**Request Body**:
```json
{
  "publicKey": "-----BEGIN PUBLIC KEY-----\n...",
  "signingString": "(request-target): post /inbox\nhost: example.com\ndate: ...",
  "signature": "..."
}
```

**Response**:
```json
{
  "valid": true,
  "message": "Signature is valid"
}
```

## Controller Implementation

Create `DysonNetwork.Sphere/ActivityPub/ActivityPubTestController.cs`:

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DysonNetwork.Sphere.ActivityPub;

[ApiController]
[Route("api/activitypub/test")]
[Authorize] // Require auth for testing
public class ActivityPubTestController(
    AppDatabase db,
    ActivityPubDeliveryService deliveryService,
    ActivityPubKeyService keyService,
    ActivityPubSignatureService signatureService,
    IConfiguration configuration,
    ILogger<ActivityPubTestController> logger
) : ControllerBase
{
    [HttpPost("follow")]
    public async Task<ActionResult> TestFollow([FromBody] TestFollowRequest request)
    {
        var currentUser = GetCurrentUser();
        var publisher = await GetPublisherForUser(currentUser.Id);
        
        if (publisher == null)
            return BadRequest("Publisher not found");
        
        var success = await deliveryService.SendFollowActivityAsync(
            publisher.Id,
            request.TargetActorUri
        );
        
        return Ok(new
        {
            success,
            targetActorUri = request.TargetActorUri,
            publisherId = publisher.Id
        });
    }

    [HttpPost("like")]
    public async Task<ActionResult> TestLike([FromBody] TestLikeRequest request)
    {
        var currentUser = GetCurrentUser();
        var publisher = await GetPublisherForUser(currentUser.Id);
        
        var success = await deliveryService.SendLikeActivityAsync(
            request.PostId,
            currentUser.Id,
            request.TargetActorUri
        );
        
        return Ok(new { success, postId = request.PostId });
    }

    [HttpPost("announce")]
    public async Task<ActionResult> TestAnnounce([FromBody] TestAnnounceRequest request)
    {
        var post = await db.Posts.FindAsync(request.PostId);
        if (post == null)
            return NotFound();
        
        var success = await deliveryService.SendCreateActivityAsync(post);
        
        return Ok(new { success, postId = request.PostId });
    }

    [HttpPost("undo")]
    public async Task<ActionResult> TestUndo([FromBody] TestUndoRequest request)
    {
        var currentUser = GetCurrentUser();
        var publisher = await GetPublisherForUser(currentUser.Id);
        
        if (publisher == null)
            return BadRequest("Publisher not found");
        
        var success = await deliveryService.SendUndoActivityAsync(
            request.ActivityType,
            request.ObjectUri,
            publisher.Id
        );
        
        return Ok(new { success, activityType = request.ActivityType });
    }

    [HttpGet("status")]
    public async Task<ActionResult> GetStatus()
    {
        var totalActors = await db.FediverseActors.CountAsync();
        var localActors = await db.FediverseActors
            .CountAsync(a => a.Uri.Contains("solar.local"));
        
        var totalContents = await db.FediverseContents.CountAsync();
        
        var relationships = await db.FediverseRelationships
            .GroupBy(r => r.State)
            .Select(g => new { State = g.Key, Count = g.Count() })
            .ToListAsync();
        
        var activitiesByStatus = await db.FediverseActivities
            .GroupBy(a => a.Status)
            .Select(g => new { Status = g.Key, Count = g.Count() })
            .ToListAsync();
        
        var activitiesByType = await db.FediverseActivities
            .GroupBy(a => a.Type)
            .Select(g => new { Type = g.Key, Count = g.Count() })
            .ToListAsync();
        
        return Ok(new
        {
            actors = new
            {
                total = totalActors,
                local = localActors,
                remote = totalActors - localActors
            },
            contents = new
            {
                total = totalContents
            },
            relationships = relationships.ToDictionary(r => r.State.ToString(), r => r.Count),
            activities = new
            {
                byStatus = activitiesByStatus.ToDictionary(a => a.Status.ToString(), a => a.Count),
                byType = activitiesByType.ToDictionary(a => a.Type.ToString(), a => a.Count)
            }
        });
    }

    [HttpGet("activities")]
    public async Task<ActionResult> GetActivities([FromQuery] int limit = 20, [FromQuery] string? type = null)
    {
        var query = db.FediverseActivities
            .OrderByDescending(a => a.CreatedAt);
        
        if (!string.IsNullOrEmpty(type))
        {
            query = query.Where(a => a.Type.ToString() == type);
        }
        
        var activities = await query
            .Take(limit)
            .Select(a => new
            {
                a.Id,
                a.Type,
                a.Status,
                ActorUri = a.Actor.Uri,
                ObjectUri = a.ObjectUri,
                a.CreatedAt,
                a.ErrorMessage
            })
            .ToListAsync();
        
        return Ok(new { activities });
    }

    [HttpGet("actors/{username}/keys")]
    public async Task<ActionResult> GetActorKeys(string username)
    {
        var publisher = await db.Publishers
            .FirstOrDefaultAsync(p => p.Name == username);
        
        if (publisher == null)
            return NotFound();
        
        var actorUrl = $"http://solar.local:5000/activitypub/actors/{username}";
        
        var (privateKey, publicKey) = keyService.GenerateKeyPair();
        
        return Ok(new
        {
            username,
            hasKeys = publisher.Meta != null,
            actorUri,
            publicKeyId = $"{actorUrl}#main-key",
            publicKey = publicKey,
            privateKeyStored = publisher.Meta != null
        });
    }

    [HttpPost("sign")]
    public ActionResult TestSignature([FromBody] TestSignatureRequest request)
    {
        var isValid = keyService.Verify(
            request.PublicKey,
            request.SigningString,
            request.Signature
        );
        
        return Ok(new
        {
            valid = isValid,
            message = isValid ? "Signature is valid" : "Signature is invalid"
        });
    }

    private async Task<SnPublisher?> GetPublisherForUser(Guid accountId)
    {
        return await db.Publishers
            .Include(p => p.Members)
            .Where(p => p.Members.Any(m => m.AccountId == accountId))
            .FirstOrDefaultAsync();
    }

    private Guid GetCurrentUser()
    {
        // Implement based on your auth system
        return Guid.Empty;
    }
}

public class TestFollowRequest
{
    public string TargetActorUri { get; set; } = string.Empty;
}

public class TestLikeRequest
{
    public Guid PostId { get; set; }
    public string TargetActorUri { get; set; } = string.Empty;
}

public class TestAnnounceRequest
{
    public Guid PostId { get; set; }
}

public class TestUndoRequest
{
    public string ActivityType { get; set; } = string.Empty;
    public string ObjectUri { get; set; } = string.Empty;
}

public class TestSignatureRequest
{
    public string PublicKey { get; set; } = string.Empty;
    public string SigningString { get; set; } = string.Empty;
    public string Signature { get; set; } = string.Empty;
}
```

## Testing with Helper Endpoints

### 1. Test Follow
```bash
curl -X POST http://solar.local:5000/api/activitypub/test/follow \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "targetActorUri": "http://mastodon.local:3001/users/testuser"
  }'
```

### 2. Test Like
```bash
curl -X POST http://solar.local:5000/api/activitypub/test/like \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "postId": "YOUR_POST_ID",
    "targetActorUri": "http://mastodon.local:5000/activitypub/actors/mastodonuser"
  }'
```

### 3. Check Status
```bash
curl http://solar.local:5000/api/activitypub/test/status \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 4. Get Recent Activities
```bash
curl "http://solar.local:5000/api/activitypub/test/activities?limit=10" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Integration with Main Flow

These helper endpoints can be used to:

1. **Quickly test federation** without full UI integration
2. **Debug specific activity types** in isolation
3. **Verify HTTP signatures** are correct
4. **Test error handling** for various scenarios
5. **Monitor federation status** during development

## Security Notes

- All test endpoints require authentication
- Use only in development/staging environments
- Remove or disable in production
- Rate limiting recommended if exposing to public

## Cleanup

After testing, you can:

1. Remove the test controller (optional)
2. Disable test endpoints
3. Clear test activities from database
4. Reset test relationships

```sql
-- Clear test data
DELETE FROM fediverse_activities WHERE created_at < NOW() - INTERVAL '1 day';
```
