import 'dart:io';
import 'dart:ui';

import 'package:croppy/croppy.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' show basename;
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_attachment.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/types/post.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/universal_image.dart';

class AccountPublisherEditScreen extends StatefulWidget {
  final String name;

  const AccountPublisherEditScreen({super.key, required this.name});

  @override
  State<AccountPublisherEditScreen> createState() =>
      _AccountPublisherEditScreenState();
}

class _AccountPublisherEditScreenState
    extends State<AccountPublisherEditScreen> {
  bool _isBusy = false;

  SnPublisher? _publisher;

  String? _avatar;
  String? _banner;

  final TextEditingController _nickController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _fetchPublisher() async {
    final sn = context.read<SnNetworkProvider>();
    final ua = context.read<UserProvider>();
    if (!ua.isAuthorized) return;

    setState(() => _isBusy = true);

    try {
      final resp = await sn.client.get('/cgi/co/publishers/${widget.name}');
      _publisher = SnPublisher.fromJson(resp.data);
      _syncWidget();
    } catch (err) {
      if (mounted) context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _performAction() async {
    final sn = context.read<SnNetworkProvider>();
    final ua = context.read<UserProvider>();
    if (!ua.isAuthorized) return;

    setState(() => _isBusy = true);

    try {
      await sn.client.put(
        '/cgi/co/publishers/${widget.name}',
        data: {
          'avatar': _avatar,
          'banner': _banner,
          'nick': _nickController.text,
          'name': _nameController.text,
          'description': _descriptionController.text,
        },
      );
      if (mounted) Navigator.pop(context, true);
    } catch (err) {
      if (mounted) context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  void _syncWidget() {
    _avatar = _publisher!.avatar;
    _banner = _publisher!.banner;
    _nickController.text = _publisher!.nick;
    _nameController.text = _publisher!.name;
    _descriptionController.text = _publisher!.description;
  }

  void _syncWithAccount() {
    final ua = context.read<UserProvider>();
    _avatar = ua.user!.avatar;
    _banner = ua.user!.banner;
    _nickController.text = ua.user!.nick;
    _nameController.text = ua.user!.name;
    _descriptionController.text = ua.user!.profile!.description;
    setState(() {});
  }

  final _imagePicker = ImagePicker();

  Future<void> _updateImage(String place) async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    if (!mounted) return;

    final skipCrop = image.path.endsWith('.gif');

    Uint8List? rawBytes;
    if (!skipCrop) {
      final ImageProvider imageProvider =
          kIsWeb ? NetworkImage(image.path) : FileImage(File(image.path));
      final aspectRatios = place == 'banner'
          ? [CropAspectRatio(width: 16, height: 7)]
          : [CropAspectRatio(width: 1, height: 1)];
      final result = (!kIsWeb && (Platform.isIOS || Platform.isMacOS))
          ? await showCupertinoImageCropper(
              // ignore: use_build_context_synchronously
              context,
              allowedAspectRatios: aspectRatios,
              imageProvider: imageProvider,
            )
          : await showMaterialImageCropper(
              // ignore: use_build_context_synchronously
              context,
              allowedAspectRatios: aspectRatios,
              imageProvider: imageProvider,
            );

      if (result == null) return;

      if (!mounted) return;
      setState(() => _isBusy = true);
      rawBytes = (await result.uiImage.toByteData(format: ImageByteFormat.png))!
          .buffer
          .asUint8List();
    } else {
      if (!mounted) return;
      setState(() => _isBusy = true);
      rawBytes = await image.readAsBytes();
    }

    if (!mounted) return;
    final attach = context.read<SnAttachmentProvider>();

    try {
      final attachment = await attach.directUploadOne(
        rawBytes,
        basename(image.path),
        'avatar',
        null,
        mimetype: 'image/png',
      );

      switch (place) {
        case 'avatar':
          _avatar = attachment.rid;
          break;
        case 'banner':
          _banner = attachment.rid;
          break;
      }
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPublisher();
  }

  @override
  void dispose() {
    _nickController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sn = context.read<SnNetworkProvider>();

    return AppScaffold(
      noBackground: ResponsiveScaffold.getIsExpand(context),
      appBar: AppBar(
          leading: PageBackButton(),
          title: Text('screenAccountPublisherEdit').tr()),
      body: SingleChildScrollView(
        child: Column(
          children: [
            LoadingIndicator(isActive: _isBusy),
            const Gap(24),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Material(
                  elevation: 0,
                  child: InkWell(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: AspectRatio(
                        aspectRatio: 16 / 7,
                        child: Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                          child: _banner != null
                              ? AutoResizeUniversalImage(
                                  sn.getAttachmentUrl(_banner!),
                                  fit: BoxFit.cover)
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    onTap: () {
                      _updateImage('banner');
                    },
                  ),
                ),
                Positioned(
                  bottom: -28,
                  left: 16,
                  child: Material(
                    elevation: 2,
                    borderRadius: const BorderRadius.all(Radius.circular(40)),
                    child: InkWell(
                      child: AccountImage(content: _avatar, radius: 40),
                      onTap: () {
                        _updateImage('avatar');
                      },
                    ),
                  ),
                ),
              ],
            ),
            const Gap(8 + 28),
            TextField(
              controller: _nameController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'fieldUsername'.tr(),
                helperText: 'fieldUsernameCannotEditHint'.tr(),
              ),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const Gap(4),
            TextField(
              controller: _nickController,
              decoration: InputDecoration(labelText: 'fieldNickname'.tr()),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const Gap(4),
            TextField(
              controller: _descriptionController,
              maxLines: null,
              minLines: 3,
              decoration: InputDecoration(labelText: 'fieldDescription'.tr()),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const Gap(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_publisher?.type == 0)
                  TextButton.icon(
                    onPressed: _syncWithAccount,
                    label: Text('publisherSyncWithAccount').tr(),
                    icon: const Icon(Symbols.sync),
                  )
                else
                  const SizedBox(),
                ElevatedButton.icon(
                  onPressed: _isBusy ? null : _performAction,
                  label: Text('apply').tr(),
                  icon: const Icon(Symbols.save),
                ),
              ],
            ),
          ],
        ).padding(horizontal: 24, vertical: 12),
      ),
    );
  }
}
