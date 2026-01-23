package com.example.quote_vault.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.OutOfQuotaPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import com.example.quote_vault.MainActivity
import com.example.quote_vault.R
import java.time.Duration
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.ZoneId
import java.util.concurrent.TimeUnit

class QuoteOfDayWidgetProvider : AppWidgetProvider() {
  override fun onEnabled(context: Context) {
    super.onEnabled(context)
    enqueuePeriodicRefresh(context)
    enqueueImmediateRefresh(context)
  }

  override fun onUpdate(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray
  ) {
    super.onUpdate(context, appWidgetManager, appWidgetIds)

    // Render cached content immediately.
    for (appWidgetId in appWidgetIds) {
      updateWidgetFromCache(context, appWidgetManager, appWidgetId)
    }

    enqueuePeriodicRefresh(context)
    enqueueImmediateRefresh(context)
  }

  companion object {
    private const val UNIQUE_PERIODIC_WORK = "quote_of_day_widget_periodic"
    private const val UNIQUE_ONE_TIME_WORK = "quote_of_day_widget_one_time"
    private const val EXTRA_OPEN_QUOTE_OF_DAY = "open_quote_of_day"

    fun updateAllWidgets(context: Context) {
      val manager = AppWidgetManager.getInstance(context)
      val ids = manager.getAppWidgetIds(
        android.content.ComponentName(context, QuoteOfDayWidgetProvider::class.java)
      )
      for (id in ids) {
        updateWidgetFromCache(context, manager, id)
      }
    }

    private fun updateWidgetFromCache(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetId: Int
    ) {
      val prefs = QuoteOfDayWidgetStorage(context)
      val quote = prefs.getQuote()

      val views = RemoteViews(context.packageName, R.layout.widget_quote_of_day)
      views.setTextViewText(R.id.widget_body, quote?.body ?: "Loading...")
      views.setTextViewText(R.id.widget_author, "– ${quote?.author ?: "QuoteVault Daily"}")

      // Tap should open the app's home screen (no quote detail deep-link).
      val intent = Intent(context, MainActivity::class.java).apply {
        putExtra(EXTRA_OPEN_QUOTE_OF_DAY, true)
        addFlags(
          Intent.FLAG_ACTIVITY_NEW_TASK or
            Intent.FLAG_ACTIVITY_CLEAR_TOP or
            Intent.FLAG_ACTIVITY_SINGLE_TOP
        )
      }

      val flags = PendingIntent.FLAG_UPDATE_CURRENT or
        (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
      val pendingIntent = PendingIntent.getActivity(context, appWidgetId, intent, flags)
      views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

      appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun enqueueImmediateRefresh(context: Context) {
      val constraints = Constraints.Builder()
        .setRequiredNetworkType(NetworkType.CONNECTED)
        .build()
      val req = OneTimeWorkRequestBuilder<QuoteOfDayWidgetWorker>()
        .setConstraints(constraints)
        // Best-effort: run ASAP so the widget doesn't sit on "Loading...".
        .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
        .build()
      WorkManager.getInstance(context).enqueueUniqueWork(
        UNIQUE_ONE_TIME_WORK,
        ExistingWorkPolicy.REPLACE,
        req
      )
    }

    private fun enqueuePeriodicRefresh(context: Context) {
      val initialDelay = computeInitialDelayToNextLocalMidnightPlus(minutes = 5)
      val constraints = Constraints.Builder()
        .setRequiredNetworkType(NetworkType.CONNECTED)
        .build()

      val req = PeriodicWorkRequestBuilder<QuoteOfDayWidgetWorker>(1, TimeUnit.DAYS)
        .setInitialDelay(initialDelay.toMillis(), TimeUnit.MILLISECONDS)
        .setConstraints(constraints)
        .build()

      WorkManager.getInstance(context).enqueueUniquePeriodicWork(
        UNIQUE_PERIODIC_WORK,
        ExistingPeriodicWorkPolicy.UPDATE,
        req
      )
    }

    private fun computeInitialDelayToNextLocalMidnightPlus(minutes: Long): Duration {
      val zone = ZoneId.systemDefault()
      val now = LocalDateTime.now(zone)
      val next = LocalDate.now(zone).plusDays(1).atTime(LocalTime.MIDNIGHT).plusMinutes(minutes)
      val diff = Duration.between(now, next)
      return if (diff.isNegative) Duration.ofMinutes(1) else diff
    }
  }
}


