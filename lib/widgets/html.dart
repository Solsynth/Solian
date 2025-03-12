import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:surface/widgets/universal_image.dart';
import 'package:url_launcher/url_launcher_string.dart';

List<Widget> parseHtmlToWidgets(
    BuildContext context, Iterable<dom.Element>? elements) {
  if (elements == null) return [];

  final List<Widget> widgets = [];

  for (final node in elements) {
    switch (node.localName) {
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        widgets.add(Text(node.text.trim(),
            style: Theme.of(context).textTheme.titleMedium));
        break;
      case 'p':
        if (node.text.trim().isEmpty) continue;
        widgets.add(
          Text.rich(
            TextSpan(
              text: node.text.trim(),
              children: [
                for (final child in node.children)
                  switch (child.localName) {
                    'a' => TextSpan(
                        text: child.text.trim(),
                        style: const TextStyle(
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrlString(child.attributes['href']!);
                          },
                      ),
                    _ => TextSpan(text: child.text.trim()),
                  },
              ],
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
        break;
      case 'a':
        // drop single link
        break;
      case 'div':
        // ignore div text, normally it is not meaningful
        widgets.addAll(parseHtmlToWidgets(context, node.children));
        break;
      case 'hr':
        widgets.add(const Divider());
        break;
      case 'img':
        var src = node.attributes['src'];
        if (src == null) break;
        final width = double.tryParse(node.attributes['width'] ?? 'null');
        final height = double.tryParse(node.attributes['height'] ?? 'null');
        final ratio = width != null && height != null ? width / height : 1.0;
        if (src.startsWith('//')) {
          src = 'https:$src';
        } else if (!src.startsWith('http')) {
          // final baseUri = Uri.parse(_article!.url);
          // final baseUrl = '${baseUri.scheme}://${baseUri.host}';
          src = src;
        }
        widgets.add(
          AspectRatio(
            aspectRatio: ratio,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              height: height ?? double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: AutoResizeUniversalImage(
                    src,
                    fit: width != null && height != null
                        ? BoxFit.cover
                        : BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        );
        break;
      default:
        widgets.addAll(parseHtmlToWidgets(context, node.children));
        break;
    }
  }

  return widgets;
}
