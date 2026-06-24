import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';

@RoutePage()
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Symbols.search_off,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                '404',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "The page you're looking for doesn't exist.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.router.navigatePath('/'),
                icon: const Icon(Symbols.home),
                label: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
