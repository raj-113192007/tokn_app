package com.example.tokn

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class TokenWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Get data from Flutter HomeWidget
                val hospitalName = widgetData.getString("hospital", "No Hospital") ?: "No Hospital"
                val servingNum = widgetData.getString("serving", "-") ?: "-"
                val mineNum = widgetData.getString("mine", "-") ?: "-"
                val waitTime = widgetData.getString("wait_time", "0") ?: "0"

                // Update UI views
                setTextViewText(R.id.widget_hospital, hospitalName)
                setTextViewText(R.id.widget_serving_num, "#$servingNum")
                setTextViewText(R.id.widget_mine_num, "#$mineNum")
                setTextViewText(R.id.widget_wait_time, "~$waitTime mins wait")
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
