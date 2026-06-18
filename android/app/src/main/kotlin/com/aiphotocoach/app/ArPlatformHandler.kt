package com.aiphotocoach.app

import android.app.Activity
import com.google.ar.core.ArCoreApk
import com.google.ar.core.Config
import com.google.ar.core.Session
import com.google.ar.core.TrackingState
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

class ArPlatformHandler(private val activity: Activity) :
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null
    private var session: Session? = null
    private var pollJob: Job? = null
    private val scope = CoroutineScope(Dispatchers.Default)

    override fun onMethodCall(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkSupport" -> result.success(checkSupport())
            "startSession" -> {
                startSession()
                result.success(null)
            }
            "stopSession" -> {
                stopSession()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun checkSupport(): Map<String, Any> {
        val availability = ArCoreApk.getInstance().checkAvailability(activity)
        val supported = availability.isSupported
        return mapOf(
            "isSupported" to supported,
            "planeState" to if (supported) "searching" else "unsupported",
            "horizontalPlanes" to 0,
        )
    }

    private fun startSession() {
        stopSession()
        val availability = ArCoreApk.getInstance().checkAvailability(activity)
        if (!availability.isSupported) {
            emitStatus("unsupported", 0)
            return
        }

        try {
            if (ArCoreApk.getInstance().requestInstall(activity, true) != ArCoreApk.InstallStatus.INSTALLED) {
                emitStatus("unavailable", 0)
                return
            }
            session = Session(activity).apply {
                configure(
                    Config(this).apply {
                        planeFindingMode = Config.PlaneFindingMode.HORIZONTAL
                        updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
                    },
                )
            }
            pollJob = scope.launch {
                while (isActive) {
                    updatePlaneStatus()
                    delay(700)
                }
            }
        } catch (_: Exception) {
            emitStatus("unavailable", 0)
        }
    }

    private fun stopSession() {
        pollJob?.cancel()
        pollJob = null
        session?.close()
        session = null
        emitStatus("searching", 0)
    }

    private fun updatePlaneStatus() {
        val current = session ?: run {
            emitStatus("unavailable", 0)
            return
        }
        try {
            val frame = current.update()
            if (frame.camera.trackingState != TrackingState.TRACKING) {
                emitStatus("searching", 0)
                return
            }
            val planes = current.getAllTrackables(com.google.ar.core.Plane::class.java)
                .count { it.trackingState == TrackingState.TRACKING && it.type == com.google.ar.core.Plane.Type.HORIZONTAL_UPWARD_FACING }
            emitStatus(if (planes > 0) "detected" else "searching", planes)
        } catch (_: Exception) {
            emitStatus("searching", 0)
        }
    }

    private fun emitStatus(state: String, planes: Int) {
        val payload = mapOf(
            "isSupported" to true,
            "planeState" to state,
            "horizontalPlanes" to planes,
        )
        activity.runOnUiThread {
            eventSink?.success(payload)
        }
    }
}