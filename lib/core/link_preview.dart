import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/posts/posts_models/embed.dart';
import 'package:island/core/network.dart';

part 'link_preview.g.dart';

@riverpod
class LinkPreview extends _$LinkPreview {
  @override
  Future<SnScrappedLink?> build(String url) async {
    final client = ref.read(apiClientProvider);

    try {
      final response = await client.get(
        '/scrap/link',
        queryParameters: {'url': url},
      );

      if (response.statusCode == 200 && response.data != null) {
        return SnScrappedLink.fromJson(response.data);
      }
      return null;
    } catch (e) {
      // Return null on error to show fallback UI
      return null;
    }
  }
}
