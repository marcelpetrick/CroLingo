package it.marcelpetrick.crolingo

import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity(), TextToSpeech.OnInitListener {
    private var speech: TextToSpeech? = null
    private var speechReady = false
    private var speechUnavailable = false
    private val pending = mutableListOf<Pair<String, MethodChannel.Result>>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        speech = TextToSpeech(applicationContext, this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "it.marcelpetrick.crolingo/speech",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "speakCroatian" -> {
                    val text = call.arguments as? String
                    if (text.isNullOrBlank()) {
                        result.success("failed")
                    } else if (speechReady) {
                        speak(text, result)
                    } else if (speechUnavailable) {
                        result.success("unavailable")
                    } else {
                        pending.add(text to result)
                    }
                }
                "stop" -> {
                    speech?.stop()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onInit(status: Int) {
        val locale = Locale.forLanguageTag("hr-HR")
        val availability = if (status == TextToSpeech.SUCCESS) {
            speech?.isLanguageAvailable(locale) ?: TextToSpeech.LANG_NOT_SUPPORTED
        } else {
            TextToSpeech.LANG_NOT_SUPPORTED
        }
        speechReady = availability >= TextToSpeech.LANG_AVAILABLE &&
            speech?.setLanguage(locale) != TextToSpeech.LANG_NOT_SUPPORTED &&
            speech?.setSpeechRate(0.85f) == TextToSpeech.SUCCESS
        speechUnavailable = !speechReady
        val waiting = pending.toList()
        pending.clear()
        waiting.forEach { (text, result) ->
            if (speechReady) speak(text, result) else result.success("unavailable")
        }
    }

    private fun speak(text: String, result: MethodChannel.Result) {
        val status = speech?.speak(
            text,
            TextToSpeech.QUEUE_FLUSH,
            null,
            "crolingo-${System.nanoTime()}",
        )
        result.success(if (status == TextToSpeech.SUCCESS) "spoken" else "failed")
    }

    override fun onDestroy() {
        pending.forEach { (_, result) -> result.success("failed") }
        pending.clear()
        speech?.stop()
        speech?.shutdown()
        speech = null
        super.onDestroy()
    }
}
