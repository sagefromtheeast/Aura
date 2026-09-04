// lib/ui/screens/player/queues_manager_sheet.dart
// Aura — The multiple-queues panel.
//
// Aura can hold several independent named queues at once (a playlist playing
// while a search result waits). This lists them, shows which is active, and
// lets the user switch, rename, delete, or keep only the current one.
//
// It reads the orchestrator's QueueManager directly and re-reads on each
// action — a transient manager panel does not need a live stream.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';

class QueuesManagerSheet extends ConsumerStatefulWidget {
  const QueuesManagerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const QueuesManagerSheet(),
    );
  }

  @override
  ConsumerState<QueuesManagerSheet> createState() => _QueuesManagerSheetState();
}

class _QueuesManagerSheetState extends ConsumerState<QueuesManagerSheet> {
  @override
  Widget build(BuildContext context) {
    final orchestrator = ref.read(playbackOrchestratorProvider);
    final manager = orchestrator.queueManager;
    final queues = manager.queues;
    final activeId = manager.active?.id;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: DesignTokens.spacing12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: DesignTokens.radiusPill,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.queue_music_rounded),
              title: Text('Queues',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            if (queues.isEmpty)
              const Padding(
                padding: EdgeInsets.all(DesignTokens.spacing32),
                child: Text('No queues yet. Play something to start one.'),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: queues.length,
                  itemBuilder: (context, i) {
                    final queue = queues[i];
                    final isActive = queue.id == activeId;
                    return ListTile(
                      leading: Icon(
                        isActive
                            ? Icons.play_circle_rounded
                            : Icons.radio_button_unchecked,
                        color: isActive ? DesignTokens.primarySeed : null,
                      ),
                      title: Text(queue.name,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                          '${queue.length} tracks'
                          '${queue.source != null ? ' · ${queue.source}' : ''}'),
                      onTap: isActive
                          ? null
                          : () async {
                              await orchestrator.switchQueue(queue.id);
                              if (mounted) setState(() {});
                            },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, size: 20),
                            tooltip: 'Rename',
                            onPressed: () => _rename(orchestrator, queue.id,
                                queue.name),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            tooltip: 'Remove queue',
                            onPressed: () {
                              orchestrator.removeQueue(queue.id);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (queues.length > 1)
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spacing16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      orchestrator.removeAllOtherQueues();
                      setState(() {});
                    },
                    icon: Icon(Icons.layers_clear_rounded,
                        color: Theme.of(context).colorScheme.error),
                    label: Text('Remove all other queues',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _rename(
      dynamic orchestrator, String queueId, String current) async {
    final controller = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename queue'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text),
              child: const Text('Save')),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      orchestrator.renameQueue(queueId, name.trim());
      if (mounted) setState(() {});
    }
  }
}
