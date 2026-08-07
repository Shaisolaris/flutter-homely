import 'package:flutter/material.dart';

import '../../../core/constants/automation_visuals.dart';
import '../../../core/logic/automation.dart';
import '../../../core/models/automation_rule.dart';
import '../../../core/models/device.dart';

/// A single automation: an "If [trigger], then [action]" sentence built by
/// `describeTrigger`/`describeAction`, an enable switch, and a manual
/// "Test now" button that evaluates it against live device state.
class AutomationCard extends StatelessWidget {
  const AutomationCard({
    super.key,
    required this.automation,
    required this.devices,
    required this.onEnabledChanged,
    required this.onTest,
  });

  final Automation automation;
  final List<Device> devices;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final triggerText = describeTrigger(automation.trigger, devices);
    final actionText = describeAction(automation.action, devices);
    final bodyStyle = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    final emphasisStyle = theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: scheme.onSurface);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.secondaryContainer,
                  foregroundColor: scheme.onSecondaryContainer,
                  child: Icon(triggerIconFor(automation.trigger.type)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    automation.name,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Switch(value: automation.enabled, onChanged: onEnabledChanged),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(text: 'If ', style: bodyStyle),
                    TextSpan(text: triggerText, style: emphasisStyle),
                    TextSpan(text: ', then ', style: bodyStyle),
                    TextSpan(text: actionText, style: emphasisStyle),
                    TextSpan(text: '.', style: bodyStyle),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onTest,
                icon: const Icon(Icons.play_circle_outline, size: 18),
                label: const Text('Test now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
