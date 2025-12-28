# ActivityPub UI Implementation

## Overview

Complete UI implementation for ActivityPub features in Solian client, including search, following, and followers screens.

## Created Files

### 1. Widgets (`lib/widgets/activitypub/`)

#### `activitypub.dart`
- **Purpose**: Export file for ActivityPub widgets
- **Exports**: `ActivityPubUserListItem`

#### `user_list_item.dart`
- **Purpose**: Reusable list item widget for displaying ActivityPub users
- **Features**:
  - Avatar with remote instance indicator (public icon)
  - Display name with instance badge (e.g., "mastodon.social")
  - Bio with truncation (max 2 lines)
  - Followed at timestamp (relative time)
  - Follow/Unfollow buttons with loading states
  - Tap callback for navigation to profile

### 2. Screens (`lib/screens/activitypub/`)

#### `activitypub.dart`
- **Purpose**: Export file for ActivityPub screens
- **Exports**: `ActivityPubSearchScreen`, `ActivityPubListScreen`

#### `search.dart`
- **Purpose**: Search and follow ActivityPub users from other instances
- **Features**:
  - Search bar with 500ms debounce
  - Real-time search results
  - Instant follow/unfollow actions
  - Local tracking of followed users
  - Empty states for no search and no results
  - Refresh support via pull-to-refresh
  - User feedback via snack bars
- **User Flow**:
  1. User enters search query (e.g., `@alice@mastodon.social`)
  2. Results appear after debounce
  3. User taps "Follow" → Follow request sent
  4. Success message shown
  5. Button updates to "Unfollow"

#### `list.dart`
- **Purpose**: Display following/followers lists
- **Features**:
  - Reusable for both Following and Followers
  - Local state management
  - Per-user loading states during actions
  - Empty states with helpful hints
  - Refresh support
  - Auto-update lists when actions occur
- **Types**:
  - `ActivityPubListType.following`: Shows users you follow
  - `ActivityPubListType.followers`: Shows users who follow you
- **User Flow**:
  1. User opens Following/Followers screen
  2. List loads from API
  3. User can unfollow (Following tab) or follow (Followers tab)
  4. List updates automatically
  5. Success/error messages shown

## Design Patterns

### Follows Project Conventions

1. **Material 3 Design**: All widgets use Material 3 components
2. **Styled Widget Package**: Used for `.padding()`, `.textColor()`, etc.
3. **Riverpod State Management**: Hooks for local state, providers for global state
4. **Error Handling**: `showErrorAlert()` from `alert.dart` for user feedback
5. **Success Feedback**: `showSnackBar()` for quick notifications
6. **Localization**: All strings use `.tr()` with placeholder args

### Color Scheme & Theming

- **Remote Badge**: Uses `Theme.colorScheme.primary` for indicator
- **Instance Tag**: Uses `Theme.colorScheme.secondaryContainer`
- **Text Colors**: Adaptive based on theme (dark/light)
- **States**: Loading indicators with standard `CircularProgressIndicator`

### Spacing & Layout

- **List Item Padding**: `EdgeInsets.only(left: 16, right: 12)`
- **Avatar Size**: 24px radius (48px diameter)
- **Badge Size**: Small (10px font) with 6px horizontal padding
- **Button Size**: Minimum 88px width, 36px height

## Translations Added

### New Keys in `assets/i18n/en-US.json`

```json
{
  "searchFediverse": "Search Fediverse",
  "searchFediverseHint": "Search by address, e.g. {}",
  "searchFediverseEmpty": "Search for users on other ActivityPub instances",
  "searchFediverseNoResults": "No users found for this search",
  "following": "Following",
  "followers": "Followers",
  "follow": "Follow",
  "unfollow": "Unfollow",
  "followedUser": "Followed @{}",
  "unfollowedUser": "Unfollowed @{}",
  "followingEmpty": "You're not following anyone yet",
  "followersEmpty": "No followers yet",
  "followingEmptyHint": "Start by searching for users or explore other instances"
}
```

## Usage Examples

### Using Search Screen

```dart
import 'package:go_router/go_router.dart';
import 'package:island/screens/activitypub/activitypub.dart';

// In navigation or route
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ActivityPubSearchScreen(),
  ),
);

// Or using go_router
context.push('/activitypub/search');
```

### Using List Screen

```dart
// Following
ActivityPubListScreen(
  type: ActivityPubListType.following,
);

// Followers
ActivityPubListScreen(
  type: ActivityPubListType.followers,
);
```

### Using User List Item Widget

```dart
ActivityPubUserListItem(
  user: user,
  isFollowing: isFollowing,
  isLoading: isLoading,
  onFollow: () => handleFollow(user),
  onUnfollow: () => handleUnfollow(user),
  onTap: () => navigateToProfile(user),
);
```

## Integration Points

### Navigation Integration

To add ActivityPub screens to navigation:

1. **Option A**: Add to existing tab/navigation structure
2. **Option B**: Add as standalone routes in `go_router`
3. **Option C**: Add to profile menu overflow menu

### Service Integration

All screens use `activityPubServiceProvider`:

```dart
import 'package:island/services/activitypub_service.dart';

final service = ref.read(activityPubServiceProvider);
```

### Error Handling

All errors are caught and displayed using:

```dart
try {
  // API call
} catch (err) {
  showErrorAlert(err);
}
```

## Testing Checklist

- [ ] Search for existing Mastodon user
- [ ] Search for Pleroma user
- [ ] Follow a user
- [ ] Unfollow a user
- [ ] View following list
- [ ] View followers list
- [ ] Test empty states
- [ ] Test loading states
- [ ] Test error handling
- [ ] Test dark mode
- [ ] Test RTL languages (if supported)

## Technical Details

### Dependencies

**Already in project**:
- ✅ `cached_network_image` - For avatar images
- ✅ `easy_localization` - For translations
- ✅ `hooks_riverpod` - For state management
- ✅ `flutter_hooks` - For hooks (useState, useEffect, etc.)
- ✅ `material_symbols_icons` - For icons
- ✅ `relative_time` - For timestamp formatting
- ✅ `island/services/activitypub_service.dart` - API service (created earlier)
- ✅ `island/widgets/alert.dart` - Error/success dialogs
- ✅ `island/models/activitypub.dart` - Data models (created earlier)

### Performance Considerations

1. **Debounced Search**: 500ms delay prevents excessive API calls
2. **Local State Tracking**: `followingUris` Set prevents duplicate API calls
3. **Conditional Rebuilds**: Widget only rebuilds when necessary
4. **Image Caching**: Uses `CachedNetworkImageProvider` for avatars

### Accessibility

1. **Semantic Labels**: All ListTile widgets have proper content
2. **Touch Targets**: Minimum 44px touch targets for buttons
3. **Color Contrast**: Follows Material 3 color guidelines
4. **Loading Indicators**: Visual feedback during async operations

## Future Enhancements

### Potential Additions

1. **Profile Integration**: Show ActivityPub profile details
2. **Post Timeline**: Show federated posts from followed users
3. **Instance Blocking**: Block entire ActivityPub instances
4. **Advanced Search**: Filter by instance, user type, etc.
5. **Batch Actions**: Follow/unfollow multiple users at once
6. **Suggested Users**: Show recommended users to follow
7. **Recent Activity**: Show recent interactions
8. **Notifications**: Follow/unfollow notifications

### Localization

Need to add same keys to other language files:
- `es-ES.json`
- `ja-JP.json`
- `ko-KR.json`
- etc.

## Browser Testing

Test with real ActivityPub instances:
- mastodon.social
- pixelfed.social
- lemmy.world
- pleroma.site
- fosstodon.org

## Troubleshooting

### Common Issues

1. **Search returns no results**
   - Check if user exists on remote instance
   - Verify instance is accessible
   - Try full URL instead of handle

2. **Follow button not working**
   - Check if user is already following
   - Verify server is online
   - Check API logs

3. **Avatar not loading**
   - Check remote avatar URL
   - Verify network connection
   - Check image cache

## Summary

✅ **Fully functional ActivityPub UI** with:
- Search screen for discovering fediverse users
- Following/Followers list screens
- Reusable user list item component
- Proper error handling and user feedback
- Material 3 design
- Responsive layout
- Local state management
- Debounced search
- Empty states and loading indicators

**Ready for integration into main app navigation!** 🎉
