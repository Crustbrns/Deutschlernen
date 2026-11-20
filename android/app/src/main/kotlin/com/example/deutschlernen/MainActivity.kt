package com.example.deutschlernen

import android.os.Build
import android.view.inputmethod.InputMethodManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Keyboard languages for the language sheet (DeviceLanguagesService).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "deutschlernen/device_languages")
            .setMethodCallHandler { call, result ->
                if (call.method == "keyboardLanguages") {
                    result.success(keyboardLanguages())
                } else {
                    result.notImplemented()
                }
            }
    }

    // Languages of the enabled keyboards. Some keyboards (e.g. Samsung's)
    // report none; the Dart side adds the system languages after these.
    // `locale` is deprecated but the only field before API 24.
    @Suppress("DEPRECATION")
    private fun keyboardLanguages(): List<String> {
        val imm = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
        return imm.enabledInputMethodList.flatMap { ime ->
            imm.getEnabledInputMethodSubtypeList(ime, true).mapNotNull { subtype ->
                val tag = if (Build.VERSION.SDK_INT >= 24) subtype.languageTag else ""
                tag.ifEmpty { subtype.locale }.ifEmpty { null }
            }
        }
    }
}
