import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/user.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class ContactMethodSheet extends HookConsumerWidget {
  final SnContactMethod contact;
  const ContactMethodSheet({super.key, required this.contact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> deleteContactMethod() async {
      final confirm = await showConfirmAlert(
        'contactMethodDeleteHint'.tr(),
        'contactMethodDelete'.tr(),
      );
      if (!confirm || !context.mounted) return;
      try {
        showLoadingModal(context);
        final client = ref.read(apiClientProvider);
        await client.delete('/id/accounts/me/contacts/${contact.id}');
        if (context.mounted) Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> verifyContactMethod() async {
      try {
        showLoadingModal(context);
        final client = ref.read(apiClientProvider);
        await client.post('/id/accounts/me/contacts/${contact.id}/verify');
        if (context.mounted) {
          showSnackBar('contactMethodVerificationSent'.tr());
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> setContactMethodAsPrimary() async {
      try {
        showLoadingModal(context);
        final client = ref.read(apiClientProvider);
        await client.post('/id/accounts/me/contacts/${contact.id}/primary');
        if (context.mounted) Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    return SheetScaffold(
      titleText: 'contactMethod'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(switch (contact.type) {
                0 => Symbols.mail,
                1 => Symbols.phone,
                _ => Symbols.home,
              }, size: 32),
              const Gap(8),
              Text(switch (contact.type) {
                0 => 'contactMethodTypeEmail'.tr(),
                1 => 'contactMethodTypePhone'.tr(),
                _ => 'contactMethodTypeAddress'.tr(),
              }),
              const Gap(4),
              Text(
                contact.content,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Gap(10),
              Row(
                children: [
                  if (contact.verifiedAt == null)
                    Badge(
                      label: Text('contactMethodUnverified'.tr()),
                      textColor: Theme.of(context).colorScheme.onSecondary,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    )
                  else
                    Badge(
                      label: Text('contactMethodVerified'.tr()),
                      textColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  if (contact.isPrimary)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Badge(
                        label: Text('contactMethodPrimary'.tr()),
                        textColor: Theme.of(context).colorScheme.onTertiary,
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                ],
              ),
            ],
          ).padding(all: 20),
          const Divider(height: 1),
          if (contact.verifiedAt == null)
            ListTile(
              leading: const Icon(Symbols.verified),
              title: Text('contactMethodVerify').tr(),
              onTap: verifyContactMethod,
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
            ),
          if (contact.verifiedAt != null && !contact.isPrimary)
            ListTile(
              leading: const Icon(Symbols.star),
              title: Text('contactMethodSetPrimary').tr(),
              onTap: setContactMethodAsPrimary,
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
            ),
          ListTile(
            leading: const Icon(Symbols.delete),
            title: Text('contactMethodDelete').tr(),
            onTap: deleteContactMethod,
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
          ),
        ],
      ),
    );
  }
}

class ContactMethodNewSheet extends HookConsumerWidget {
  const ContactMethodNewSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactType = useState<int>(0);
    final contentController = useTextEditingController();

    Future<void> addContactMethod() async {
      if (contentController.text.isEmpty) {
        showSnackBar('contactMethodContentEmpty'.tr());
        return;
      }

      try {
        showLoadingModal(context);
        final apiClient = ref.read(apiClientProvider);
        await apiClient.post(
          '/id/accounts/me/contacts',
          data: {'type': contactType.value, 'content': contentController.text},
        );
        if (context.mounted) {
          showSnackBar('contactMethodVerificationNeeded'.tr());
          Navigator.pop(context, true);
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    return SheetScaffold(
      titleText: 'contactMethodNew'.tr(),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<int>(
            value: contactType.value,
            decoration: InputDecoration(
              labelText: 'contactMethodType'.tr(),
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem<int>(
                value: 0,
                child: Row(
                  children: [
                    Icon(Symbols.mail),
                    const Gap(8),
                    Text('contactMethodTypeEmail'.tr()),
                  ],
                ),
              ),
              DropdownMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    Icon(Symbols.phone),
                    const Gap(8),
                    Text('contactMethodTypePhone'.tr()),
                  ],
                ),
              ),
              DropdownMenuItem<int>(
                value: 2,
                child: Row(
                  children: [
                    Icon(Symbols.home),
                    const Gap(8),
                    Text('contactMethodTypeAddress'.tr()),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                contactType.value = value;
              }
            },
          ),
          TextField(
            controller: contentController,
            decoration: InputDecoration(
              prefixIcon: Icon(switch (contactType.value) {
                0 => Symbols.mail,
                1 => Symbols.phone,
                _ => Symbols.home,
              }),
              labelText: switch (contactType.value) {
                0 => 'contactMethodTypeEmail'.tr(),
                1 => 'contactMethodTypePhone'.tr(),
                _ => 'contactMethodTypeAddress'.tr(),
              },
              hintText: switch (contactType.value) {
                0 => 'contactMethodEmailHint'.tr(),
                1 => 'contactMethodPhoneHint'.tr(),
                _ => 'contactMethodAddressHint'.tr(),
              },
              border: const OutlineInputBorder(),
            ),
            keyboardType: switch (contactType.value) {
              0 => TextInputType.emailAddress,
              1 => TextInputType.phone,
              _ => TextInputType.multiline,
            },
            maxLines: switch (contactType.value) {
              2 => 3,
              _ => 1,
            },
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child:
                Text(switch (contactType.value) {
                  0 => 'contactMethodEmailDescription',
                  1 => 'contactMethodPhoneDescription',
                  _ => 'contactMethodAddressDescription',
                }).tr(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: addContactMethod,
                icon: Icon(Symbols.add),
                label: Text('create').tr(),
              ),
            ],
          ),
        ],
      ).padding(horizontal: 20, vertical: 24),
    );
  }
}
