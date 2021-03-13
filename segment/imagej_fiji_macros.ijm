// ------------------------------------------------------------------------------------
// ImageJ/FIJI Binary Lesion Segmentation Proofreading Macros
//
// (c) Philipp Tschandl 2021
//
// You may re-use this code under the CC BY-NC 4.0 license.
// This code was used to revisit, check and correct automated lesion segmentations for:
// 		Tschandl, P. et al. Human–computer collaboration for skin cancer recognition. 
// 		Nat Med 26, 1229–1234 (2020). https://doi.org/10.1038/s41591-020-0942-0
//
// Images should be placed as:
// 		"/PATH/TO/YOUR/DATASET/IMAGES/ImageName1.jpg" ...
// Automated segmentations should be placed as:
// 		"/PATH/TO/YOUR/DATASET/SEGMENTATIONS_AUTOMATED/ImageName1_segmentation.png" ...
// Corrected segmentations will be stored as:
// 		"/PATH/TO/YOUR/DATASET/SEGMENTATIONS_CORRECTED/ImageName1_segmentation.png" ...
//
// ------------------------------------------------------------------------------------


// If you don't want to select the folders after every restart you can hard-code them here
var lesionImagesPath =  "/PATH/TO/YOUR/DATASET/IMAGES/";
var lesionAutoSegmentationsPath =  "/PATH/TO/YOUR/DATASET/SEGMENTATIONS_AUTOMATED/";
var lesionCorrectedSegmentationsPath =  "/PATH/TO/YOUR/DATASET/SEGMENTATIONS_CORRECTED/";


// Set the source and target folders
macro "setSegmentationPaths" {
	showMessage("Set paths for [1] Images, [2] Automated Segmentations, [3] Corrected Segmentations.");
	lesionImagesPath=getDirectory("Directory of raw images (*ID*.img)");
	lesionAutoSegmentationsPath=getDirectory("Directory of automated segmentations (*ID*_segmentation.png)");
	lesionCorrectedSegmentationsPath=getDirectory("Directory of corrected segmentations (*ID*_segmentation.png)"); 
	showMessage("[1] Images: "+lesionImagesPath + " -- \n[2] Automated Segmentations: " + lesionAutoSegmentationsPath + " -- \n[3] Corrected Segmentations: " + lesionCorrectedSegmentationsPath);
}


// Loads the corresponding mask to the opened image and converts it into a selection
macro "loadBinaryMaskAnnotation... [l]" {

	if ((lesionImagesPath == "") | (lesionAutoSegmentationsPath == "") | (lesionCorrectedSegmentationsPath == ""))
		exit("You need to run 'setSegmentationsPaths' before using this command!");
	
	imageid = getTitle;
	lesionid = getTitle;
	dot = indexOf(lesionid, "."); 
	if (dot >= 0) lesionid = substring(lesionid, 0, dot); 
	
	target = lesionCorrectedSegmentationsPath+lesionid+"_segmentation.png";
	autoseg = lesionAutoSegmentationsPath+lesionid+"_segmentation.png";
	
	if (File.exists(target))
	    open(target);
	else
	    open(autoseg);
	
	if (File.exists(target))
	    showStatus("MANUAL segmentation loaded");
	else
	    showStatus("AUTOMATED segmentation loaded");
	
	selectWindow(lesionid+"_segmentation.png");
	run("Invert");
	run("Create Selection");
	selectWindow(imageid);
	run("Restore Selection");
	
	selectWindow(lesionid+"_segmentation.png");
	close();
	selectWindow(imageid);
	// Optional, depending on the automated segmentations:
	// run("Enlarge...", "enlarge=2");
}


// Stores the current selection as a binary mask
macro "Store Seg as Mask... [e]" {

	if ((lesionImagesPath == "") | (lesionAutoSegmentationsPath == "") | (lesionCorrectedSegmentationsPath == ""))
		exit("You need to run 'setSegmentationsPaths' before using this command!");
	
	imageid=getTitle;
	lesionid=getTitle;
	dot = indexOf(lesionid, "."); 
	if (dot >= 0) lesionid = substring(lesionid, 0, dot); 
	run("Create Mask");
	path = lesionCorrectedSegmentationsPath+lesionid+"_segmentation.png";
	saveAs("PNG", path);
	close();
	selectWindow(imageid);
	run("Open Next");
	run("Select None");
	run("loadBinaryMaskAnnotation... [l]");
}


// Checks images and target folder, returns how many are finished, 
// ...and opens the first image without a corrected segmentation mask
macro "Get first unsegmented image... [u]" {

	if ((lesionImagesPath == "") | (lesionAutoSegmentationsPath == "") | (lesionCorrectedSegmentationsPath == ""))
		exit("You need to run 'setSegmentationsPaths' before using this command!");

	showMessage("Getting files from:\n" + lesionImagesPath);
	list = getFileList(lesionImagesPath);
	for (i = 0; i < list.length; i++) {
		imageid = list[i];
		lesionid = list[i];
		dot = indexOf(lesionid, "."); 
		if (dot >= 0) lesionid = substring(lesionid, 0, dot); 
	    target = lesionCorrectedSegmentationsPath+lesionid+"_segmentation.png";
	    if (File.exists(target)) {
		    showStatus(lesionid+" already segmented.");
	    } else {
	    	showMessage("Continue labeling at: "+lesionid);
			open(lesionImagesPath + list[i]);
			i = 99999999;
		}
	}
	seglist = getFileList(lesionCorrectedSegmentationsPath);
	showMessage("Already segmented "+seglist.length+" of "+list.length+" images");
	setTool("freehand");
	run("loadBinaryMaskAnnotation... [l]");
}
