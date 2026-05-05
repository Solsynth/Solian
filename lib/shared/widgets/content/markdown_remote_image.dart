import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network/domain_trust.dart';
import 'package:island/shared/widgets/content/blocked_image_placeholder.dart';
import 'package:island/shared/widgets/content/image.dart';

class MarkdownRemoteImage extends HookConsumerWidget {
  final Uri uri;

  const MarkdownRemoteImage({
    super.key,
    required this.uri,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domainTrustService = ref.watch(domainTrustServiceProvider);
    final validationResult = useState<DomainTrustResult?>(null);
    final isLoading = useState(true);
    final userConfirmed = useState(false);

    useEffect(() {
      Future(() async {
        final result = await domainTrustService.validateUrl(uri);
        if (context.mounted) {
          validationResult.value = result;
          isLoading.value = false;
        }
      });
      return null;
    }, [uri.toString()]);

    if (isLoading.value) {
      return Container(
        constraints: const BoxConstraints(minHeight: 120),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final result = validationResult.value;
    if (result == null) {
      return const SizedBox.shrink();
    }

    if (result.trustLevel == DomainTrustLevel.verified) {
      return _buildImage();
    }

    if (!userConfirmed.value) {
      return BlockedImagePlaceholder(
        uri: uri,
        result: result,
        onProceed: () {
          userConfirmed.value = true;
        },
      );
    }

    return _buildImage();
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 360),
        child: UniversalImage(
          uri: uri.toString(),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
