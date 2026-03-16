package com.example.tokn;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.widget.RemoteViews;

import es.antonborri.home_widget.HomeWidgetPlugin;

/**
 * TokN Home Screen Widget – shows upcoming booking token details.
 */
public class TokenWidgetProvider extends AppWidgetProvider {

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        String widgetToken    = HomeWidgetPlugin.Companion.getData(context).getString("token",    "N/A");
        String widgetHospital = HomeWidgetPlugin.Companion.getData(context).getString("hospital", "N/A");
        String widgetTime     = HomeWidgetPlugin.Companion.getData(context).getString("time",     "N/A");

        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_layout);
        views.setTextViewText(R.id.widget_token,    widgetToken);
        views.setTextViewText(R.id.widget_hospital, "Hospital: " + widgetHospital);
        views.setTextViewText(R.id.widget_time,     "Time: "     + widgetTime);

        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }
}
