import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

class EmbedViewRenderer extends HookConsumerWidget {
  final SnPostEmbedView embedView;
  final double? maxHeight;
  final BorderRadius? borderRadius;

  const EmbedViewRenderer({
    super.key,
    required this.embedView,
    this.maxHeight = 400,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // State management for lazy loading
    final shouldLoad = useState(false);
    final isLoading = useState(false);

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight ?? 400),
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
        color: colorScheme.surfaceContainerLowest,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with embed info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    embedView.renderer == PostEmbedViewRenderer.webView
                        ? Symbols.web
                        : Symbols.web,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getUriDisplay(embedView.uri),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Symbols.open_in_new,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () async {
                      final uri = Uri.parse(embedView.uri);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Open in browser',
                  ),
                ],
              ),
            ),

            // WebView content with lazy loading
            AspectRatio(
              aspectRatio: embedView.aspectRatio ?? 1,
              child:
                  shouldLoad.value
                      ? Stack(
                        children: [
                          InAppWebView(
                            initialUrlRequest: URLRequest(
                              url: WebUri(embedView.uri),
                            ),
                            initialSettings: InAppWebViewSettings(
                              javaScriptEnabled: true,
                              mediaPlaybackRequiresUserGesture: false,
                              allowsInlineMediaPlayback: true,
                              useShouldOverrideUrlLoading: true,
                              useOnLoadResource: true,
                              supportZoom: false,
                              useWideViewPort: false,
                              loadWithOverviewMode: true,
                              builtInZoomControls: false,
                              displayZoomControls: false,
                              minimumFontSize: 12,
                              preferredContentMode:
                                  UserPreferredContentMode.RECOMMENDED,
                              allowsBackForwardNavigationGestures: false,
                              allowsLinkPreview: false,
                              isInspectable: false,
                            ),
                            onWebViewCreated: (controller) {
                              // Configure webview settings
                              controller.addJavaScriptHandler(
                                handlerName: 'onHeightChanged',
                                callback: (args) {
                                  // Handle dynamic height changes if needed
                                },
                              );
                            },
                            onLoadStart: (controller, url) {
                              isLoading.value = true;
                            },
                            onLoadStop: (controller, url) async {
                              isLoading.value = false;
                              // Inject CSS to improve mobile display and remove borders
                              await controller.evaluateJavascript(
                                source: '''
                            // Remove unwanted elements
                            var elements = document.querySelectorAll('nav, header, footer, .ads, .advertisement, .sidebar');
                            for (var i = 0; i < elements.length; i++) {
                              elements[i].style.display = 'none';
                            }

                            // Remove borders from embedded content (YouTube, Vimeo, etc.)
                            var iframes = document.querySelectorAll('iframe');
                            for (var i = 0; i < iframes.length; i++) {
                              iframes[i].style.border = 'none';
                              iframes[i].style.borderRadius = '0';
                            }

                            // Remove borders from video elements
                            var videos = document.querySelectorAll('video');
                            for (var i = 0; i < videos.length; i++) {
                              videos[i].style.border = 'none';
                              videos[i].style.borderRadius = '0';
                            }

                            // Remove borders from any element that might have them
                            var allElements = document.querySelectorAll('*');
                            for (var i = 0; i < allElements.length; i++) {
                              if (allElements[i].style.border) {
                                allElements[i].style.border = 'none';
                              }
                            }

                            // Improve readability
                            var body = document.body;
                            body.style.fontSize = '14px';
                            body.style.lineHeight = '1.4';
                            body.style.margin = '0';
                            body.style.padding = '0';

                            // Handle dynamic content
                            var observer = new MutationObserver(function(mutations) {
                              // Remove borders from newly added elements
                              var newIframes = document.querySelectorAll('iframe');
                              for (var i = 0; i < newIframes.length; i++) {
                                if (!newIframes[i].style.border || newIframes[i].style.border !== 'none') {
                                  newIframes[i].style.border = 'none';
                                  newIframes[i].style.borderRadius = '0';
                                }
                              }
                              var newVideos = document.querySelectorAll('video');
                              for (var i = 0; i < newVideos.length; i++) {
                                if (!newVideos[i].style.border || newVideos[i].style.border !== 'none') {
                                  newVideos[i].style.border = 'none';
                                  newVideos[i].style.borderRadius = '0';
                                }
                              }
                              window.flutter_inappwebview.callHandler('onHeightChanged', document.body.scrollHeight);
                            });
                            observer.observe(document.body, { childList: true, subtree: true });
                          ''',
                              );
                            },
                            onLoadError: (controller, url, code, message) {
                              isLoading.value = false;
                            },
                            onLoadHttpError: (
                              controller,
                              url,
                              statusCode,
                              description,
                            ) {
                              isLoading.value = false;
                            },
                            shouldOverrideUrlLoading: (
                              controller,
                              navigationAction,
                            ) async {
                              final uri = navigationAction.request.url;
                              if (uri != null &&
                                  uri.toString() != embedView.uri) {
                                // Open external links in browser
                                // You might want to use url_launcher here
                                return NavigationActionPolicy.CANCEL;
                              }
                              return NavigationActionPolicy.ALLOW;
                            },
                            onProgressChanged: (controller, progress) {
                              // Handle progress changes if needed
                            },
                            onConsoleMessage: (controller, consoleMessage) {
                              // Handle console messages for debugging
                              debugPrint(
                                'WebView Console: ${consoleMessage.message}',
                              );
                            },
                          ),
                          if (isLoading.value)
                            Container(
                              color: colorScheme.surfaceContainerLowest,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      )
                      : GestureDetector(
                        onTap: () {
                          shouldLoad.value = true;
                        },
                        child: Container(
                          color: colorScheme.surfaceContainerLowest,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Symbols.play_arrow,
                                size: 48,
                                color: colorScheme.onSurfaceVariant.withOpacity(
                                  0.6,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to load content',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  String _getUriDisplay(String uri) {
    try {
      final parsedUri = Uri.parse(uri);
      return parsedUri.host.isNotEmpty ? parsedUri.host : uri;
    } catch (e) {
      return uri;
    }
  }
}
