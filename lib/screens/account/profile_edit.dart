import 'dart:io';
import 'dart:ui';

import 'package:croppy/croppy.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' show basename;
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_attachment.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/universal_image.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _imagePicker = ImagePicker();

  final _usernameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timezoneController = TextEditingController();
  final _genderController = TextEditingController();
  final _pronounsController = TextEditingController();
  final _locationController = TextEditingController();
  final _birthdayController = TextEditingController();

  String? _avatar;
  String? _banner;
  DateTime? _birthday;
  List<(String, String)>? _links;

  bool _isBusy = false;

  static const _kDateFormat = 'y/M/d';

  void _syncWidget() async {
    final ua = context.read<UserProvider>();
    final prof = ua.user!;
    _usernameController.text = prof.name;
    _nicknameController.text = prof.nick;
    _descriptionController.text = prof.profile!.description;
    _firstNameController.text = prof.profile!.firstName;
    _lastNameController.text = prof.profile!.lastName;
    _timezoneController.text = prof.profile!.timeZone;
    _genderController.text = prof.profile!.gender;
    _pronounsController.text = prof.profile!.pronouns;
    _locationController.text = prof.profile!.location;
    _avatar = prof.avatar;
    _banner = prof.banner;
    _links =
        prof.profile!.links.entries.map((ele) => (ele.key, ele.value)).toList();
    _birthday = prof.profile!.birthday?.toLocal();
    if (_birthday != null) {
      _birthdayController.text =
          DateFormat(_kDateFormat).format(prof.profile!.birthday!.toLocal());
    }
  }

  void _selectBirthday() async {
    await showCupertinoModalPopup<DateTime?>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          child: CupertinoDatePicker(
            initialDateTime: _birthday?.toLocal(),
            mode: CupertinoDatePickerMode.date,
            use24hFormat: true,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                _birthday = newDate;
                _birthdayController.text =
                    DateFormat(_kDateFormat).format(_birthday!);
              });
            },
          ),
        ),
      ),
    );
  }

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

      if (!mounted) return;
      final sn = context.read<SnNetworkProvider>();
      await sn.client
          .put('/cgi/id/users/me/$place', data: {'attachment': attachment.rid});

      if (!mounted) return;
      final ua = context.read<UserProvider>();
      await ua.refreshUser();

      if (!mounted) return;
      context.showSnackbar('accountProfileEditApplied'.tr());
      _syncWidget();
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  void _updateUserInfo() async {
    setState(() => _isBusy = true);

    final sn = context.read<SnNetworkProvider>();

    try {
      await sn.client.put(
        '/cgi/id/users/me',
        data: {
          'nick': _nicknameController.value.text,
          'description': _descriptionController.value.text,
          'first_name': _firstNameController.value.text,
          'last_name': _lastNameController.value.text,
          'time_zone': _timezoneController.value.text,
          'gender': _genderController.value.text,
          'pronouns': _pronounsController.value.text,
          'location': _locationController.value.text,
          'birthday': _birthday?.toUtc().toIso8601String(),
          'links': {
            for (final link in _links!
                .where((ele) => ele.$1.isNotEmpty && ele.$2.isNotEmpty))
              link.$1: link.$2,
          },
        },
      );

      if (!mounted) return;
      final ua = context.read<UserProvider>();
      await ua.refreshUser();

      if (!mounted) return;
      context.showSnackbar('accountProfileEditApplied'.tr());
      _syncWidget();
    } catch (err) {
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _syncWidget();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nicknameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _descriptionController.dispose();
    _timezoneController.dispose();
    _genderController.dispose();
    _pronounsController.dispose();
    _locationController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 24;

    final sn = context.read<SnNetworkProvider>();

    return AppScaffold(
      noBackground: true,
      appBar: AppBar(
          leading: const PageBackButton(),
          title: Text('screenAccountProfileEdit').tr()),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        aspectRatio: 16 / 9,
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
            ).padding(horizontal: padding),
            const Gap(8 + 28),
            Column(
              spacing: 4,
              children: [
                TextField(
                  readOnly: true,
                  controller: _usernameController,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: 'fieldUsername'.tr(),
                    helperText: 'fieldUsernameCannotEditHint'.tr(),
                  ),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
                TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: 'fieldNickname'.tr()),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: TextField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'fieldFirstName'.tr(),
                        ),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    const Gap(8),
                    Flexible(
                      flex: 1,
                      child: TextField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'fieldLastName'.tr(),
                        ),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: TextField(
                        controller: _genderController,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'fieldGender'.tr(),
                        ),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    const Gap(4),
                    Flexible(
                      flex: 1,
                      child: TextField(
                        controller: _pronounsController,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'fieldPronouns'.tr(),
                        ),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: _descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 3,
                  decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: 'fieldDescription'.tr()),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _timezoneController,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'fieldTimeZone'.tr(),
                        ),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    const Gap(4),
                    StyledWidget(
                      IconButton(
                        icon: const Icon(Symbols.calendar_month),
                        visualDensity:
                            VisualDensity(horizontal: -4, vertical: -4),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          _timezoneController.text =
                              await FlutterTimezone.getLocalTimezone();
                        },
                      ),
                    ).padding(top: 6),
                    const Gap(4),
                    StyledWidget(
                      IconButton(
                        icon: const Icon(Symbols.clear),
                        visualDensity:
                            VisualDensity(horizontal: -4, vertical: -4),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          _timezoneController.clear();
                        },
                      ),
                    ).padding(top: 6),
                  ],
                ),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: 'fieldLocation'.tr()),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
                TextField(
                  controller: _birthdayController,
                  readOnly: true,
                  decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: 'fieldBirthday'.tr()),
                  onTap: () => _selectBirthday(),
                ),
                if (_links != null)
                  Card(
                    margin: const EdgeInsets.only(top: 16, bottom: 4),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'fieldLinks'.tr(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontSize: 17),
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                visualDensity:
                                    VisualDensity(horizontal: -4, vertical: -4),
                                icon: const Icon(Symbols.add),
                                onPressed: () {
                                  setState(() => _links!.add(('', '')));
                                },
                              ),
                            ],
                          ),
                          const Gap(8),
                          for (var idx = 0; idx < _links!.length; idx++)
                            Row(
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: TextFormField(
                                    initialValue: _links![idx].$1,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: const OutlineInputBorder(),
                                      labelText: 'fieldLinkName'.tr(),
                                    ),
                                    onChanged: (value) {
                                      _links![idx] = (value, _links![idx].$2);
                                    },
                                    onTapOutside: (_) => FocusManager
                                        .instance.primaryFocus
                                        ?.unfocus(),
                                  ),
                                ),
                                const Gap(8),
                                Flexible(
                                  flex: 1,
                                  child: TextFormField(
                                    initialValue: _links![idx].$2,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: const OutlineInputBorder(),
                                      labelText: 'fieldLinkUrl'.tr(),
                                    ),
                                    onChanged: (value) {
                                      _links![idx] = (_links![idx].$1, value);
                                    },
                                    onTapOutside: (_) => FocusManager
                                        .instance.primaryFocus
                                        ?.unfocus(),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ).padding(horizontal: padding + 8),
            const Gap(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _isBusy ? null : _updateUserInfo,
                  icon: const Icon(Symbols.save),
                  label: Text('apply').tr(),
                ),
              ],
            ).padding(horizontal: padding),
            Gap(MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
