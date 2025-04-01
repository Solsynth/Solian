import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surface/providers/post.dart';
import 'package:surface/providers/sn_attachment.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/attachment.dart';
import 'package:surface/types/poll.dart';
import 'package:surface/types/post.dart';
import 'package:surface/types/realm.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/universal_image.dart';
import 'package:video_compress/video_compress.dart';

class PostWriteMedia {
  late String name;
  late SnMediaType type;
  final SnAttachment? attachment;
  final XFile? file;
  final Uint8List? raw;

  PostWriteMedia? thumbnail;

  PostWriteMedia(this.attachment, {this.file, this.raw}) {
    name = attachment!.name;

    switch (attachment?.mimetype.split('/').firstOrNull) {
      case 'image':
        type = SnMediaType.image;
        break;
      case 'video':
        type = SnMediaType.video;
        break;
      case 'audio':
        type = SnMediaType.audio;
        break;
      default:
        type = SnMediaType.file;
    }
  }

  PostWriteMedia.fromFile(this.file, {this.attachment, this.raw}) {
    name = file!.name;

    String? mimetype = file!.mimeType;
    mimetype ??= lookupMimeType(file!.path);

    switch (mimetype?.split('/').firstOrNull) {
      case 'image':
        type = SnMediaType.image;
        break;
      case 'video':
        type = SnMediaType.video;
        break;
      case 'audio':
        type = SnMediaType.audio;
        break;
      default:
        type = SnMediaType.file;
    }
  }

  PostWriteMedia.fromBytes(this.raw, this.name, this.type,
      {this.attachment, this.file});

  bool get isEmpty => attachment == null && file == null && raw == null;

  Future<int?> length() async {
    if (attachment != null) {
      return attachment!.size;
    } else if (file != null) {
      return await file!.length();
    } else if (raw != null) {
      return raw!.length;
    }
    return null;
  }

  XFile? toFile() {
    if (file != null) {
      return file!;
    } else if (raw != null) {
      return XFile.fromData(
        raw!,
        name: name,
      );
    }
    return null;
  }

  ImageProvider? getImageProvider(
    BuildContext context, {
    int? width,
    int? height,
  }) {
    if (attachment != null) {
      final sn = context.read<SnNetworkProvider>();
      final ImageProvider provider =
          UniversalImage.provider(sn.getAttachmentUrl(attachment!.rid));
      if (width != null && height != null && !kIsWeb) {
        return ResizeImage(
          provider,
          width: width,
          height: height,
          policy: ResizeImagePolicy.fit,
        );
      }
      return provider;
    } else if (file != null) {
      final ImageProvider provider =
          kIsWeb ? NetworkImage(file!.path) : FileImage(File(file!.path));
      if (width != null && height != null) {
        return ResizeImage(
          provider,
          width: width,
          height: height,
          policy: ResizeImagePolicy.fit,
        );
      }
      return provider;
    } else if (raw != null) {
      final provider = MemoryImage(raw!);
      if (width != null && height != null) {
        return ResizeImage(
          provider,
          width: width,
          height: height,
          policy: ResizeImagePolicy.fit,
        );
      }
      return provider;
    }
    return null;
  }
}

class PostWriteController extends ChangeNotifier {
  static const Map<String, String> kTitleMap = {
    'stories': 'writePostTypeStory',
    'articles': 'writePostTypeArticle',
    'questions': 'writePostTypeQuestion',
    'videos': 'writePostTypeVideo',
  };

  static const kAttachmentProgressWeight = 0.9;
  static const kPostingProgressWeight = 0.1;

  final TextEditingController contentController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController aliasController = TextEditingController();
  final TextEditingController rewardController = TextEditingController();

  ContentInsertionConfiguration get contentInsertionConfiguration =>
      ContentInsertionConfiguration(
        onContentInserted: (KeyboardInsertedContent content) {
          if (content.hasData) {
            addAttachments([
              PostWriteMedia.fromBytes(content.data!,
                  'attachmentInsertedImage'.tr(), SnMediaType.image)
            ]);
          }
        },
      );

  bool _temporarySaveActive = false;

  PostWriteController({bool doLoadFromTemporary = true}) {
    _temporarySaveActive = doLoadFromTemporary;
    titleController.addListener(() {
      _temporaryPlanSave();
      notifyListeners();
    });
    descriptionController.addListener(() {
      _temporaryPlanSave();
      notifyListeners();
    });
    contentController.addListener(() {
      _temporaryPlanSave();
      notifyListeners();
    });
    if (doLoadFromTemporary) _temporaryLoad();
  }

  String mode = kTitleMap.keys.first;

  String get title => titleController.text;

  String get description => descriptionController.text;

  bool get isRelatedNull =>
      ![editingPost, repostingPost, replyingPost].any((ele) => ele != null);

  bool isLoading = false, isBusy = false;
  double? progress;

  SnRealm? realm;
  SnPublisher? publisher;
  SnPost? editingPost, repostingPost, replyingPost;
  bool editingDraft = false;

  int visibility = 0;
  List<int> visibleUsers = List.empty();
  List<int> invisibleUsers = List.empty();
  List<String> tags = List.empty();
  List<String> categories = List.empty();
  PostWriteMedia? thumbnail;
  List<PostWriteMedia> attachments = List.empty(growable: true);
  DateTime? publishedAt, publishedUntil;
  SnAttachment? videoAttachment;
  SnPoll? poll;

  Future<void> fetchRelatedPost(
    BuildContext context, {
    int? editing,
    int? reposting,
    int? replying,
  }) async {
    final pt = context.read<SnPostContentProvider>();

    isLoading = true;
    notifyListeners();

    try {
      if (editing != null) {
        final post = await pt.getPost(editing);
        publisher = post.publisher;
        titleController.text = post.body['title'] ?? '';
        descriptionController.text = post.body['description'] ?? '';
        contentController.text = post.body['content'] ?? '';
        aliasController.text = post.alias ?? '';
        rewardController.text = post.body['reward']?.toString() ?? '';
        videoAttachment = post.body['video'] != null
            ? SnAttachment.fromJson(post.body['video'])
            : null;
        publishedAt = post.publishedAt;
        publishedUntil = post.publishedUntil;
        visibleUsers = List.from(post.visibleUsersList ?? [], growable: true);
        invisibleUsers =
            List.from(post.invisibleUsersList ?? [], growable: true);
        visibility = post.visibility;
        tags = List.from(post.tags.map((ele) => ele.alias), growable: true);
        categories =
            List.from(post.categories.map((ele) => ele.alias), growable: true);
        attachments.addAll(
          post.body['attachments']
                  ?.map((ele) => SnAttachment.fromJson(ele))
                  ?.map((ele) => PostWriteMedia(ele))
                  ?.cast<PostWriteMedia>() ??
              [],
        );
        poll = post.poll;

        editingDraft = post.isDraft;

        if (post.body['thumbnail'] != null) {
          thumbnail =
              PostWriteMedia(SnAttachment.fromJson(post.body['thumbnail']));
        }
        if (post.realm != null) {
          realm = post.realm!;
        }

        editingPost = post;
      }

      if (replying != null) {
        final post = await pt.getPost(replying);
        replyingPost = post;
      }

      if (reposting != null) {
        final post = await pt.getPost(reposting);
        repostingPost = post;
      }
    } catch (err) {
      if (!context.mounted) return;
      context.showErrorDialog(err);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<SnAttachment> _uploadAttachment(
      BuildContext context, PostWriteMedia media,
      {bool isCompressed = false}) async {
    final attach = context.read<SnAttachmentProvider>();

    final place = await attach.chunkedUploadInitialize(
      (await media.length())!,
      media.name,
      'interactive',
      null,
      mimetype: media.raw != null && media.type == SnMediaType.image
          ? 'image/png'
          : null,
    );

    var item = await attach.chunkedUploadParts(
      media.toFile()!,
      place.$1,
      place.$2,
      analyzeNow: media.type == SnMediaType.image,
      onProgress: (value) {
        progress = value;
        notifyListeners();
      },
    );

    if (media.type == SnMediaType.video && !isCompressed && context.mounted) {
      try {
        final compressedAttachment =
            await _tryCompressVideoCopy(context, media);
        if (compressedAttachment != null) {
          item = await attach.updateOne(item,
              compressedId: compressedAttachment.id);
        }
      } catch (err) {
        if (context.mounted) context.showErrorDialog(err);
      }
    }

    return item;
  }

  Future<SnAttachment?> _tryCompressVideoCopy(
      BuildContext context, PostWriteMedia media) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS || Platform.isMacOS))
      return null;
    if (media.type != SnMediaType.video) return null;
    if (media.file == null) return null;
    if (VideoCompress.isCompressing) return null;

    final confirm = await context.showConfirmDialog(
      'attachmentVideoCompressHint'.tr(),
      'attachmentVideoCompressHintDescription'.tr(args: [media.file!.name]),
    );
    if (!confirm) return null;

    progress = null;
    notifyListeners();

    final mediaInfo = await VideoCompress.compressVideo(
      media.file!.path,
      quality: VideoQuality.LowQuality,
      frameRate: 30,
      deleteOrigin: false,
    );
    if (mediaInfo == null) return null;
    if (!context.mounted) return null;

    final compressedMedia = PostWriteMedia.fromFile(XFile(mediaInfo.path!));
    final compressedAttachment =
        await _uploadAttachment(context, compressedMedia, isCompressed: true);

    return compressedAttachment;
  }

  static const kTemporaryStorageKey = 'int_draft_post';

  Timer? _temporarySaveTimer;

  void _temporaryPlanSave() {
    if (!_temporarySaveActive) return;
    _temporarySaveTimer?.cancel();
    _temporarySaveTimer = Timer(const Duration(seconds: 1), () {
      _temporarySave();
      log("[PostWriter] Temporary save saved.");
    });
  }

  void _temporarySave() {
    SharedPreferences.getInstance().then((prefs) {
      if (titleController.text.isEmpty &&
          descriptionController.text.isEmpty &&
          contentController.text.isEmpty &&
          thumbnail == null &&
          attachments.isEmpty) {
        prefs.remove(kTemporaryStorageKey);
        return;
      }

      prefs.setString(
        kTemporaryStorageKey,
        jsonEncode({
          'publisher': publisher,
          'content': contentController.text,
          if (aliasController.text.isNotEmpty) 'alias': aliasController.text,
          if (titleController.text.isNotEmpty) 'title': titleController.text,
          if (descriptionController.text.isNotEmpty)
            'description': descriptionController.text,
          if (rewardController.text.isNotEmpty) 'reward': rewardController.text,
          if (thumbnail != null && thumbnail!.attachment != null)
            'thumbnail': thumbnail!.attachment!.toJson(),
          'attachments': attachments
              .where((e) => e.attachment != null)
              .map((e) => e.attachment!.toJson())
              .toList(growable: true),
          'tags': tags.map((ele) => {'alias': ele}).toList(growable: true),
          'categories':
              categories.map((ele) => {'alias': ele}).toList(growable: true),
          'visibility': visibility,
          'visible_users_list': visibleUsers,
          'invisible_users_list': invisibleUsers,
          if (publishedAt != null)
            'published_at': publishedAt!.toUtc().toIso8601String(),
          if (publishedUntil != null)
            'published_until': publishedAt!.toUtc().toIso8601String(),
          if (replyingPost != null) 'reply_to': replyingPost!.toJson(),
          if (repostingPost != null) 'repost_to': repostingPost!.toJson(),
          if (poll != null) 'poll': poll!.toJson(),
          if (realm != null) 'realm': realm!.toJson(),
        }),
      );
    });
  }

  bool get isNotEmpty =>
      title.isNotEmpty ||
      description.isNotEmpty ||
      contentController.text.isNotEmpty ||
      attachments.isNotEmpty;

  bool temporaryRestored = false;

  void _temporaryLoad() {
    SharedPreferences.getInstance().then((prefs) {
      final raw = prefs.getString(kTemporaryStorageKey);
      if (raw == null) return;
      final data = jsonDecode(raw);
      contentController.text = data['content'];
      aliasController.text = data['alias'] ?? '';
      titleController.text = data['title'] ?? '';
      descriptionController.text = data['description'] ?? '';
      rewardController.text = data['reward']?.toString() ?? '';
      if (data['thumbnail'] != null)
        thumbnail = PostWriteMedia(SnAttachment.fromJson(data['thumbnail']));
      attachments.addAll(data['attachments']
          .map((ele) => PostWriteMedia(SnAttachment.fromJson(ele)))
          .cast<PostWriteMedia>());
      tags = List.from(data['tags'].map((ele) => ele['alias']));
      categories = List.from(data['categories'].map((ele) => ele['alias']));
      visibility = data['visibility'];
      visibleUsers = List.from(data['visible_users_list'] ?? []);
      invisibleUsers = List.from(data['invisible_users_list'] ?? []);
      if (data['published_at'] != null)
        publishedAt = DateTime.tryParse(data['published_at'])?.toLocal();
      if (data['published_until'] != null)
        publishedUntil = DateTime.tryParse(data['published_until'])?.toLocal();
      replyingPost =
          data['reply_to'] != null ? SnPost.fromJson(data['reply_to']) : null;
      repostingPost =
          data['repost_to'] != null ? SnPost.fromJson(data['repost_to']) : null;
      poll = data['poll'] != null ? SnPoll.fromJson(data['poll']) : null;
      realm = data['realm'] != null ? SnRealm.fromJson(data['realm']) : null;
      temporaryRestored = true;
      notifyListeners();
    });
  }

  Future<void> uploadSingleAttachment(BuildContext context, int idx) async {
    if (isBusy) return;

    final media = idx == -1 ? thumbnail! : attachments[idx];
    isBusy = true;
    notifyListeners();

    final item = await _uploadAttachment(context, media);
    attachments[idx] = PostWriteMedia(item);
    isBusy = false;

    notifyListeners();
  }

  Future<void> sendPost(
    BuildContext context, {
    bool saveAsDraft = false,
  }) async {
    if (isBusy || publisher == null) return;

    final sn = context.read<SnNetworkProvider>();
    final attach = context.read<SnAttachmentProvider>();

    progress = 0;
    isBusy = true;
    notifyListeners();

    // Uploading attachments
    try {
      if (thumbnail != null && thumbnail!.attachment == null) {
        final thumb = await _uploadAttachment(context, thumbnail!);
        thumbnail = PostWriteMedia(thumb);
      }

      for (int i = 0; i < attachments.length; i++) {
        final media = attachments[i];
        if (media.attachment != null) continue; // Already uploaded, skip
        if (media.isEmpty) continue; // Nothing to do, skip

        final place = await attach.chunkedUploadInitialize(
          (await media.length())!,
          media.name,
          'interactive',
          null,
          mimetype: media.raw != null && media.type == SnMediaType.image
              ? 'image/png'
              : null,
        );

        var item = await attach.chunkedUploadParts(
          media.toFile()!,
          place.$1,
          place.$2,
          onProgress: (value) {
            // Calculate overall progress for attachments
            progress = math.max(
                ((i + value) / attachments.length) * kAttachmentProgressWeight,
                value);
            notifyListeners();
          },
        );

        try {
          if (context.mounted) {
            final compressedAttachment =
                await _tryCompressVideoCopy(context, media);
            if (compressedAttachment != null) {
              item = await attach.updateOne(item,
                  compressedId: compressedAttachment.id);
            }
          }
        } catch (err) {
          if (context.mounted) context.showErrorDialog(err);
        }

        progress = (i + 1) / attachments.length * kAttachmentProgressWeight;
        attachments[i] = PostWriteMedia(item);
        notifyListeners();
      }
    } catch (err) {
      isBusy = false;
      notifyListeners();
      if (!context.mounted) return;
      context.showErrorDialog(err);
      return;
    }

    progress = kAttachmentProgressWeight;
    notifyListeners();

    final reward = double.tryParse(rewardController.text);

    // Posting the content
    try {
      final baseProgressVal = progress!;
      final resp = await sn.client.request(
        [
          '/cgi/co/$mode',
          if (editingPost != null) '${editingPost!.id}',
        ].join('/'),
        data: {
          'publisher': publisher!.id,
          'content': contentController.text,
          if (aliasController.text.isNotEmpty) 'alias': aliasController.text,
          if (titleController.text.isNotEmpty) 'title': titleController.text,
          if (descriptionController.text.isNotEmpty)
            'description': descriptionController.text,
          if (thumbnail != null && thumbnail!.attachment != null)
            'thumbnail': thumbnail!.attachment!.rid,
          'attachments': attachments
              .where((e) => e.attachment != null)
              .map((e) => e.attachment!.rid)
              .toList(),
          'tags': tags.map((ele) => {'alias': ele}).toList(),
          'categories': categories.map((ele) => {'alias': ele}).toList(),
          'visibility': visibility,
          'visible_users_list': visibleUsers,
          'invisible_users_list': invisibleUsers,
          if (publishedAt != null)
            'published_at': publishedAt!.toUtc().toIso8601String(),
          if (publishedUntil != null)
            'published_until': publishedAt!.toUtc().toIso8601String(),
          if (replyingPost != null) 'reply_to': replyingPost!.id,
          if (repostingPost != null) 'repost_to': repostingPost!.id,
          if (reward != null) 'reward': reward,
          if (videoAttachment != null) 'video': videoAttachment!.rid,
          if (poll != null) 'poll': poll!.id,
          if (realm != null) 'realm': realm!.id,
          'is_draft': saveAsDraft,
        },
        onSendProgress: (count, total) {
          progress =
              baseProgressVal + (count / total) * (kPostingProgressWeight / 2);
          notifyListeners();
        },
        onReceiveProgress: (count, total) {
          progress = baseProgressVal +
              (kPostingProgressWeight / 2) +
              (count / total) * (kPostingProgressWeight / 2);
          notifyListeners();
        },
        options: Options(
          method: editingPost != null ? 'PUT' : 'POST',
        ),
      );
      if (saveAsDraft) {
        if (!context.mounted) return;
        editingDraft = true;
        final out = SnPost.fromJson(resp.data);
        final pt = context.read<SnPostContentProvider>();
        editingPost = await pt.completePostData(out);
        notifyListeners();
      } else {
        reset();
      }
    } catch (err) {
      if (!context.mounted) return;
      context.showErrorDialog(err);
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  void addAttachments(Iterable<PostWriteMedia> items) {
    attachments.addAll(items);
    notifyListeners();
  }

  void setAttachmentAt(int idx, PostWriteMedia item) {
    if (idx == -1) {
      thumbnail = item;
    } else {
      attachments[idx] = item;
    }
    notifyListeners();
  }

  void removeAttachmentAt(int idx) {
    if (idx == -1) {
      thumbnail = null;
    } else {
      attachments.removeAt(idx);
    }
    notifyListeners();
  }

  void setThumbnail(SnAttachment? value) {
    thumbnail = value == null ? null : PostWriteMedia(value);
    notifyListeners();
  }

  void setPublisher(SnPublisher? item) {
    publisher = item;
    _temporaryPlanSave();
    notifyListeners();
  }

  void setPublishedAt(DateTime? value) {
    publishedAt = value;
    _temporaryPlanSave();
    notifyListeners();
  }

  void setPublishedUntil(DateTime? value) {
    publishedUntil = value;
    _temporaryPlanSave();
    notifyListeners();
  }

  void setTags(List<String> value) {
    tags = value;
    _temporaryPlanSave();
    notifyListeners();
  }

  void setCategories(List<String> value) {
    categories = value;
    _temporaryPlanSave();
    notifyListeners();
  }

  void setVisibility(int value) {
    visibility = value;
    _temporaryPlanSave();
    notifyListeners();
  }

  void setVisibleUsers(List<int> value) {
    visibleUsers = value;
    _temporaryPlanSave();
    notifyListeners();
  }

  void setInvisibleUsers(List<int> value) {
    invisibleUsers = value;
    _temporaryPlanSave();
    notifyListeners();
  }

  void setRealm(SnRealm? value) {
    realm = value;
    notifyListeners();
  }

  void setProgress(double? value) {
    progress = value;
    _temporaryPlanSave();
    notifyListeners();
  }

  void setIsBusy(bool value) {
    isBusy = value;
    _temporaryPlanSave();
    notifyListeners();
  }

  void setMode(String value) {
    mode = value;
    _temporaryPlanSave();
    notifyListeners();
  }

  void setVideoAttachment(SnAttachment? value) {
    videoAttachment = value;
    notifyListeners();
  }

  void setPoll(SnPoll? value) {
    poll = value;
    notifyListeners();
  }

  void reset() {
    publishedAt = null;
    publishedUntil = null;
    thumbnail = null;
    visibility = 0;
    titleController.clear();
    descriptionController.clear();
    contentController.clear();
    aliasController.clear();
    tags = List.empty(growable: true);
    categories = List.empty(growable: true);
    attachments = List.empty(growable: true);
    editingPost = null;
    replyingPost = null;
    repostingPost = null;
    mode = kTitleMap.keys.first;
    temporaryRestored = false;
    SharedPreferences.getInstance()
        .then((prefs) => prefs.remove(kTemporaryStorageKey));
    notifyListeners();
  }

  @override
  void dispose() {
    contentController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    aliasController.dispose();
    super.dispose();
  }
}
