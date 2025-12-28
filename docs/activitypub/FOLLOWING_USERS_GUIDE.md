# Follow Feature - User Guide

## Quick Start: How to Follow Fediverse Users

### Method 1: Via Search (Recommended)

1. Go to the search bar in Solar Network
2. Type the user's full address: `@username@domain.com`
   - Example: `@alice@mastodon.social`
   - Example: `@bob@pleroma.site`
3. Click on their profile in search results
4. Click the "Follow" button
5. Wait for acceptance (usually immediate)
6. ✅ Done! Their posts will now appear in your timeline

### Method 2: Via Profile URL

1. If you know their profile URL, visit it directly:
   - Example: `https://mastodon.social/@alice`
2. Look for the "Follow" button on their profile
3. Click it to follow
4. ✅ You're now following them!

## What Happens When You Follow Someone

### The Technical Flow
```
You click "Follow"
        ↓
Solar Network creates Follow Activity
        ↓
Follow Activity is signed with your private key
        ↓
Solar Network sends Follow to their instance's inbox
        ↓
Their instance verifies your signature
        ↓
Their instance processes the Follow
        ↓
Their instance sends Accept Activity back
        ↓
Solar Network receives and processes Accept
        ↓
Relationship is stored in database
        ↓
Their public posts federate to Solar Network
```

### What You'll See

- ✅ **"Following..."** (while waiting for acceptance)
- ✅ **"Following" ✓** (when accepted)
- ✅ **Their posts** in your home timeline
- ✅ **Their likes, replies, boosts** on your posts

## Different Types of Accounts

### Regular Users
- Full ActivityPub support
- Follows work both ways
- Content federates normally
- Example: `@alice@mastodon.social`

### Locked Accounts
- User must manually approve followers
- You'll see "Pending" after clicking follow
- User receives notification to approve/deny
- Example: `@private@pleroma.site`

### Bot/Service Accounts
- Automated content accounts
- Often auto-accept follows
- Example: `@newsbot@botsin.space`

### Organizational Accounts
- Group or team accounts
- Example: `@team@company.social`

## Managing Your Follows

### View Who You're Following

**Go to**: Following page or `GET /api/activitypub/following`

You'll see:
- Username
- Display name
- Profile picture
- When you followed them
- Their instance (e.g., "Mastodon")

### Unfollowing Someone

**Method 1: Via UI**
1. Go to their profile
2. Click "Following" button (shows as active)
3. Click to unfollow

**Method 2: Via API**
```bash
curl -X POST http://solar.local:5000/api/activitypub/unfollow \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "targetActorUri": "https://mastodon.social/users/alice"
  }'
```

**Response**:
```json
{
  "success": true,
  "message": "Unfollowed successfully"
}
```

### View Your Followers

**Go to**: Followers page or `GET /api/activitypub/followers`

You'll see:
- Users following you
- Their instance
- When they started following
- Whether they're local or from another instance

## Searching Fediverse Users

### How Search Works

1. **Type in search bar**: `@username@domain.com`
2. **Solar Network queries their instance**:
   - Fetches their actor profile
   - Checks if they're discoverable
3. **Shows results**:
   - Profile picture
   - Display name
   - Bio
   - Instance name

### Supported Search Formats

| Format | Example | Works? |
|--------|---------|--------|
| Full handle | `@alice@mastodon.social` | ✅ Yes |
| Username only | `alice` | ⚠️ May search local users first |
| Full URL | `https://mastodon.social/@alice` | ✅ Yes |

## Privacy Considerations

### Public Posts
- **What**: Posts visible to everyone
- **Federation**: ✅ Federates to all followers
- **Timeline**: Visible in public federated timelines
- **Example**: General updates, thoughts, content you want to share

### Private Posts
- **What**: Posts only visible to followers
- **Federation**: ✅ Federates to followers (including remote)
- **Timeline**: Only visible to your followers
- **Example**: Personal updates, questions

### Unlisted Posts
- **What**: Posts not in public timelines
- **Federation**: ✅ Federates but marked unlisted
- **Timeline**: Only followers see it
- **Example**: Limited audience content

### Followers-Only Posts
- **What**: Posts only to followers, no federated boost
- **Federation**: ⚠️ May not federate fully
- **Timeline**: Only your followers
- **Example**: Very sensitive content

## Following Etiquette

### Best Practices

1. **Check before following**:
   - Read their bio and recent posts
   - Make sure they're who you think they are
   - Check if their content aligns with your interests

2. **Start with interactions**:
   - Like a few posts first
   - Reply thoughtfully
   - Share interesting content
   - Then follow if you want to see more

3. **Respect instance culture**:
   - Each instance has its own norms
   - Read their community guidelines
   - Be mindful of local rules

4. **Don't spam**:
   - Don't mass-follow users
   - Don't send unwanted DMs
   - Don't repeatedly like old posts

5. **Use appropriate post visibility**:
   - Public for general content
   - Unlisted for updates to followers
   - Private for sensitive topics

### Red Flags to Watch

1. **Suspicious accounts**:
   - Newly created with generic content
   - Only posting promotional links
   - Unusual following patterns

2. **Instances with poor moderation**:
   - Lots of spam in public timelines
   - Harassment goes unaddressed
   - You may want to block the instance

3. **Content warnings not respected**:
   - Users posting unmarked sensitive content
   - You can report/block these users

## Troubleshooting

### "Follow button doesn't work"

**Possible causes**:
1. User doesn't exist
2. Instance is down
3. Network connectivity issue

**What to do**:
1. Verify the username/domain is correct
2. Try searching for them again
3. Check your internet connection
4. Try again in a few minutes

### "User doesn't appear in Following list"

**Possible causes**:
1. Follow was rejected (locked account)
2. Follow is still pending
3. Error in federation

**What to do**:
1. Check if their account is locked
2. Wait a few minutes for acceptance
3. Check your ActivityPub logs
4. Try following again

### "Can't find a user via search"

**Possible causes**:
1. Username/domain is wrong
2. User's instance is blocking your instance
3. User's profile is not discoverable

**What to do**:
1. Double-check the spelling
2. Try their full URL: `https://instance.com/@username`
3. Check if they're from a blocked instance
4. Contact them directly for their handle

## API Reference

### Follow a Remote User

**Endpoint**: `POST /api/activitypub/follow`

**Request**:
```json
{
  "targetActorUri": "https://mastodon.social/users/alice"
}
```

**Success Response**:
```json
{
  "success": true,
  "message": "Follow request sent. Waiting for acceptance.",
  "targetActorUri": "https://mastodon.social/users/alice"
}
```

### Get Your Following

**Endpoint**: `GET /api/activitypub/following?limit=50`

**Response**:
```json
{
  "users": [
    {
      "actorUri": "https://mastodon.social/users/alice",
      "username": "alice",
      "displayName": "Alice Smith",
      "bio": "I love tech!",
      "avatarUrl": "https://...",
      "followedAt": "2024-01-15T10:30:00Z",
      "isLocal": false,
      "instanceDomain": "mastodon.social"
    }
  ]
}
```

### Get Your Followers

**Endpoint**: `GET /api/activitypub/followers?limit=50`

**Response**:
```json
{
  "users": [
    {
      "actorUri": "https://pleroma.site/users/bob",
      "username": "bob",
      "displayName": "Bob Jones",
      "bio": "Federated user following me",
      "avatarUrl": "https://...",
      "followedAt": "2024-01-10T14:20:00Z",
      "isLocal": false,
      "instanceDomain": "pleroma.site"
    }
  ]
}
```

### Search Users

**Endpoint**: `GET /api/activitypub/search?query=@alice@domain.com&limit=20`

**Response**:
```json
{
  "users": [
    {
      "actorUri": "https://mastodon.social/users/alice",
      "username": "alice",
      "displayName": "Alice Smith",
      "bio": "Tech enthusiast",
      "avatarUrl": "https://...",
      "isLocal": false,
      "instanceDomain": "mastodon.social"
    }
  ]
}
```

## Real Examples

### Example 1: Following a Mastodon User

**What you do**:
1. Search for `@alice@mastodon.social`
2. Click on Alice's profile
3. Click "Follow" button
4. Wait 1-2 seconds
5. ✅ Alice appears in your "Following" list
6. ✅ Alice's public posts appear in your timeline

**What happens technically**:
- Solar Network sends Follow to Alice's Mastodon instance
- Alice's Mastodon auto-accepts (unless locked)
- Mastodon sends Accept back to Solar Network
- Relationship stored in both databases
- Alice's future posts federate to Solar Network

### Example 2: Following a Locked Account

**What you do**:
1. Search for `@private@pleroma.site`
2. Click "Follow" button
3. ✅ See "Following..." (pending)
4. Wait for user to approve

**What happens technically**:
- Solar Network sends Follow to private@pleroma.site
- Private user receives notification
- Private user manually approves the request
- Private user's instance sends Accept
- ✅ Now following!

### Example 3: Following a Bot Account

**What you do**:
1. Search for `@news@botsin.space`
2. Click "Follow" button
3. ✅ Immediately following (bots auto-accept)

**What happens technically**:
- Follow is auto-accepted
- News posts appear in your timeline
- Regular updates from the bot

## Key Differences from Traditional Social Media

| Aspect | Traditional Social | ActivityPub |
|---------|------------------|-------------|
| Central server | ❌ No | ✅ Yes (per instance) |
| Multiple platforms | ❌ No | ✅ Yes (Mastodon, Pleroma, etc.) |
| Data ownership | ❌ On their servers | ✅ On your server |
| Blocking | ❌ One platform | ✅ Per instance |
| Migration | ❌ Difficult | ✅ Use your own domain |
| Federation | ❌ No | ✅ Built-in |

## Getting Help

If you have issues following users:

1. **Check the main guide**: See `HOW_TO_FOLLOW_FEDIVERSE_USERS.md`
2. **Check your logs**: Look for ActivityPub errors
3. **Test the API**: Use curl to test follow endpoints directly
4. **Verify the user**: Make sure the user exists on their instance

## Summary

Following fediverse users in Solar Network:

1. **Simple**: Just search and click "Follow"
2. **Works both ways**: You can follow them, they can follow you
3. **Works across instances**: Mastodon, Pleroma, Lemmy, etc.
4. **Federated content**: Their posts appear in your timeline
5. **Full interactions**: Like, reply, boost their posts

It works just like following on any other social platform, but with the added benefit of being able to follow users on completely different services! 🌍
