package com.swmansion.rnscreens.core.modals.formsheet

import org.junit.Assert.assertEquals
import org.junit.Test

class FormSheetPlacementTest {
    @Test fun flatAndCoverWindowsKeepMaterialSizing() {
        assertEquals(FormSheetPlacement(1560, 258), FormSheetPlacement.resolve(2076, 1560, null, true))
        assertEquals(FormSheetPlacement(1080, 0), FormSheetPlacement.resolve(1080, 1560, null, true))
    }

    @Test fun portraitBookStaysBeforeThePhysicalHinge() {
        assertEquals(FormSheetPlacement(1038, 0), FormSheetPlacement.resolve(2076, 1560, 1038, true))
        assertEquals(FormSheetPlacement(1560, 220), FormSheetPlacement.resolve(4000, 1560, 2000, true))
    }

    @Test fun landscapeAndInvalidHingesKeepTheFullWindow() {
        for (hinge in listOf(0, 2076, 3000)) {
            assertEquals(FormSheetPlacement(1560, 258), FormSheetPlacement.resolve(2076, 1560, hinge, true))
        }
        assertEquals(FormSheetPlacement(1560, 258), FormSheetPlacement.resolve(2076, 1560, 1038, false))
    }

    @Test fun placementRestoresWhenTheHingeReleasesOrWindowFolds() {
        val frames =
            listOf(
                FormSheetPlacement.resolve(2076, 1560, null, true),
                FormSheetPlacement.resolve(2076, 1560, 1038, true),
                FormSheetPlacement.resolve(1080, 1560, null, true),
                FormSheetPlacement.resolve(2076, 1560, null, true),
            )
        assertEquals(listOf(258, 0, 0, 258), frames.map { it.left })
        assertEquals(listOf(1560, 1038, 1080, 1560), frames.map { it.width })
    }
}
