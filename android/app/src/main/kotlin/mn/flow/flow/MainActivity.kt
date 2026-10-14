package mn.flow.flow

import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "mn.flow.flow/window")
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "setSecure" -> {
            if (call.arguments == true) {
              window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
            } else {
              window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            }
            result.success(null)
          }
          else -> result.notImplemented()
        }
      }
  }
}
