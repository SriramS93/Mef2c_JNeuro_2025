// Fiji Macro to open all .czi files as virtual stack in a chosen folder, 
//Then sum total intensisty in each channel (DAPI, tdTomato, and EGFP, in that order) of the image across all z-sections,
//Print the values in the ImageJ log
// Ensure Bio-Formats plugin is available in Fiji for this macro to work

// Ask the user to choose the input directory
inputDir = getDirectory("Choose a Directory containing the .czi files");

fileList = getFileList(inputDir);
print("FileName, DAPI Intensity, tdTomato Intensity, EGFP Intensity, Ratio EGFP/tdT");

for (i = 0; i < fileList.length; i++) {
	filename = fileList[i];

    // Process only .czi files
    if (endsWith(filename, ".czi")) {
    	filepath = inputDir + filename;
        //print("Opening: " + filepath);

        run("Bio-Formats Importer", "open=[" + filepath + "] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT use_virtual_stack");
        id = getImageID();
        selectImage(id);
    	imageTitle = getTitle();

    	// Get the number of channels and slices (z-planes)
   		Stack.getDimensions(width, height, channels, slices, frames);
		// Initialize arrays to store total intensities for each channel
    	totalIntensity = newArray(0,0,0);
    	// Loop through slices
    	for (z = 1; z <= slices; z++) {
        	// Loop through channels for the current z-slcie
        	for (c = 1; c <= channels; c++) {
            	Stack.setSlice(z);
            	Stack.setChannel(c);
            	getRawStatistics(nPixels, mean, min, max, std, histogram);
            	totalIntensity[(c-1)] += mean * width * height;
        	}
        
    	}

    	// Calculate the ratio (Channel 3 Intensity / Channel 2 Intensity)
    	ratio = totalIntensity[2] / totalIntensity[1];

   		// Print the result in the specified format
    	print(imageTitle + ", " +  totalIntensity[0] + ", " +  totalIntensity[1] + ", " +
          totalIntensity[2] + ", " + ratio);
        close("*");        
    }
    else {
    print("No directory selected. Macro aborted.");
	}
}	