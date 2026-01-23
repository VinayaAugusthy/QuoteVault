package com.example.quote_vault.widget

import android.content.Context
import org.json.JSONObject

data class QuoteOfDayWidgetQuote(
  val id: String,
  val body: String,
  val author: String
)

class QuoteOfDayWidgetStorage(context: Context) {
  private val prefs = context.getSharedPreferences("quote_of_day_widget", Context.MODE_PRIVATE)

  fun saveQuote(quote: QuoteOfDayWidgetQuote) {
    val json = JSONObject()
      .put("id", quote.id)
      .put("body", quote.body)
      .put("author", quote.author)
    prefs.edit().putString("quote", json.toString()).apply()
  }

  fun getQuote(): QuoteOfDayWidgetQuote? {
    val raw = prefs.getString("quote", null) ?: return null
    return try {
      val obj = JSONObject(raw)
      QuoteOfDayWidgetQuote(
        id = obj.optString("id", ""),
        body = obj.optString("body", ""),
        author = obj.optString("author", "")
      ).takeIf { it.id.isNotBlank() && it.body.isNotBlank() }
    } catch (_: Exception) {
      null
    }
  }
}


