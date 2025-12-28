# How to Follow (Subscribe to) Fediverse Users in Solar Network

## Overview

In ActivityPub terminology, "subscribing" to a user is called **"following"**. This guide explains how users in Solar Network can follow users from other federated services (Mastodon, Pleroma, etc.).

## User Guide: How to Follow Fediverse Users

### Method 1: Via Search (Recommended)

1. **Search for the user**:
   - Type their full address in the search bar: `@username@domain.com`
   - Example: `@alice@mastodon.social`
   - Example: `@bob@pleroma.site`

2. **View their profile**:
   - Click on the search result
   - You'll see their profile, bio, and recent posts

3. **Click "Follow" button**:
   - Solar Network sends a Follow activity to their instance
   - The remote instance will send back an Accept
   - The user now appears in your "Following" list

### Method 2: Via Profile URL

1. **Visit their profile directly**:
   - If you know their profile URL, visit it directly
   - Example: `https://mastodon.social/@alice`

2. **Look for "Follow" button**:
   - Click it to follow

3. **Confirm the follow**:
   - Solar Network will send the follow request
   - Wait for acceptance (usually immediate)

## What Happens Behind the Scenes

### The Follow Flow

```
User clicks "Follow"
        ↓
Solar Network creates Follow Activity
        ↓
Solar Network signs with publisher's private key
        ↓
Solar Network sends to remote user's inbox
        ↓
Remote instance verifies signature
        ↓
Remote instance processes the Follow
        ↓
Remote instance sends Accept Activity back
        ↓
Solar Network receives and processes Accept
        ↓
Relationship is established!
```

### Timeline Integration

Once you're following a user:
- ✅ Their public posts appear in your "Home" timeline
- ✅ Their posts are federated to your followers
- ✅ Their likes, replies, and boosts are visible
- ✅ You can interact with their content

## Following Different Types of Accounts

### Individual Users
- **What**: Regular users like you
- **Example**: `@alice@mastodon.social`
- **Works**: ✅ Full support

### Organizational/Bot Accounts
- **What**: Groups, bots, or organizations
- **Example**: `@official@newsbot.site`
- **Works**: ✅ Full support

### Locked Accounts
- **What**: Users who manually approve followers
- **Example**: `@private@pleroma.site`
- **Works**: ✅ Follow request sent, waits for approval

## Managing Your Follows

### View Who You're Following

**API Endpoint**: `GET /api/activitypub/following`

**Response Example**:
```json
{
  "users": [
    {
      "actorUri": "https://mastodon.social/users/alice",
      "username": "alice",
      "displayName": "Alice Smith",
      "bio": "I love tech and coffee! ☕",
      "avatarUrl": "https://cdn.mastodon.social/avatars/...",
      "followedAt": "2024-01-15T10:30:00Z",
      "isLocal": false,
      "instanceDomain": "mastodon.social"
    }
  ]
}
```

### Unfollowing Someone

**API Endpoint**: `POST /api/activitypub/unfollow`

**Request Body**:
```json
{
  "targetActorUri": "https://mastodon.social/users/alice"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Unfollowed successfully"
}
```

## Searching Fediverse Users

**API Endpoint**: `GET /api/activitypub/search?query=@username@domain.com`

**Response Example**:
```json
{
  "users": [
    {
      "actorUri": "https://mastodon.social/users/alice",
      "username": "alice",
      "displayName": "Alice Smith",
      "bio": "Software developer | Mastodon user",
      "avatarUrl": "https://cdn.mastodon.social/avatars/...",
      "isLocal": false,
      "instanceDomain": "mastodon.social"
    }
  ]
}
```

## Follow States

| State | Meaning | What User Sees |
|--------|---------|----------------|
| Pending | Follow request sent, waiting for response | "Following..." (loading) |
| Accepted | Remote user accepted | "Following" ✓ |
| Rejected | Remote user declined | "Follow" button available again |
| Failed | Error occurred | "Error following" message |

## Privacy & Visibility

### Public Posts
- ✅ Federate to your followers automatically
- ✅ Appear in remote instances' timelines
- ✅ Can be boosted/liked by remote users

### Private Posts
- ❌ Do not federate
- ❌ Only visible to your local followers
- ❌ Not sent to remote instances

### Unlisted Posts
- ⚠️ Federate but not in public timelines
- ⚠️ Only visible to followers

## Best Practices for Users

### When Following Someone

1. **Check their profile first**:
   - Make sure they're who you think they are
   - Read their bio to understand their content

2. **Start with a few interactions**:
   - Like a few posts
   - Reply to something interesting
   - Don't overwhelm their timeline

3. **Respect their instance's rules**:
   - Each instance has its own guidelines
   - Read community rules before interacting

4. **Report spam/harassment**:
   - Use instance blocking features
   - Report to instance admins

### Following Across Instances

1. **Use their full address**:
   - `@username@instance.com`
   - This helps identify which instance they're on

2. **Be aware of instance culture**:
   - Each instance has its own norms
   - Some are more technical, others more casual

3. **Check if they're from your instance**:
   - Local users show `isLocal: true`
   - Usually faster interaction

## Troubleshooting

### "Follow button doesn't work"

**Possible Causes**:
1. User doesn't exist
2. Instance is down
3. Network issue

**Solutions**:
1. Verify the user's address is correct
2. Check if the instance is accessible
3. Check your internet connection
4. Try again in a few minutes

### "User doesn't appear in Following list"

**Possible Causes**:
1. Follow was rejected
2. Still waiting for acceptance (locked accounts)
3. Error in federation

**Solutions**:
1. Check the follow status via API
2. Try following again
3. Check if their account is locked
4. Contact support if issue persists

### "Can't find a user"

**Possible Causes**:
1. Wrong username or domain
2. User doesn't exist
3. Instance blocking your instance

**Solutions**:
1. Double-check the address
2. Try searching from a different instance
3. Contact the user directly for their handle

## API Reference

### Follow a Remote User

**Endpoint**: `POST /api/activitypub/follow`

**Request**:
```json
{
  "targetActorUri": "https://mastodon.social/users/alice"
}
```

**Response**: `200 OK`
```json
{
  "success": true,
  "message": "Follow request sent. Waiting for acceptance.",
  "targetActorUri": "https://mastodon.social/users/alice"
}
```

### Get Following List

**Endpoint**: `GET /api/activitypub/following?limit=50`

**Response**: `200 OK`
```json
{
  "users": [
    {
      "actorUri": "https://mastodon.social/users/alice",
      "username": "alice",
      "displayName": "Alice Smith",
      "bio": "...",
      "avatarUrl": "...",
      "followedAt": "2024-01-15T10:30:00Z",
      "isLocal": false,
      "instanceDomain": "mastodon.social"
    }
  ]
}
```

### Get Followers List

**Endpoint**: `GET /api/activitypub/followers?limit=50`

**Response**: `200 OK`
```json
{
  "users": [
    {
      "actorUri": "https://mastodon.social/users/alice",
      "username": "alice",
      "displayName": "Alice Smith",
      "bio": "...",
      "avatarUrl": "...",
      "isLocal": false,
      "instanceDomain": "mastodon.social"
    }
  ]
}
```

### Search Users

**Endpoint**: `GET /api/activitypub/search?query=alice&limit=20`

**Response**: `200 OK`
```json
{
  "users": [
    {
      "actorUri": "https://mastodon.social/users/alice",
      "username": "alice",
      "displayName": "Alice Smith",
      "bio": "...",
      "avatarUrl": "...",
      "isLocal": false,
      "instanceDomain": "mastodon.social"
    }
  ]
}
```

## What's Different About ActivityPub Following?

Unlike traditional social media:

| Feature | Traditional Social | ActivityPub |
|---------|------------------|-------------|
| Central server | ✅ Yes | ❌ No - federated |
| All users on same platform | ✅ Yes | ❌ No - multiple platforms |
| Blocked instances | ❌ No | ✅ Yes - instance blocking |
| Following across platforms | ❌ No | ✅ Yes - works with Mastodon, Pleroma, etc. |
| Your data stays on your server | ❌ Maybe | ✅ Yes - you control your data |

## User Experience Considerations

### Making It Easy

1. **Auto-discovery**:
   - When users search for `@username`, suggest `@username@domain.com`
   - Offer to search the fediverse

2. **Clear UI feedback**:
   - Show "Follow request sent..."
   - Show "They accepted!" notification
   - Show "Follow request rejected" message

3. **Helpful tooltips**:
   - Explain what ActivityPub is
   - Show which instance a user is from
   - Explain locked accounts

4. **Profile badges**:
   - Show instance icon/logo
   - Show if user is from same instance
   - Show if user is verified

## Examples

### Following a Mastodon User

**User searches**: `@alice@mastodon.social`

**What happens**:
1. Solar Network fetches Alice's actor profile
2. Solar Network stores Alice in `fediverse_actors`
3. Solar Network sends Follow to Alice's inbox
4. Alice's instance accepts
5. Solar Network stores relationship in `fediverse_relationships`
6. Alice's posts now appear in user's timeline

### Following a Local User

**User searches**: `@bob`

**What happens**:
1. Solar Network finds Bob's publisher
2. Relationship created locally (no federation needed)
3. Bob's posts appear in user's timeline immediately
4. Same as traditional social media following

## Summary

Following fediverse users in Solar Network:

1. **Search by `@username@domain.com`** - Works for any ActivityPub instance
2. **Click "Follow"** - Sends federated follow request
3. **Wait for acceptance** - Remote user can approve or auto-accept
4. **See their posts in your timeline** - Content federates to you
5. **Interact normally** - Like, reply, boost, etc.

All of this is handled automatically by the ActivityPub implementation!
