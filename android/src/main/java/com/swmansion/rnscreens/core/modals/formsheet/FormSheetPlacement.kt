package com.swmansion.rnscreens.core.modals.formsheet

internal data class FormSheetPlacement(
    val width: Int,
    val left: Int,
) {
    companion object {
        fun resolve(
            windowWidth: Int,
            maxWidth: Int,
            hingeLeft: Int?,
            portrait: Boolean,
        ): FormSheetPlacement {
            val availableWidth =
                if (portrait && hingeLeft != null && hingeLeft in 1 until windowWidth) hingeLeft else windowWidth
            val width = minOf(availableWidth, maxWidth)
            return FormSheetPlacement(width, (availableWidth - width) / 2)
        }
    }
}
