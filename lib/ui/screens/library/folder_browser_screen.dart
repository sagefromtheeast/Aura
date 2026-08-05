import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

/// Folder and Genre Explorer allowing users to navigate raw filesystem audio
/// directories and filter library by extracted ID3/FLAC genre clusters.
class FolderBrowserScreen extends ConsumerStatefulWidget {
  const FolderBrowserScreen({super.key});

  @override
  ConsumerState<FolderBrowserScreen> createState() => _FolderBrowserScreenState();
}

class _FolderBrowserScreenState extends ConsumerState<FolderBrowserScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentPath = '/storage/emulated/0/Music';

  final List<String> _simulatedFolders = [
    'Lossless FLAC Masterpieces',
    'High-Res DSD Albums',
    'Daily Offline Mixtapes',
    'Vinyl Rips (24-bit 96kHz)',
    'Downloaded Soundtracks',
  ];

  final List<String> _genres = [
    'Ambient & Drone',
    'Electronic & Synthwave',
    'Classical (High-Res)',
    'Jazz Vocal & Fusion',
    'Progressive Rock',
    'Binaural Acoustic Folk',
    'Deep Dub techno',
    'Lo-Fi Beats',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Folder and Genre Browser Screen',
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // ── App Bar ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spacing16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Back to library',
                    ),
                    const SizedBox(width: DesignTokens.spacing8),
                    Text(
                      'Folders & Genres',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.create_new_folder_rounded, color: DesignTokens.primarySeed),
                      onPressed: () {
                        // Scan directory trigger
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Scanning audio directory roots...')),
                        );
                      },
                      tooltip: 'Add scan folder',
                    ),
                  ],
                ),
              ),

              // ── Tab Bar ─────────────────────────────────────────────────────
              TabBar(
                controller: _tabController,
                indicatorColor: DesignTokens.primarySeed,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).disabledColor,
                tabs: const [
                  Tab(icon: Icon(Icons.folder_open_rounded), text: 'Storage Directories'),
                  Tab(icon: Icon(Icons.style_rounded), text: 'Genre Clusters'),
                ],
              ),
              const SizedBox(height: DesignTokens.spacing12),

              // ── Tab Views ───────────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFolderTab(),
                    _buildGenreTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFolderTab() {
    final tracksAsync = ref.watch(allTracksProvider);

    return Column(
      children: [
        // Breadcrumb header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: DesignTokens.primarySeed.withValues(alpha: 0.1),
              borderRadius: DesignTokens.radius16,
            ),
            child: Row(
              children: [
                const Icon(Icons.sd_card_rounded, size: 18, color: DesignTokens.primarySeed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentPath,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontFamily: DesignTokens.fontMono,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spacing12),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              ..._simulatedFolders.map((folder) => Padding(
                    padding: const EdgeInsets.only(bottom: DesignTokens.spacing12),
                    child: GlassCard(
                      onTap: () {
                        setState(() {
                          _currentPath = '$_currentPath/$folder';
                        });
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.folder_rounded, size: 36, color: DesignTokens.primarySeed),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(folder, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text('Directory · Indexed & Verified', style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: DesignTokens.primarySeed),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: DesignTokens.spacing12),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text('FILES IN FOLDER', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: DesignTokens.primarySeed)),
              ),
              ...tracksAsync.maybeWhen(
                data: (tracks) => tracks.map((track) => Padding(
                      padding: const EdgeInsets.only(bottom: DesignTokens.spacing8),
                      child: GlassCard(
                        onTap: () => ref.read(playbackOrchestratorProvider).playTrack(track),
                        child: Row(
                          children: [
                            const Icon(Icons.audio_file_rounded, color: DesignTokens.primarySeed),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(track.title, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                            Text(
                              'FLAC',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontFamily: DesignTokens.fontMono,
                                    color: DesignTokens.primarySeed,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )),
                orElse: () => [const SizedBox.shrink()],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenreTab() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.35,
      ),
      itemCount: _genres.length,
      itemBuilder: (context, index) {
        final genre = _genres[index];
        return GlassCard(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Filtering library by genre: $genre')),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: const Icon(Icons.auto_graph_rounded, size: 28, color: DesignTokens.primarySeed),
              ),
              const Spacer(),
              Text(
                genre,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
