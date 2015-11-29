totalPlanes = 3000;
type = "[Grid: snake by columns]";
order = "[Up & Right]";
gridSizeX = 3;
gridSizeY = 3;
tileOverlap = 10;
firstIndex = 0;
inputDir = "Z:\\Data\\drawitschf\\stacks\\st002Top\\st002Flat";
outputDir = "Z:\\Data\\drawitschf\\stacks\\st002Top\\st002Stitched";
fileExpr = "2015-11-02_FD0128-2-HR_{iiiiiii}.tif";
fileOutputTrunk = "2015-11-02_FD0128-2-HR_"
regressionThreshold = 0.2;
relativeDisplacementThreshold = 2.5;
absoluteDisplacementThreshold = 3.5;
stdFname = "img_t1_z1_c1";

for (i=0; i<=totalPlanes; i++) {
	// Run Stitching
	runString = "type="+type+" order="+order+" grid_size_x="+gridSizeX+" grid_size_y="+gridSizeY+" tile_overlap="+tileOverlap+" first_file_index_i="+firstIndex+" directory="+inputDir+" file_names="+fileExpr+" output_textfile_name=TileConfiguration.txt"+" fusion_method=[Linear Blending]"+" regression_threshold="+regressionThreshold+" max/avg_displacement_threshold="+relativeDisplacementThreshold+" absolute_displacement_threshold="+absoluteDisplacementThreshold+" compute_overlap computation_parameters=[Save computation time (but use more RAM)]"+" image_output=[Write to disk] "+" output_directory="+outputDir;
	run("Grid/Collection stitching", runString);
	wait(3000);

	// Rename File
	fnameOld = outputDir+"\\"+stdFname;
	fnameNew = outputDir+"\\"+fileOutputTrunk+"_stitched_"+IJ.pad(i,5)+".tif";
	File.rename(fnameOld, fnameNew);

	// Update Index
	firstIndex = firstIndex + gridSizeX * gridSizeY;
}