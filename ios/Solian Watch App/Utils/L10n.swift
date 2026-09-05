//  L10n.swift
//  Solian Watch App
//
// - Provides `L10n` namespace so SwiftUI views read `L10n.panelChat` etc.
//   instead of scattering `NSLocalizedString` boilerplate.
//

import Foundation

/// Typed wrapper around `NSLocalizedString` for compile-time key safety.
public enum L10n {
    // MARK: - ContentView (Sidebar / Navigation)
    static let panelExplore = NSLocalizedString("panel.explore", comment: "Explore panel title")
    static let panelChat = NSLocalizedString("panel.chat", comment: "Chat panel title")
    static let panelNotifications = NSLocalizedString("panel.notifications", comment: "Notifications panel title")
    static let panelAccount = NSLocalizedString("panel.account", comment: "Account panel title")
    static let panelCheckIn = NSLocalizedString("panel.checkIn", comment: "Check In panel title")
    static let panelSelectPanel = NSLocalizedString("panel.selectPanel", comment: "Placeholder when no panel selected")

    // MARK: - SignInView
    static let signInTitle = NSLocalizedString("signin.title", comment: "Sign-in navigation title")
    static let signInWelcomeTitle = NSLocalizedString("signin.welcome.title", comment: "Welcome headline")
    static let signInWelcomeSubtitle = NSLocalizedString("signin.welcome.subtitle", comment: "Welcome subtitle")
    static let signInGetStarted = NSLocalizedString("signin.getStarted", comment: "Get started button")
    static let signInStarting = NSLocalizedString("signin.starting", comment: "Starting phase")
    static let signInSigningIn = NSLocalizedString("signin.signingIn", comment: "Signing in phase")
    static let signInEnterCode = NSLocalizedString("signin.enterCode", comment: "Enter code on phone prompt")
    static let signInOpenVerification = NSLocalizedString("signin.openVerification", comment: "Open verification page button")
    static let signInCancel = NSLocalizedString("signin.cancel", comment: "Cancel button")
    static let signInApprovedOnPhone = NSLocalizedString("signin.approvedOnPhone", comment: "Approved on phone")
    static let signInApproveOnPhone = NSLocalizedString("signin.approveOnPhone", comment: "Approve on phone")
    static let signInTimedOut = NSLocalizedString("signin.timedOut", comment: "Timed out")

    // MARK: - AppInfoHeaderView
    static let connectionConnected = NSLocalizedString("connection.connected", comment: "Connected state")
    static let connectionConnecting = NSLocalizedString("connection.connecting", comment: "Connecting state")
    static let connectionDisconnected = NSLocalizedString("connection.disconnected", comment: "Disconnected state")
    static let connectionServerDown = NSLocalizedString("connection.serverDown", comment: "Server down state")
    static let connectionDuplicateDevice = NSLocalizedString("connection.duplicateDevice", comment: "Duplicate device state")
    static let connectionError = NSLocalizedString("connection.error", comment: "Error state with message")

    // MARK: - ExploreView
    static let exploreLoading = NSLocalizedString("explore.loading", comment: "Loading state")
    static let exploreCompose = NSLocalizedString("explore.compose", comment: "Compose button")
    static let exploreShuffle = NSLocalizedString("explore.shuffle", comment: "Shuffle posts button")
    static let explorePublishers = NSLocalizedString("explore.publishers", comment: "Manage publishers button")
    static let exploreBrowseCategories = NSLocalizedString("explore.browseCategories", comment: "Browse categories button")

    // MARK: - NotificationView
    static let notificationsTitle = NSLocalizedString("notifications.title", comment: "Notifications title")
    static let notificationsError = NSLocalizedString("notifications.error", comment: "Error state")
    static let notificationsRetry = NSLocalizedString("notifications.retry", comment: "Retry button")
    static let notificationsEmpty = NSLocalizedString("notifications.empty", comment: "Empty state")
    static let notificationsLoadMore = NSLocalizedString("notifications.loadMore", comment: "Load more button")
    static let notificationsDetailTitle = NSLocalizedString("notifications.detail.title", comment: "Detail title")
    static let notificationsUnread = NSLocalizedString("notifications.unread", comment: "Unread label")

    // MARK: - AccountView
    static let accountTitle = NSLocalizedString("account.title", comment: "Account title")
    static let accountFailedToLoad = NSLocalizedString("account.failedToLoad", comment: "Failed to load")
    static let accountStatus = NSLocalizedString("account.status", comment: "Status label")
    static let accountClearStatus = NSLocalizedString("account.clearStatus", comment: "Clear status dialog title")
    static let accountClearStatusMessage = NSLocalizedString("account.clearStatus.message", comment: "Clear status message")
    static let accountClearStatusButton = NSLocalizedString("account.clearStatus.button", comment: "Clear status button")
    static let accountCancel = NSLocalizedString("account.cancel", comment: "Cancel button")
    static let accountNoStatus = NSLocalizedString("account.noStatus", comment: "No status")
    static let accountNoStatusSet = NSLocalizedString("account.noStatusSet", comment: "No status set")
    static let accountInvisible = NSLocalizedString("account.invisible", comment: "Invisible status")
    static let accountDoNotDisturb = NSLocalizedString("account.doNotDisturb", comment: "Do not disturb")
    static let accountClearsAt = NSLocalizedString("account.clearsAt", comment: "Clears at time")
    static let accountLevel = NSLocalizedString("account.level", comment: "Level label")
    static let accountExperience = NSLocalizedString("account.experience", comment: "Experience label")
    static let accountNoBio = NSLocalizedString("account.noBio", comment: "No bio")
    static let accountJoinedAt = NSLocalizedString("account.joinedAt", comment: "Joined at")
    static let accountNoAccountData = NSLocalizedString("account.noAccountData", comment: "No account data")
    static let accountSignOut = NSLocalizedString("account.signOut", comment: "Sign out")
    static let accountSignOutAccessibility = NSLocalizedString("account.signOut.accessibility", comment: "Sign out accessibility")

    // MARK: - CheckInView
    static let checkInTitle = NSLocalizedString("checkin.title", comment: "Check-in title")
    static let checkInCouldntLoad = NSLocalizedString("checkin.couldntLoad", comment: "Couldn't load")
    static let checkInRetry = NSLocalizedString("checkin.retry", comment: "Retry button")
    static let checkInCheckInToday = NSLocalizedString("checkin.checkInToday", comment: "Check in today")
    static let checkInDescription = NSLocalizedString("checkin.description", comment: "Check-in description")
    static let checkInCheckIn = NSLocalizedString("checkin.checkIn", comment: "Check in button")
    static let checkInLevel = NSLocalizedString("checkin.level", comment: "Level label")
    static let checkInCheckedIn = NSLocalizedString("checkin.checkedIn", comment: "Checked in date")

    // MARK: - ChatView
    static let chatTitle = NSLocalizedString("chat.title", comment: "Chat title")
    static let chatTabAll = NSLocalizedString("chat.tab.all", comment: "All tab")
    static let chatTabDirect = NSLocalizedString("chat.tab.direct", comment: "Direct tab")
    static let chatTabGroup = NSLocalizedString("chat.tab.group", comment: "Group tab")
    static let chatErrorLoading = NSLocalizedString("chat.errorLoading", comment: "Error loading chats")
    static let chatRetry = NSLocalizedString("chat.retry", comment: "Retry button")
    static let chatNoChats = NSLocalizedString("chat.noChats", comment: "No chats yet")
    static let chatDirectMessage = NSLocalizedString("chat.directMessage", comment: "Direct message")
    static let chatGroupChat = NSLocalizedString("chat.groupChat", comment: "Group chat")
    static let chatAttachment = NSLocalizedString("chat.attachment", comment: "Attachment")
    static let chatInvites = NSLocalizedString("chat.invites", comment: "Invites")
    static let chatNoInvites = NSLocalizedString("chat.noInvites", comment: "No invites")
    static let chatOwner = NSLocalizedString("chat.owner", comment: "Owner role")
    static let chatModerator = NSLocalizedString("chat.moderator", comment: "Moderator role")
    static let chatMember = NSLocalizedString("chat.member", comment: "Member role")
    static let chatDirect = NSLocalizedString("chat.direct", comment: "Direct label")
    static let chatUnknownChat = NSLocalizedString("chat.unknownChat", comment: "Unknown chat")

    // MARK: - ChatRoomView
    static let chatRoomChat = NSLocalizedString("chatRoom.chat", comment: "Chat room title")
    static let chatRoomError = NSLocalizedString("chatRoom.error", comment: "Error state")
    static let chatRoomRetry = NSLocalizedString("chatRoom.retry", comment: "Retry button")
    static let chatRoomNoMessages = NSLocalizedString("chatRoom.noMessages", comment: "No messages yet")
    static let chatRoomLoadOlder = NSLocalizedString("chatRoom.loadOlder", comment: "Load older messages")
    static let chatRoomRead = NSLocalizedString("chatRoom.read", comment: "Read watermark label")
    static let chatRoomToday = NSLocalizedString("chatRoom.today", comment: "Today divider")
    static let chatRoomYesterday = NSLocalizedString("chatRoom.yesterday", comment: "Yesterday divider")
    static let chatRoomMessages = NSLocalizedString("chatRoom.messages", comment: "Messages")
    static let chatRoomMoreComposeOptions = NSLocalizedString("chatRoom.moreComposeOptions", comment: "More compose options")
    static let chatRoomChooseContentType = NSLocalizedString("chatRoom.chooseContentType", comment: "Choose content type")
    static let chatRoomSend = NSLocalizedString("chatRoom.send", comment: "Send")
    static let chatRoomSendMessage = NSLocalizedString("chatRoom.sendMessage", comment: "Send message")

    // MARK: - MessageBubbleView
    static let chatRoomDeletedMessage = NSLocalizedString("chatRoom.deletedMessage", comment: "Deleted message")
    static let chatRoomSending = NSLocalizedString("chatRoom.sending", comment: "Sending")
    static let chatRoomFailed = NSLocalizedString("chatRoom.failed", comment: "Failed")
    static let chatRoomEdited = NSLocalizedString("chatRoom.edited", comment: "Edited")
    static let chatRoomRepliedTo = NSLocalizedString("chatRoom.repliedTo", comment: "Replied to")
    static let chatRoomForwardedFrom = NSLocalizedString("chatRoom.forwardedFrom", comment: "Forwarded from")
    static let chatRoomRepliedToMessage = NSLocalizedString("chatRoom.repliedToMessage", comment: "Replied to message")
    static let chatRoomForwardedMessage = NSLocalizedString("chatRoom.forwardedMessage", comment: "Forwarded message")
    static let chatRoomMoreAttachments = NSLocalizedString("chatRoom.moreAttachments", comment: "More attachments")

    // MARK: - VoiceMessageView
    static let voicePlay = NSLocalizedString("voice.play", comment: "Play voice message")
    static let voicePause = NSLocalizedString("voice.pause", comment: "Pause voice message")

    // MARK: - VoiceRecorderView
    static let voiceRecording = NSLocalizedString("voice.recording", comment: "Recording state")
    static let voiceVoiceMessage = NSLocalizedString("voice.voiceMessage", comment: "Voice message")
    static let voiceStopRecording = NSLocalizedString("voice.stopRecording", comment: "Stop recording")
    static let voiceSendVoice = NSLocalizedString("voice.sendVoice", comment: "Send voice message")
    static let voiceCancelVoice = NSLocalizedString("voice.cancelVoice", comment: "Cancel voice message")
    static let voiceStartRecording = NSLocalizedString("voice.startRecording", comment: "Start recording")
    static let voiceStartRecordingHint = NSLocalizedString("voice.startRecording.hint", comment: "Start recording hint")
    static let voiceAudioUnavailable = NSLocalizedString("voice.audioUnavailable", comment: "Audio unavailable")
    static let voiceEnableMicrophone = NSLocalizedString("voice.enableMicrophone", comment: "Enable microphone")
    static let voiceCouldNotStartRecording = NSLocalizedString("voice.couldNotStartRecording", comment: "Could not start recording")

    // MARK: - ChatComposerActionsView
    static let composerStickers = NSLocalizedString("composer.stickers", comment: "Stickers")
    static let composerVoice = NSLocalizedString("composer.voice", comment: "Voice")
    static let composerPhoto = NSLocalizedString("composer.photo", comment: "Photo")
    static let composerLinkCloud = NSLocalizedString("composer.linkCloud", comment: "Link cloud")

    // MARK: - StickerPickerView
    static let stickersTitle = NSLocalizedString("stickers.title", comment: "Stickers title")
    static let stickersNoPacks = NSLocalizedString("stickers.noPacks", comment: "No sticker packs")
    static let stickersUnavailable = NSLocalizedString("stickers.unavailable", comment: "Stickers unavailable")
    static let stickersNoStickersInPack = NSLocalizedString("stickers.noStickersInPack", comment: "No stickers in pack")
    static let stickersStickerCount = NSLocalizedString("stickers.stickerCount", comment: "Sticker count")

    // MARK: - CloudImageLinkerView
    static let cloudImageTitle = NSLocalizedString("cloudImage.title", comment: "Link cloud image")
    static let cloudImageNoImages = NSLocalizedString("cloudImage.noImages", comment: "No cloud images")
    static let cloudImageCouldNotLoad = NSLocalizedString("cloudImage.couldNotLoad", comment: "Could not load")

    // MARK: - PhotoPickerView
    static let photoPickerSending = NSLocalizedString("photoPicker.sending", comment: "Sending photo")
    static let photoPickerLoading = NSLocalizedString("photoPicker.loading", comment: "Loading image")
    static let photoPickerCouldNotRead = NSLocalizedString("photoPicker.couldNotRead", comment: "Could not read")
    static let photoPickerCouldNotProcess = NSLocalizedString("photoPicker.couldNotProcess", comment: "Could not process")
    static let photoPickerCouldNotSave = NSLocalizedString("photoPicker.couldNotSave", comment: "Could not save")
    static let photoPickerChoosePhoto = NSLocalizedString("photoPicker.choosePhoto", comment: "Choose photo")
    static let photoPickerTryAgain = NSLocalizedString("photoPicker.tryAgain", comment: "Try again")

    // MARK: - PostViews
    static let postUnknown = NSLocalizedString("post.unknown", comment: "Unknown")
    static let postBoostedBy = NSLocalizedString("post.boostedBy", comment: "Boosted by")
    static let postAttachments = NSLocalizedString("post.attachments", comment: "Attachments")
    static let postLink = NSLocalizedString("post.link", comment: "Link")
    static let postTitle = NSLocalizedString("post.title", comment: "Post title")
    static let postInReplyTo = NSLocalizedString("post.inReplyTo", comment: "In reply to")
    static let postForwarded = NSLocalizedString("post.forwarded", comment: "Forwarded")
    static let postReplies = NSLocalizedString("post.replies", comment: "Replies")
    static let postRepliesLoadFromApp = NSLocalizedString("post.repliesLoadFromApp", comment: "Replies load from app")
    static let postLoadMoreReplies = NSLocalizedString("post.loadMoreReplies", comment: "Load more replies")
    static let postLoading = NSLocalizedString("post.loading", comment: "Loading")
    static let postLess = NSLocalizedString("post.less", comment: "Less")
    static let postReply = NSLocalizedString("post.reply", comment: "Reply")
    static let postForward = NSLocalizedString("post.forward", comment: "Forward")
    static let postBoost = NSLocalizedString("post.boost", comment: "Boost")
    static let postBookmark = NSLocalizedString("post.bookmark", comment: "Bookmark")
    static let postRemoveBookmark = NSLocalizedString("post.removeBookmark", comment: "Remove bookmark")
    static let postUnknownActivity = NSLocalizedString("post.unknownActivity", comment: "Unknown activity")

    // MARK: - ComposePostView
    static let composeNewPost = NSLocalizedString("compose.newPost", comment: "New post")
    static let composeReply = NSLocalizedString("compose.reply", comment: "Reply")
    static let composeForward = NSLocalizedString("compose.forward", comment: "Forward")
    static let composeReplyingTo = NSLocalizedString("compose.repilingTo", comment: "Replying to")
    static let composeForwarding = NSLocalizedString("compose.forwarding", comment: "Forwarding")
    static let composeContent = NSLocalizedString("compose.content", comment: "Content")
    static let composeContentPlaceholder = NSLocalizedString("compose.contentPlaceholder", comment: "Content placeholder")
    static let composeVisibility = NSLocalizedString("compose.visibility", comment: "Visibility")
    static let composeVisibilityPublic = NSLocalizedString("compose.visibility.public", comment: "Public")
    static let composeVisibilityFriends = NSLocalizedString("compose.visibility.friends", comment: "Friends")
    static let composeVisibilityUnlisted = NSLocalizedString("compose.visibility.unlisted", comment: "Unlisted")
    static let composeVisibilityPrivate = NSLocalizedString("compose.visibility.private", comment: "Private")
    static let composeSelectVisibility = NSLocalizedString("compose.selectVisibility", comment: "Select visibility")
    static let composeCancel = NSLocalizedString("compose.cancel", comment: "Cancel")
    static let composePosting = NSLocalizedString("compose.posting", comment: "Posting")
    static let composeError = NSLocalizedString("compose.error", comment: "Error")

    // MARK: - ActivityListView
    static let activityErrorFetching = NSLocalizedString("activity.errorFetching", comment: "Error fetching data")
    static let activityNoActivities = NSLocalizedString("activity.noActivities", comment: "No activities")
    static let activityLoadMore = NSLocalizedString("activity.loadMore", comment: "Load more")
    static let activityExplore = NSLocalizedString("activity.explore", comment: "Explore")

    // MARK: - ActivityEventRow
    static let activityFriendUpdatedStatus = NSLocalizedString("activity.friendUpdatedStatus", comment: "Friend updated status")
    static let activityFriendActivity = NSLocalizedString("activity.friendActivity", comment: "Friend activity")
    static let activityGaming = NSLocalizedString("activity.gaming", comment: "Gaming")
    static let activityMusic = NSLocalizedString("activity.music", comment: "Music")
    static let activityWorkout = NSLocalizedString("activity.workout", comment: "Workout")
    static let activityBusy = NSLocalizedString("activity.busy", comment: "Busy")
    static let activityDoNotDisturb = NSLocalizedString("activity.doNotDisturb", comment: "Do not disturb")
    static let activityInvisible = NSLocalizedString("activity.invisible", comment: "Invisible")
    static let activityOnline = NSLocalizedString("activity.online", comment: "Online")

    // MARK: - AttachmentView
    static let attachmentFile = NSLocalizedString("attachment.file", comment: "File")
    static let attachmentFailedToLoad = NSLocalizedString("attachment.failedToLoad", comment: "Failed to load")
    static let attachmentTryAgain = NSLocalizedString("attachment.tryAgain", comment: "Try again")
    static let attachmentLoading = NSLocalizedString("attachment.loading", comment: "Loading")

    // MARK: - ImageViewer
    static let imageViewerLoading = NSLocalizedString("imageViewer.loading", comment: "Loading")
    static let imageViewerFailedToLoad = NSLocalizedString("imageViewer.failedToLoad", comment: "Failed to load")
    static let imageViewerTryAgain = NSLocalizedString("imageViewer.tryAgain", comment: "Try again")

    // MARK: - AudioPlayerView
    static let audioPlayerLoading = NSLocalizedString("audioPlayer.loading", comment: "Loading audio")

    // MARK: - ReactionSheetView
    static let reactionReact = NSLocalizedString("reaction.react", comment: "React")
    static let reactionPositive = NSLocalizedString("reaction.positive", comment: "Positive")
    static let reactionNeutral = NSLocalizedString("reaction.neutral", comment: "Neutral")
    static let reactionNegative = NSLocalizedString("reaction.negative", comment: "Negative")

    // MARK: - DiscoveryViews
    static let discoveryRealm = NSLocalizedString("discovery.realm", comment: "Realm")
    static let discoveryPublisher = NSLocalizedString("discovery.publisher", comment: "Publisher")
    static let discoveryAccount = NSLocalizedString("discovery.account", comment: "Account")
    static let discoveryArticle = NSLocalizedString("discovery.article", comment: "Article")
    static let discoveryUnknownSuggestion = NSLocalizedString("discovery.unknownSuggestion", comment: "Unknown suggestion")
    static let discoveryGood = NSLocalizedString("discovery.good", comment: "Good")
    static let discoveryThanks = NSLocalizedString("discovery.thanks", comment: "Thanks")
    static let discoveryNotForMe = NSLocalizedString("discovery.notForMe", comment: "Not for me")
    static let discoveryShowMoreLikeThis = NSLocalizedString("discovery.showMoreLikeThis", comment: "Show more like this")
    static let discoveryNotInterested = NSLocalizedString("discovery.notInterested", comment: "Not interested")

    // MARK: - ExploreExtrasViews
    static let explorePublishersTitle = NSLocalizedString("explore.publishers", comment: "Publishers")
    static let exploreLoadingPublishers = NSLocalizedString("explore.loadingPublishers", comment: "Loading publishers")
    static let exploreCouldntLoadPublishers = NSLocalizedString("explore.couldntLoadPublishers", comment: "Couldn't load publishers")
    static let exploreNotFollowingAnyPublishers = NSLocalizedString("explore.notFollowingAnyPublishers", comment: "Not following any publishers")
    static let exploreUnfollow = NSLocalizedString("explore.unfollow", comment: "Unfollow")
    static let exploreCategories = NSLocalizedString("explore.categories", comment: "Categories")
    static let exploreTags = NSLocalizedString("explore.tags", comment: "Tags")
    static let exploreCategoriesAndTags = NSLocalizedString("explore.categoriesAndTags", comment: "Categories & tags")
    static let exploreCouldntLoadCategories = NSLocalizedString("explore.couldntLoadCategories", comment: "Couldn't load categories")
    static let exploreNothingHereYet = NSLocalizedString("explore.nothingHereYet", comment: "Nothing here yet")
    static let exploreFollow = NSLocalizedString("explore.follow", comment: "Follow")
    static let exploreNoPostsYet = NSLocalizedString("explore.noPostsYet", comment: "No posts yet")
    static let exploreCouldntLoadPosts = NSLocalizedString("explore.couldntLoadPosts", comment: "Couldn't load posts")

    // MARK: - StatusCreationView
    static let statusTitle = NSLocalizedString("status.title", comment: "Status")
    static let statusSetStatus = NSLocalizedString("status.setStatus", comment: "Set status")
    static let statusUpdateStatus = NSLocalizedString("status.updateStatus", comment: "Update status")
    static let statusLabel = NSLocalizedString("status.label", comment: "Status label")
    static let statusSymbol = NSLocalizedString("status.symbol", comment: "Status symbol")
    static let statusMood = NSLocalizedString("status.mood", comment: "Mood")
    static let statusAttitudePositive = NSLocalizedString("status.attitude.positive", comment: "Positive attitude")
    static let statusAttitudeNeutral = NSLocalizedString("status.attitude.neutral", comment: "Neutral attitude")
    static let statusAttitudeNegative = NSLocalizedString("status.attitude.negative", comment: "Negative attitude")
    static let statusVisibility = NSLocalizedString("status.visibility", comment: "Visibility")
    static let statusTypeOnline = NSLocalizedString("status.type.online", comment: "Online")
    static let statusTypeBusy = NSLocalizedString("status.type.busy", comment: "Busy")
    static let statusTypeDoNotDisturb = NSLocalizedString("status.type.doNotDisturb", comment: "Do not disturb")
    static let statusTypeInvisible = NSLocalizedString("status.type.invisible", comment: "Invisible")
    static let statusAutoClearTime = NSLocalizedString("status.autoClearTime", comment: "Auto-clear time")
    static let statusNoAutoClear = NSLocalizedString("status.noAutoClear", comment: "No auto-clear")
    static let statusCancel = NSLocalizedString("status.cancel", comment: "Cancel")
    static let statusSave = NSLocalizedString("status.save", comment: "Save")
    static let statusSaving = NSLocalizedString("status.saving", comment: "Saving")
    static let statusDelete = NSLocalizedString("status.delete", comment: "Delete status")
    static let statusAuthenticationError = NSLocalizedString("status.authenticationError", comment: "Authentication error")

    // MARK: - Fortune Grid
    static let fortuneLove = NSLocalizedString("fortune.love", comment: "Love")
    static let fortuneStudy = NSLocalizedString("fortune.study", comment: "Study")
    static let fortuneWork = NSLocalizedString("fortune.work", comment: "Work")
    static let fortuneHealth = NSLocalizedString("fortune.health", comment: "Health")
}
