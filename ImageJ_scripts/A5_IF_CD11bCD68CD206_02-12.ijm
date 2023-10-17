//run("ImageJ2...", "scijavaio=true");
run("Options...", "iterations=2 count=1 black edm=8-bit");
run("Input/Output...", "jpeg=85 gif=-1 file=.xls use_file copy_row save_column save_row");
run("Colors...", "foreground=white background=black selection=cyan");
run("Line Width...", "line=2");
run("Set Measurements...", "area mean area_fraction limit redirect=None decimal=2");
run("Clear Results");
roiManager("Reset");
run("Close All");

Dialog.create("Image Folder");
Dialog.addMessage("You'll be asked to select the folder with the images.");
Dialog.show();
mainDir=getDirectory("Choose the folder with images");
mainList = getFileList(mainDir);
mainList = Array.sort(mainList);

print("Image Name","	","Cell Count","	","CD68+","	","CD11b+","	","CD68+ CD11b+","	","CD206 intensity");

for (i=0; i<mainList.length; i++) {
	if (endsWith(mainList[i], "/")) {
		subDir = mainDir + mainList[i];
		subList = getFileList(subDir);
		subList = Array.sort(subList);
		run("Bio-Formats Importer", "open=["+subDir+subList[0]+"] color_mode=Default view=Hyperstack stack_order=XYCZT");
		ImageName = getTitle();
		getDimensions(width, height, channels, slices, frames);
		run("Scale...", "x=0.25 y=0.25 width="+width+" height="+height+" interpolation=Bilinear average create");
		rename("CD68");
		close (ImageName);
		run("Bio-Formats Importer", "open=["+subDir+subList[1]+"] color_mode=Default view=Hyperstack stack_order=XYCZT");
		ImageName = getTitle();
		run("Scale...", "x=0.25 y=0.25 width="+width+" height="+height+" interpolation=Bilinear average create");
		rename("CD206");
		close(ImageName);
		run("Bio-Formats Importer", "open=["+subDir+subList[2]+"] color_mode=Default view=Hyperstack stack_order=XYCZT");
		ImageName = getTitle();
		run("Scale...", "x=0.25 y=0.25 width="+width+" height="+height+" interpolation=Bilinear average create");
		rename("DAPI");
		close(ImageName);
		run("Bio-Formats Importer", "open=["+subDir+subList[3]+"] color_mode=Default view=Hyperstack stack_order=XYCZT");
		ImageName = getTitle();
		run("Scale...", "x=0.25 y=0.25 width="+width+" height="+height+" interpolation=Bilinear average create");
		rename("CD11b");
		close(ImageName);
		//Your macro here
		//waitForUser;
		
		//DAPI
		
		selectWindow("DAPI");
		setThreshold(10,255);
		run("Measure");
		Area=getResult("Area",0);
		run("Clear Results");
		getDimensions(width, height, channels, slices, frames);
		run("Subtract Background...", "rolling=20");
		//run("Median...", "radius=3");
		run("Auto Local Threshold", "method=Otsu radius=10 parameter_1=0 parameter_2=0 white");
		//run("Fill Holes");
		run("Watershed");
		run("Analyze Particles...", "size=25-500 circularity=0.30-1.00 clear add");
		CellCount=roiManager("Count");
		CD68List=newArray(CellCount);
		CD11bList=newArray(CellCount);
		CD206List=newArray(CellCount);
		
		//CD68
		selectWindow("CD68");
		run("Subtract Background...", "rolling=20");
		setThreshold(45,255);
		roiManager("Measure");
		for (j=0;j<nResults;j++) {
			data=getResult("%Area",j);
			if (data>10) {
				CD68List[j]=1;
			}
		}
		run("Clear Results");
		
		//CD11b
		selectWindow("CD11b");
		run("Subtract Background...", "rolling=20");
		setThreshold(50,255);
		roiManager("Measure");
		for (j=0;j<nResults;j++) {
			data=getResult("%Area",j);
			if (data>10) {
				CD11bList[j]=1;
			}
		}
		run("Clear Results");

		//CD206
		selectWindow("CD206");
		setThreshold(20,255);
		roiManager("Measure");


		CD68=0;
		CD11b=0;
		CD68CD11b=0;
		CD206=0;
		
		for (j=0;j<nResults;j++) {
			CD68=CD68+CD68List[j];
			CD11b=CD11b+CD11bList[j];
		}

		CD206Count=0;
		for (j=0;j<nResults;j++) {
			if (CD68List[j]==1) {
				data=getResult("Mean",j);
				if (data>0) {
					CD206=CD206+data;
					CD206Count=CD206Count+1;
				}
				if (CD11bList[j]==1) {
					CD68CD11b=CD68CD11b+1;
				}
			}
		}

		CD206=CD206/CD206Count;
		
		

		print(ImageName,"	",Area*1.3*1.3,"	",CellCount,"	",CD68,"	",CD11b,"	",CD68CD11b,"	",CD206);
		//waitForUser;
		run("Close All");
		run("Clear Results");
		roiManager("Reset");
		run("Collect Garbage");		
			
	}
}