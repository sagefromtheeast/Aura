import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/dummy_library_data.dart';


class FolderScreen extends ConsumerStatefulWidget {
  const FolderScreen({super.key});

  @override
  ConsumerState<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends ConsumerState<FolderScreen> {
  final List<String> _selectedFolderIds = [];
  bool get _isMultiSelectMode => _selectedFolderIds.isNotEmpty;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedFolderIds.contains(id)) {
        _selectedFolderIds.remove(id);
      } else {
        _selectedFolderIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedFolderIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final foldersAsync = ref.watch(dummyFoldersProvider);
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_isMultiSelectMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isMultiSelectMode) {
          _clearSelection();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: foldersAsync.when(
          data: (folders) {
            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // Breadcrumb Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.sd_storage, color: theme.colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Internal Storage',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 20),
                            Text(
                              'Music',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Folder List
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final folder = folders[index];
                          final isSelected = _selectedFolderIds.contains(folder.id);

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Stack(
                              children: [
                                CircleAvatar(
                                  backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                                  child: Icon(
                                    Icons.folder,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                if (_isMultiSelectMode)
                                  Positioned(
                                    right: -4,
                                    bottom: -4,
                                    child: Icon(
                                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: isSelected ? theme.colorScheme.primary : Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(
                              folder.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${folder.trackCount} tracks · ${folder.path}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                              ),
                            ),
                            onTap: () {
                              if (_isMultiSelectMode) {
                                _toggleSelection(folder.id);
                              } else {
                                // Navigate deeper stub
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Opening ${folder.name}...')),
                                );
                              }
                            },
                            onLongPress: () {
                              if (!_isMultiSelectMode) {
                                _toggleSelection(folder.id);
                              }
                            },
                          );
                        },
                        childCount: folders.length,
                      ),
                    ),
                    
                    // Bottom padding
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 160), // Space for miniplayer and bottom bar
                    ),
                  ],
                ),

                // Bottom Action Bar (Animated)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  left: 0,
                  right: 0,
                  bottom: _isMultiSelectMode ? 80 : -100, // Show above mini player
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.inverseSurface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedFolderIds.length} selected',
                            style: TextStyle(
                              color: theme.colorScheme.onInverseSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Scanning selected folders...')),
                                  );
                                  _clearSelection();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.inversePrimary,
                                ),
                                child: const Text('Scan'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Added to Library')),
                                  );
                                  _clearSelection();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.inversePrimary,
                                  foregroundColor: theme.colorScheme.onInverseSurface,
                                ),
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error loading folders: $error')),
        ),
      ),
    );
  }
}
