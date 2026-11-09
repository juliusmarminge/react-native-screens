package com.swmansion.rnscreens.core.modals.formsheet

import android.app.Activity
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import androidx.window.layout.FoldingFeature
import androidx.window.layout.WindowInfoTracker
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/** The same vertical book posture used by the workspace, shared by both sheet implementations. */
internal class FormSheetPostureObserver(
    private val activityProvider: () -> Activity?,
    private val onChange: () -> Unit,
) : SensorEventListener {
    private var scope: CoroutineScope? = null
    private var fold: FoldingFeature? = null
    private var sensorManager: SensorManager? = null
    private var hingeSensor: Sensor? = null
    private var bent: Boolean? = null
    private var listening = false
    internal var hingeLeft: Int? = null
        private set

    fun start() {
        if (scope != null) return
        val activity = activityProvider() ?: return
        sensorManager = activity.getSystemService(SensorManager::class.java)
        hingeSensor =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) sensorManager?.getDefaultSensor(Sensor.TYPE_HINGE_ANGLE) else null
        scope =
            MainScope().also { scope ->
                scope.launch {
                    WindowInfoTracker.getOrCreate(activity).windowLayoutInfo(activity).collect { info ->
                        fold =
                            info.displayFeatures.filterIsInstance<FoldingFeature>().firstOrNull {
                                it.orientation == FoldingFeature.Orientation.VERTICAL
                            }
                        listen(fold != null)
                        report()
                    }
                }
            }
    }

    fun stop() {
        scope?.cancel()
        scope = null
        listen(false)
        fold = null
        hingeLeft = null
    }

    override fun onSensorChanged(event: SensorEvent) {
        // Match workspace hysteresis: nearly flat Pixel hinges rest at 175 degrees.
        bent = if (bent == true) event.values[0] < 175f else event.values[0] <= 170f
        report()
    }

    override fun onAccuracyChanged(
        sensor: Sensor?,
        accuracy: Int,
    ) = Unit

    private fun listen(enabled: Boolean) {
        if (enabled == listening || hingeSensor == null) return
        listening = enabled
        if (enabled) {
            sensorManager?.registerListener(this, hingeSensor, SensorManager.SENSOR_DELAY_UI)
        } else {
            sensorManager?.unregisterListener(this)
            bent = null
        }
    }

    private fun report() {
        val feature = fold
        val next = feature?.takeIf { bent ?: (it.state == FoldingFeature.State.HALF_OPENED) }?.bounds?.left
        if (hingeLeft == next) return
        hingeLeft = next
        onChange()
    }
}
