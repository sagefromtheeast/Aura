// lib/ui/screens/settings/backup_restore_screen.dart
// Aura — Back up and restore playlists, favourites, stats and settings.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../data/backup/backup_service.dart';
import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _busy = false;
  String? _lastBackupPath;

  Future<void> _backup() async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final stamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final path = p.join(dir.path, 'Aura', 'Backups', 'aura-backup-$stamp.json');
      await ref.read(backupServiceProvider).exportToFile(path);
      if (!mounted) return;
      setState(() => _lastBackupPath = path);
      messenger.showSnackBar(SnackBar(content: Text('Backed up to $path')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    if (_lastBackupPath == null) {
      // A file picker is the eventual entry point; for now restore the most
      // recent backup this app wrote.
      final dir = await getApplicationDocumentsDirectory();
      final backupsDir = Directory(p.join(dir.path, 'Aura', 'Backups'));
      if (backupsDir.existsSync()) {
        final files = backupsDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.json'))
            .toList()
          ..sort((a, b) => b.path.compareTo(a.path));
        if (files.isNotEmpty) _lastBackupPath = files.first.path;
      }
    }
    if (_lastBackupPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No backup found to restore.')),
      );
      return;
    }

    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result =
          await ref.read(backupServiceProvider).restoreFromFile(_lastBackupPath!);
      // The library and favourites views need to re-read.
      ref.invalidate(allPlaylistsProvider);
      ref.invalidate(allTracksProvider);
      ref.invalidate(favouriteTracksProvider);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(_summary(result))));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Restore failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _summary(RestoreResult r) {
    final parts = <String>[
      '${r.playlistsRestored} playlists',
      '${r.tracksReconnected} tracks',
      if (r.settingsRestored) 'settings',
    ];
    final missing =
        r.tracksMissing > 0 ? ' · ${r.tracksMissing} not in library' : '';
    return 'Restored ${parts.join(', ')}$missing';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spacing16),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Back up',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: DesignTokens.spacing8),
                Text(
                  'Saves your playlists, favourites, play counts and settings. '
                  'Your audio files are not included.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: DesignTokens.spacing16),
                FilledButton.icon(
                  onPressed: _busy ? null : _backup,
                  style: FilledButton.styleFrom(
                    backgroundColor: DesignTokens.primarySeed,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.backup_rounded),
                  label: const Text('Back up now'),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spacing16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Restore',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: DesignTokens.spacing8),
                Text(
                  'Reconnects a backup to your current library by file path, so '
                  'it survives a rescan. Anything no longer on the device is '
                  'skipped.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: DesignTokens.spacing16),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _restore,
                  icon: const Icon(Icons.restore_rounded),
                  label: const Text('Restore latest backup'),
                ),
              ],
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.all(DesignTokens.spacing24),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
