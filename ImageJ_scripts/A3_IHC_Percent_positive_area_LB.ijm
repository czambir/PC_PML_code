//run("ImageJ2...", "scijavaio=true");
run("Options...", "iterations=1 count=1 black edm=8-bit");
run("Input/Output...", "jpeg=85 gif=-1 file=.xls use_file copy_row save_column save_row");
run("Colors...", "foreground=white background=black selection=cyan");
run("Line Width...", "line=2");
run("Set Measurements...", "area limit redirect=None decimal=2");
run("Clear Results");
roiManager("Reset");
run("Close All");

Dialog.create("Image Folder");
Dialog.addMessage("You'll be asked to select the folder with the images.");
Dialog.show();
ImagePath=getDirectory("Choose the folder with images");
list = getFileList(ImagePath);
list = Array.sort (list);

for (NumImages=0; NumImages<list.length; NumImages++) {
	if (endsWith(list[NumImages],"tif")) {
		run("Bio-Formats Importer", "open=["+ImagePath+list[NumImages]+"] color_mode=Default view=Hyperstack stack_order=XYCZT");
		//open(ImagePath+list[NumImages]);
		
		//Your macro here
		ImageName = getTitle();
		run("RGB Color");
		run("Colour Deconvolution", "vectors=[H DAB]");

		//Area of the CD45
		selectWindow(ImageName + " (RGB)-(Colour_2)");
		setThreshold(0, 170);
		//run("Measure");
		//CD45Area = getResult("Area",0);

		//Area of the Tissue
		selectWindow(ImageName + " (RGB)-(Colour_1)");
		setThreshold(0, 235);
		run("Measure");
		TissueArea = getResult("Area",0);
		run("Analyze Particles...", "size=80-Infinity exclude clear add");
		Count = roiManager("Count");
		
		print(ImageName,"	",Count,"	",TissueArea,"	",Count/TissueArea*100);

		run("Close All");
		run("Clear Results");
		roiManager("Reset");
		
	}
}
