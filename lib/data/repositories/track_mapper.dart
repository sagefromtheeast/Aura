// lib/data/repositories/track_mapper.dart
// Aura — TrackRow → Track mapping, shared by the repositories that need it.

import '../../domain/entities/track.dart';
import '../database/app_database.dart';

Track trackFromRow(TrackRow r) => Track(
      id: r.id,
      title: r.title,
      artistName: r.artistName,
      albumTitle: r.albumTitle,
      artistId: r.artistId,
      albumId: r.albumId,
      durationMs: r.durationMs,
      filePath: r.filePath,
      fileSizeBytes: r.fileSizeBytes,
      format: AudioFormat.values.firstWhere(
        (f) => f.name == r.format,
        orElse: () => AudioFormat.unknown,
      ),
      bitRateKbps: r.bitRateKbps,
      sampleRateHz: r.sampleRateHz,
      playCount: r.playCount,
      skipCount: r.skipCount,
      rating: r.rating,
      dateAddedMs: r.dateAddedMs,
      lastPlayedMs: r.lastPlayedMs,
      isDeleted: r.isDeleted,
      coverArtPath: r.coverArtPath,
      trackNumber: r.trackNumber,
      discNumber: r.discNumber,
      genre: r.genre,
      year: r.year,
    );
