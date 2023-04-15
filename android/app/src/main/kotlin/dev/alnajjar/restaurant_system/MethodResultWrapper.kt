import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class MethodResultWrapper constructor(private val methodResult: MethodChannel.Result) :
    MethodChannel.Result {
    private val handler: Handler = Handler(Looper.getMainLooper())

    fun ignoreIllegalState(fn: () -> Unit) {
        try {
            fn()
        } catch (e: IllegalStateException) {
            Log.d(
                "IllegalStateException",
                "ignoring exception: $e. See https://github.com/flutter/flutter/issues/29092 for details."
            )
        }
    }

    override fun success(result: Any?) {
        handler.post {
            ignoreIllegalState {
                methodResult.success(result)
            }

        }
    }

    override fun error(
        errorCode: String, errorMessage: String?, errorDetails: Any?
    ) {
        handler.post { methodResult.error(errorCode, errorMessage, errorDetails) }
    }

    override fun notImplemented() {
        handler.post { methodResult.notImplemented() }
    }
}