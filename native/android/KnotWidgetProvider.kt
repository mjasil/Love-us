package com.flovex.knot

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.net.URL
import kotlin.concurrent.thread

class KnotWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        val url = prefs.getString("latest_url", null)

        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.knot_widget)
            if (url != null) {
                thread {
                    try {
                        val bmp = BitmapFactory.decodeStream(URL(url).openStream())
                        views.setImageViewBitmap(R.id.widget_image, bmp)
                        appWidgetManager.updateAppWidget(id, views)
                    } catch (_: Exception) {}
                }
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
