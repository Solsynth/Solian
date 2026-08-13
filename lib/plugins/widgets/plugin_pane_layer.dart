import 'package:material_ui/material_ui.dart';
import 'package:island/plugins/widgets/plugin_pane.dart';
import 'package:island/plugins/widgets/plugin_pane_host.dart';

class PluginPaneLayer extends StatelessWidget {
  const PluginPaneLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final host = PluginPaneHost.instance;

    return ListenableBuilder(
      listenable: host,
      builder: (context, _) {
        final panes = host.panes;
        if (panes.isEmpty) return const SizedBox.shrink();

        final sorted = List<PluginPaneData>.from(panes)
          ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

        return Stack(
          children: sorted
              .map((data) => PluginPane(
                    key: ValueKey(data.id),
                    data: data,
                    host: host,
                  ))
              .toList(),
        );
      },
    );
  }
}
