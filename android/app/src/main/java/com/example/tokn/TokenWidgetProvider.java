package com.example.tokn;
import com.example.tokn.R;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.widget.RemoteViews;




import es.antonborri.home_widget.HomeWidgetPlugin;

/**
 * TokN Home Screen Widget – shows upcoming booking token details.
 */
public class TokenWidgetProvider extends AppWidgetProvider {

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        String hospitalName  = HomeWidgetPlugin.Companion.getData(context).getString("hospital", "City General");
        String servingNumber = HomeWidgetPlugin.Companion.getData(context).getString("serving",  "42");
        String mineNumber    = HomeWidgetPlugin.Companion.getData(context).getString("mine",     "48");
        String waitTime      = HomeWidgetPlugin.Companion.getData(context).getString("wait_time", "15");

        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_layout);
        views.setTextViewText(R.id.widget_hospital,    hospitalName);
        views.setTextViewText(R.id.widget_serving_num, "#" + servingNumber);
        views.setTextViewText(R.id.widget_mine_num,    "#" + mineNumber);
        views.setTextViewText(R.id.widget_wait_time,   "~" + waitTime + " mins wait");

        // Open App on click
        Intent intent = new Intent(context, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent);

        appWidgetManager.updateAppWidget(appWidgetId, views);

    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }
}
