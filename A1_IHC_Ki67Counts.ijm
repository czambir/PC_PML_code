//run("ImageJ2...", "scijavaio=true");
run("Options...", "iterations=5 count=1 black edm=8-bit");
run("Input/Output...", "jpeg=85 gif=-1 file=.xlsx use_file copy_row save_column save_row");
run("Colors...", "foreground=white background=black selection=cyan");
run("Line Width...", "line=2");
run("Set Measurements...", "area shape limit redirect=None decimal=2");
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
		run("Bio-Formats Importer", "open=["+ImagePath+list[NumImages]+"] view=Hyperstack stack_order=XYCZT stitch_tiles");
		//open(ImagePath+list[NumImages]);
		
		//Your macro here
		run("Flatten");
		ImageName = getTitle();
		run("Colour Deconvolution", "vectors=[H DAB]");

		selectWindow(ImageName+"-(Colour_1)");
		setThreshold(0,250);
		run("Measure");
		TissueArea=getResult("Area",0);
		run("Clear Results");
		
		selectWindow(ImageName+"-(Colour_2)");
		run("Median...", "radius=4");
		setThreshold(0,100);
		run("Analyze Particles...", "size=50-Infinity circularity=0.50-1.00 clear add");
		roiManager("Measure");

		AreaList=newArray(nResults);
		ARList=newArray(nResults);
		for (i=0;i<nResults;i++) {
			AreaList[i]=getResult("Area",i);
			ARList[i]=getResult("AR",i);		
		}

		
		print(ImageName,"	",TissueArea,"	",nResults);
		for (i=0;i<nResults;i++) {
			roiManager("Select",i);
			print("-","	","-","	","-","	",(i+1),"	",AreaList[i],"	",ARList[i]);
		}

		run("Close All");
		run("Clear Results");
		roiManager("Reset");
		
	}
}
