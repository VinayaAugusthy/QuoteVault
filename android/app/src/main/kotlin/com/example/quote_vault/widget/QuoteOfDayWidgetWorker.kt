package com.example.quote_vault.widget

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.example.quote_vault.BuildConfig
import org.json.JSONArray
import java.net.HttpURLConnection
import java.net.URL
import java.time.LocalDate
import java.time.ZoneOffset

class QuoteOfDayWidgetWorker(
  appContext: Context,
  params: WorkerParameters
) : CoroutineWorker(appContext, params) {

  // Mirrors lib/features/quotes/data/datasources/quote_remote_datasource.dart
  private val dailyQuoteSeedUtc = LocalDate.of(2024, 1, 1)

  override suspend fun doWork(): Result {
    return try {
      val count = fetchQuotesCount() ?: return Result.retry()
      if (count <= 0) return Result.success()

      val offsetDays = LocalDate.now(ZoneOffset.UTC).toEpochDay() - dailyQuoteSeedUtc.toEpochDay()
      val index = (offsetDays % count).toInt()

      val quote = fetchQuoteAtOffset(index) ?: return Result.retry()
      QuoteOfDayWidgetStorage(applicationContext).saveQuote(quote)
      QuoteOfDayWidgetProvider.updateAllWidgets(applicationContext)
      Result.success()
    } catch (_: Exception) {
      Result.retry()
    }
  }

  private fun fetchQuotesCount(): Long? {
    // Ask PostgREST for an exact count but return 0 rows (faster).
    val url = URL("${BuildConfig.SUPABASE_URL}/rest/v1/quotes?select=id&limit=0")
    val conn = (url.openConnection() as HttpURLConnection).apply {
      requestMethod = "GET"
      connectTimeout = 12_000
      readTimeout = 12_000
      setRequestProperty("apikey", BuildConfig.SUPABASE_ANON_KEY)
      setRequestProperty("Authorization", "Bearer ${BuildConfig.SUPABASE_ANON_KEY}")
      setRequestProperty("Accept", "application/json")
      setRequestProperty("Prefer", "count=exact")
    }

    return try {
      conn.connect()
      if (conn.responseCode !in 200..299) return null
      // Content-Range example: "0-0/1234"
      val contentRange = conn.getHeaderField("Content-Range") ?: return null
      val slashIndex = contentRange.lastIndexOf('/')
      if (slashIndex == -1) return null
      val totalStr = contentRange.substring(slashIndex + 1)
      // If PostgREST returns "*" (unknown), treat as failure so we retry.
      if (totalStr == "*" || totalStr.isBlank()) return null
      totalStr.toLongOrNull()
    } finally {
      conn.disconnect()
    }
  }

  private fun fetchQuoteAtOffset(offset: Int): QuoteOfDayWidgetQuote? {
    val url = URL(
      "${BuildConfig.SUPABASE_URL}/rest/v1/quotes" +
        "?select=id,body,author,created_at" +
        "&order=created_at.asc" +
        "&limit=1" +
        "&offset=$offset"
    )
    val conn = (url.openConnection() as HttpURLConnection).apply {
      requestMethod = "GET"
      connectTimeout = 12_000
      readTimeout = 12_000
      setRequestProperty("apikey", BuildConfig.SUPABASE_ANON_KEY)
      setRequestProperty("Authorization", "Bearer ${BuildConfig.SUPABASE_ANON_KEY}")
      setRequestProperty("Accept", "application/json")
    }

    return try {
      conn.connect()
      if (conn.responseCode !in 200..299) return null
      val body = conn.inputStream.bufferedReader().use { it.readText() }
      val arr = JSONArray(body)
      if (arr.length() == 0) return null
      val obj = arr.getJSONObject(0)
      QuoteOfDayWidgetQuote(
        id = obj.optString("id", ""),
        body = obj.optString("body", ""),
        author = obj.optString("author", "QuoteVault Daily")
      ).takeIf { it.id.isNotBlank() && it.body.isNotBlank() }
    } finally {
      conn.disconnect()
    }
  }

}


