package com.aura.aura

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class AuraMusicWidget : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val trackTitle = widgetData.getString("track_title", "Aura Music")
                val trackArtist = widgetData.getString("track_artist", "Tap to start listening")
                val isPlaying = widgetData.getBoolean("is_playing", false)

                setTextViewText(R.id.track_title, trackTitle)
                setTextViewText(R.id.track_artist, trackArtist)

                if (isPlaying) {
                    setImageViewResource(R.id.btn_play_pause, android.R.drawable.ic_media_pause)
                } else {
                    setImageViewResource(R.id.btn_play_pause, android.R.drawable.ic_media_play)
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
