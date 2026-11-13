package com.swmansion.rnscreens.core.modals.formsheet

import org.junit.Assert.assertEquals
import org.junit.Test

class FormSheetPlacementTest {
    @Test fun flatAndCoverWindowsKeepMaterialSizing() {
        assertEquals(FormSheetPlacement(1560, 258), FormSheetPlacement.resolve(2076, 1560, null))
        assertEquals(FormSheetPlacement(1080, 0), FormSheetPlacement.resolve(1080, 1560, null))
    }

    @Test fun bookStaysBeforeThePhysicalHinge() {
        assertEquals(FormSheetPlacement(1038, 0), FormSheetPlacement.resolve(2076, 1560, 1038))
        assertEquals(FormSheetPlacement(1560, 220), FormSheetPlacement.resolve(4000, 1560, 2000))
        // Wide inner displays, such as the Galaxy Z Fold 8's, report book posture as landscape.
        assertEquals(FormSheetPlacement(1224, 0), FormSheetPlacement.resolve(2448, 1560, 1224))
    }

    @Test fun invalidHingesKeepTheFullWindow() {
        for (hinge in listOf(0, 2076, 3000)) {
            assertEquals(FormSheetPlacement(1560, 258), FormSheetPlacement.resolve(2076, 1560, hinge))
        }
    }

    @Test fun placementRestoresWhenTheHingeReleasesOrWindowFolds() {
        val frames =
            listOf(
                FormSheetPlacement.resolve(2076, 1560, null),
                FormSheetPlacement.resolve(2076, 1560, 1038),
                FormSheetPlacement.resolve(1080, 1560, null),
                FormSheetPlacement.resolve(2076, 1560, null),
            )
        assertEquals(listOf(258, 0, 0, 258), frames.map { it.left })
        assertEquals(listOf(1560, 1038, 1080, 1560), frames.map { it.width })
    }
}
