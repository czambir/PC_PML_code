//run("ImageJ2...", "scijavaio=true");
run("Options...", "iterations=1 count=1 black edm=8-bit");
run("Input/Output...", "jpeg=85 gif=-1 file=.xlsx use_file copy_row save_column save_row");
run("Colors...", "foreground=white background=black selection=cyan");
run("Line Width...", "line=2");
run("Set Measurements...", "area area_fraction limit redirect=None decimal=2");
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
		run("Bio-Formats Importer", "open=["+ImagePath+list[NumImages]+"] view=Hyperstack stack_order=XYCZT use_virtual_stack stitch_tiles");
		//open(ImagePath+list[NumImages]);
		
		//Your macro here
		ImageName = getTitle();

		run("Split Channels");
		selectWindow("C3-"+ImageName);
		setThreshold(10,255);
		run("Measure");
		TissueArea=getResult("Area",0);
		run("Subtract Background...", "rolling=50");
		run("Auto Local Threshold", "method=Phansalkar radius=15 parameter_1=0 parameter_2=0 white");
		run("Fill Holes");
		run("Watershed");
		run("Analyze Particles...", "size=50-Infinity pixel clear add");

		selectWindow("C2-"+ImageName);
		setThreshold(100,255);
		roiManager("Measure");
		NumCD3=0;
		CD3=newArray(nResults);
		CD3=Array.fill(CD3,0);
		for (i=0;i<nResults;i++) {
			data=getResult("%Area",i);
			if (data>25) {
				CD3[i]=1;
				NumCD3=NumCD3+1;
			}
		}
		run("Clear Results");
		
		selectWindow("C1-"+ImageName);
		setThreshold(100,255);
		roiManager("Measure");
		NumCD8=0;
		CD8=newArray(nResults);
		CD8=Array.fill(CD8,0);
		for (i=0;i<nResults;i++) {
			data=getResult("%Area",i);
			if (data>25) {
				CD8[i]=1;
				NumCD8=NumCD8+1;
			}
		}
		run("Clear Results");

		NumDouble=0;
		for (i=0;i<CD3.length;i++) {
			if (CD3[i]==1) {
				if (CD8[i]==1) {
					NumDouble=NumDouble+1;
				}				
			}
		}

		print(ImageName,"	",TissueArea,"	",NumCD3,"	",NumCD8,"	",NumDouble);
		run("Close All");
		run("Clear Results");
		roiManager("Reset");
		
	}

}
