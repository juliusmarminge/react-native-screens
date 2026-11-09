package com.swmansion.rnscreens.core.modals.formsheet.dialog

import android.app.Activity
import android.content.Context
import android.content.res.Configuration
import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.view.WindowManager
import android.widget.FrameLayout
import androidx.coordinatorlayout.widget.CoordinatorLayout
import androidx.core.view.WindowCompat
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.swmansion.rnscreens.core.modals.formsheet.FormSheetPlacement
import com.swmansion.rnscreens.core.modals.formsheet.FormSheetPostureObserver

/**
 * A custom BottomSheetDialog override used to render the FormSheet native component.
 *
 * We enforce edge-to-edge rendering, bypassing standard Material checks.
 * This is required because our custom dimming logic needs the Dialog to span
 * the entire screen. The FormSheetContainer is sized manually against the system insets.
 */
internal class FormSheetDialog(
    context: Context,
    activityProvider: () -> Activity?,
) : BottomSheetDialog(context) {
    private val posture =
        FormSheetPostureObserver(activityProvider) {
            // A posture change keeps the window bounds, so invalidate both measurement branches.
            availableHeightProvider.requestLayout()
            findViewById<View>(com.google.android.material.R.id.design_bottom_sheet)?.requestLayout()
        }

    internal fun interface CancelRequestInterceptor {
        /**
         * Invoked in place of the dialog's default cancellation whenever an interceptor is attached.
         *
         * The interceptor fully owns the outcome - either for native dismissal prevention or for driving
         * a custom animated dismissal when allowed. Either way, the dialog skips
         * [BottomSheetDialog.cancel], which would tear the window down synchronously.
         */
        fun handleCancelRequest()
    }

    internal var cancelRequestInterceptor: CancelRequestInterceptor? = null

    /**
     * Installed next to Material's content once the dialog is created. Reports the height the sheet
     * is measured against so the sheet metrics can be resolved before the sheet itself is measured.
     */
    internal val availableHeightProvider = FormSheetAvailableHeightProvider(context)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        hideNativeDimmingView(window)
        disableNativeWindowAnimation(window)

        setupBottomSheetHeight()
        installAvailableHeightProvider()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()

        posture.start()
        forceEdgeToEdge()
    }

    override fun onDetachedFromWindow() {
        posture.stop()
        super.onDetachedFromWindow()
    }

    override fun cancel() {
        val interceptor = cancelRequestInterceptor
        if (interceptor == null) {
            super.cancel()
            return
        }

        interceptor.handleCancelRequest()
    }

    /**
     * Material's [BottomSheetDialog] only draws edge-to-edge when its theme opts in via the
     * `enableEdgeToEdge` attribute AND the navigation bar is translucent (see
     * `BottomSheetDialog#onAttachedToWindow`).
     *
     * We force edge-to-edge on every API level so the window content always spans the whole
     * screen.
     */
    private fun forceEdgeToEdge() {
        val window = window ?: return
        WindowCompat.setDecorFitsSystemWindows(window, false)
        findViewById<View>(com.google.android.material.R.id.container)?.fitsSystemWindows = false
        findViewById<View>(com.google.android.material.R.id.coordinator)?.fitsSystemWindows = false
    }

    private fun hideNativeDimmingView(window: Window?) = window?.clearFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND)

    private fun disableNativeWindowAnimation(window: Window?) = window?.setWindowAnimations(0)

    private fun setupBottomSheetHeight() {
        val bottomSheetView = findViewById<FrameLayout>(com.google.android.material.R.id.design_bottom_sheet)
        bottomSheetView?.let { sheet ->
            sheet.layoutParams.height = ViewGroup.LayoutParams.MATCH_PARENT
            availableHeightProvider.onAvailableWidthMeasured = { width ->
                if (isShowing) posture.start()
                val placement =
                    FormSheetPlacement.resolve(
                        width,
                        context.resources.getDimensionPixelSize(com.google.android.material.R.dimen.material_bottom_sheet_max_width),
                        posture.hingeLeft,
                        context.resources.configuration.orientation == Configuration.ORIENTATION_PORTRAIT,
                    )
                val params = sheet.layoutParams as CoordinatorLayout.LayoutParams
                params.width = placement.width
                params.leftMargin = placement.left
                params.gravity = Gravity.LEFT
                behavior.maxWidth = placement.width
            }
        }
    }

    private fun installAvailableHeightProvider() {
        if (availableHeightProvider.parent != null) {
            return
        }

        val contentParent = findViewById<ViewGroup>(android.R.id.content)
        if (contentParent == null) {
            Log.e(TAG, "[RNScreens] Window content view not found; the sheet dimensions won't be resolved.")
            return
        }

        // FrameLayout measures its children in order, so the provider reports the height before Material's container
        contentParent.addView(
            availableHeightProvider,
            0,
            FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT),
        )
    }

    companion object {
        private const val TAG = "FormSheetDialog"
    }
}
