# fijiCubing

2015-11-29
florian.drawitsch@brain.mpg.de

1. Use the matlab script "writeTileHierarchyToFlat.m" to copy your image data into a single folder (not elegant, feel free do develop a better solution which doesnt create such an overhead)
2. Use the fiji macro stitchSequenceOfGrids2.ijm (which iterates over the plugin Grid/Collection stitching) to stitch all of your planes.
3. Manually parse your planes for debris and write down the slice ids
4. Use the matlab script replaceDebrisSlices.m to replace debris slices with the preceding slices
5. Use normalizeTifSeries.m to normalize your images (shifts histogram center followed by filling up dynamic range)
6. Use the matlab script padTifSeriesSymmetrically.m to make your slice uniform in size as well as to create some room for shifts during z alginment
7. Use the fiji plugin Registration/Register virtual stack slices. Check the "save transforms" options in case you need the parameters later
8. Use the matlab script removeExcessPadding to remove unneeded padding surrounding your aligned slices.
9. Write out the cubes using the KNOSSOSmaker_gaussfilter package. Make sure you use at least 2d filtering for mag generation to prevent aliasing (width = 3, sigma = 0.5 works fine for 2d filtering)
