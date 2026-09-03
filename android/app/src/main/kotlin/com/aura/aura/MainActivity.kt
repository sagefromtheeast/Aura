package com.aura.aura

import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.aura/file_scanner"

    companion object {
        /// Mirrors kSupportedAudioExtensions in lib/core/constants.dart.
        private val SUPPORTED_EXTENSIONS = setOf(
            "mp3", "flac", "m4a", "ogg", "opus", "wma",
            "aac", "alac", "ape", "dsf", "dff", "wav", "aiff"
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "scanAllAudio") {
                val audioFiles = scanAllAudio()
                result.success(audioFiles)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun scanAllAudio(): List<Map<String, Any?>> {
        val audioList = mutableListOf<Map<String, Any?>>()
        val uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        // GENRE is only queryable as a media column from API 30 (R).
        val hasGenre = Build.VERSION.SDK_INT >= Build.VERSION_CODES.R

        val projection = mutableListOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.ALBUM_ID,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.SIZE,
            MediaStore.Audio.Media.DATE_ADDED,
            MediaStore.Audio.Media.TRACK,
            MediaStore.Audio.Media.YEAR
        ).apply {
            if (hasGenre) add(MediaStore.Audio.Media.GENRE)
        }.toTypedArray()
        // Exclude BITRATE as it might not be available across all Android API versions easily via this constants
        // Dart code falls back correctly for bitrate and sample rate.

        val selection = "${MediaStore.Audio.Media.IS_MUSIC} != 0"

        context.contentResolver.query(uri, projection, selection, null, null)?.use { cursor ->
            val titleColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            val artistColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            val albumColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
            val durationColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
            val dataColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
            val sizeColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.SIZE)
            val dateAddedColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_ADDED)
            val trackColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TRACK)
            val yearColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.YEAR)
            val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val albumIdColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
            val genreColumn =
                if (hasGenre) cursor.getColumnIndex(MediaStore.Audio.Media.GENRE) else -1

            while (cursor.moveToNext()) {
                val path = cursor.getString(dataColumn) ?: continue
                // Only surface containers the Dart scanner indexes.
                val ext = path.substringAfterLast('.', "").lowercase()
                if (ext !in SUPPORTED_EXTENSIONS) continue

                val map = mutableMapOf<String, Any?>()
                map["id"] = cursor.getLong(idColumn).toString()
                map["albumId"] = cursor.getLong(albumIdColumn).toString()
                if (genreColumn >= 0) {
                    map["genre"] = cursor.getString(genreColumn)
                }
                map["title"] = cursor.getString(titleColumn)
                map["artist"] = cursor.getString(artistColumn)
                map["album"] = cursor.getString(albumColumn)
                map["duration"] = cursor.getLong(durationColumn)
                map["path"] = cursor.getString(dataColumn)
                map["size"] = cursor.getLong(sizeColumn)
                map["dateAdded"] = cursor.getLong(dateAddedColumn) * 1000 // Convert to ms
                map["trackNumber"] = cursor.getInt(trackColumn)
                map["year"] = cursor.getInt(yearColumn)
                
                audioList.add(map)
            }
        }
        return audioList
    }
}
