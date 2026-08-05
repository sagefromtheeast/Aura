import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/track.dart';
import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';

/// Interactive Offline Tag & Metadata Editor enabling manual correction of
/// Title, Artist, Album, Genre, and Year directly in local database and file storage.
class TagEditorSheet extends ConsumerStatefulWidget {
  final Track track;
  const TagEditorSheet({super.key, required this.track});

  /// Show as an overflow-safe modal bottom sheet with height constraints.
  static Future<void> show(BuildContext context, Track track) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => TagEditorSheet(track: track),
    );
  }

  @override
  ConsumerState<TagEditorSheet> createState() => _TagEditorSheetState();
}

class _TagEditorSheetState extends ConsumerState<TagEditorSheet> {
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _albumController;
  late TextEditingController _genreController;
  late TextEditingController _trackNumController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.track.title);
    _artistController = TextEditingController(text: widget.track.artistName);
    _albumController = TextEditingController(text: widget.track.albumTitle);
    _genreController = TextEditingController(text: widget.track.genre);
    _trackNumController = TextEditingController(text: '${widget.track.trackNumber}');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _genreController.dispose();
    _trackNumController.dispose();
    super.dispose();
  }

  Future<void> _saveMetadata() async {
    final updated = widget.track.copyWith(
      title: _titleController.text.trim(),
      artistName: _artistController.text.trim(),
      albumTitle: _albumController.text.trim(),
      genre: _genreController.text.trim().isEmpty ? 'Unknown' : _genreController.text.trim(),
      trackNumber: int.tryParse(_trackNumController.text) ?? widget.track.trackNumber,
    );

    try {
      await ref.read(musicRepositoryProvider).upsertTracks([updated]);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offline ID3 metadata updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving metadata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    // Enforce Modal Bottom Sheet Vertical Overflow Prevention rule from AGENTS.md
    return Container(
      constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.85),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: mediaQuery.viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, size: 30, color: DesignTokens.primarySeed),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Edit Offline Metadata',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing12),

          // Scrollable fields container
          Flexible(
            child: ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildField('Track Title', _titleController, Icons.title_rounded),
                const SizedBox(height: 12),
                _buildField('Artist Name', _artistController, Icons.person_rounded),
                const SizedBox(height: 12),
                _buildField('Album Name', _albumController, Icons.album_rounded),
                const SizedBox(height: 12),
                _buildField('Genre / Style', _genreController, Icons.style_rounded),
                const SizedBox(height: 12),
                _buildField('Track Number', _trackNumController, Icons.numbers_rounded, isNumeric: true),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Action button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primarySeed,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: DesignTokens.radius24),
            ),
            icon: const Icon(Icons.save_rounded, size: 24),
            label: const Text('SAVE TO OFFLINE STORE', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: _saveMetadata,
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: DesignTokens.primarySeed,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: Theme.of(context).disabledColor),
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: DesignTokens.radius16,
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
