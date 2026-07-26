package com.calistrack.calistrack

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/// Widget da schermata home: mostra battiti e passi, con deep-link all'app.
class CaliWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.cali_widget).apply {
                val bpm = widgetData.getString("bpm", "--") ?: "--"
                val steps = widgetData.getString("steps", "--") ?: "--"
                val rank = widgetData.getString("rank", "CaliStrack") ?: "CaliStrack"

                setTextViewText(R.id.widget_bpm, bpm)
                setTextViewText(R.id.widget_steps, steps)
                setTextViewText(R.id.widget_rank, rank)

                // Tap sull'intero widget -> apre la sezione Salute.
                val openHealth = HomeWidgetLaunchIntent.getActivity(
                    context, MainActivity::class.java, Uri.parse("caliwidget://health")
                )
                setOnClickPendingIntent(R.id.widget_root, openHealth)

                // Tap sui passi -> apre la Home/Dashboard.
                val openDash = HomeWidgetLaunchIntent.getActivity(
                    context, MainActivity::class.java, Uri.parse("caliwidget://dashboard")
                )
                setOnClickPendingIntent(R.id.widget_steps_box, openDash)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
