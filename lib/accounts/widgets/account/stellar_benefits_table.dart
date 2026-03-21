import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';

class StellarBenefitsTable extends StatefulWidget {
  const StellarBenefitsTable({super.key});

  @override
  State<StellarBenefitsTable> createState() => _StellarBenefitsTableState();
}

class _StellarBenefitsTableState extends State<StellarBenefitsTable> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
              bottom: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.table_chart_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      'benefitsComparison'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [const Gap(8), _StellarPerksTable()],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _StellarPerksTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Perks',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Stellar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Nova',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.purple,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Supernova',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildPerkRow(context, 'Cloud storage', '5GB', '10GB', '15GB'),
          _buildPerkRow(
            context,
            'Username color',
            'Limited',
            'Unlimited',
            'Unlimited + gradient',
          ),
          _buildPerkRow(
            context,
            'Translation',
            'Included',
            'Included',
            'Included',
          ),
          _buildPerkRow(context, 'Leveling boost', '1.5x', '2x', '2.5x'),
          _buildPerkRow(
            context,
            'Verification',
            'Eligible',
            'Eligible',
            'Eligible',
          ),
          _buildPerkRow(context, 'Publisher quota', '2/3/5*', 'Same', 'Same'),
          _buildPerkRow(context, 'Realm quota', 'Not included', '0-3*', 'Same'),
          _buildPerkRow(
            context,
            'Bot quota',
            'Not included',
            '0-3*',
            'Same',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPerkRow(
    BuildContext context,
    String benefit,
    String stellar,
    String nova,
    String supernova, {
    bool isLast = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              benefit,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              stellar,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              nova,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.purple.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              supernova,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.orange.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
