package com.calistrack.calistrack

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity è richiesto dal plugin local_auth per mostrare
// il prompt biometrico / di blocco del dispositivo.
class MainActivity : FlutterFragmentActivity() {
    private val channel = "calistrack/app_icon"

    // Alias disponibili (devono combaciare con AndroidManifest.xml).
    private val aliases = listOf(
        "IconDefault", "IconZeus", "IconCyberpunk", "IconSpartacus", "IconKratos"
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setIcon" -> {
                        val alias = call.argument<String>("alias")
                        if (alias == null || !aliases.contains(alias)) {
                            result.error("BAD_ARG", "Alias non valido", null)
                        } else {
                            setIcon(alias)
                            result.success(true)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun setIcon(target: String) {
        val pm = packageManager
        val pkg = packageName
        for (alias in aliases) {
            val state = if (alias == target) {
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            } else {
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED
            }
            pm.setComponentEnabledSetting(
                ComponentName(pkg, "$pkg.$alias"),
                state,
                PackageManager.DONT_KILL_APP
            )
        }
    }
}
