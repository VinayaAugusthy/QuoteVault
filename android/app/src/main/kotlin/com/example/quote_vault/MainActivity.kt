package com.example.quote_vault

import android.content.ContentValues
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
  companion object {
    private const val CHANNEL = "quote_vault/gallery_saver"
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "saveImage" -> {
            val bytes = call.argument<ByteArray>("bytes")
            val fileName = call.argument<String>("fileName") ?: "quote.png"
            if (bytes == null) {
              result.error("invalid_args", "Missing bytes", null)
              return@setMethodCallHandler
            }
            try {
              val saved = savePngToGallery(bytes, fileName)
              result.success(saved)
            } catch (e: Exception) {
              result.error("save_failed", e.message, null)
            }
          }

          else -> result.notImplemented()
        }
      }
  }

  private fun savePngToGallery(bytes: ByteArray, fileName: String): String? {
    val resolver = applicationContext.contentResolver

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      val values = ContentValues().apply {
        put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
        put(MediaStore.Images.Media.MIME_TYPE, "image/png")
        put(MediaStore.Images.Media.RELATIVE_PATH, "${Environment.DIRECTORY_PICTURES}/QuoteVault")
        put(MediaStore.Images.Media.IS_PENDING, 1)
      }

      val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values) ?: return null
      resolver.openOutputStream(uri)?.use { stream ->
        stream.write(bytes)
        stream.flush()
      }

      values.clear()
      values.put(MediaStore.Images.Media.IS_PENDING, 0)
      resolver.update(uri, values, null, null)

      return uri.toString()
    }

    // Legacy fallback (API < 29)
    val picturesDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
    val appDir = File(picturesDir, "QuoteVault")
    if (!appDir.exists()) appDir.mkdirs()

    val outFile = File(appDir, fileName)
    FileOutputStream(outFile).use { stream ->
      stream.write(bytes)
      stream.flush()
    }

    MediaScannerConnection.scanFile(
      applicationContext,
      arrayOf(outFile.absolutePath),
      arrayOf("image/png"),
      null
    )

    return outFile.absolutePath
  }
}
