#include "imatrix.h"
#include "ETF.h"
#include "fdog.h"
#include "myvec.h"
#include <string>
#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
using namespace std;

void writePPM(ofstream &out, int nx, int ny, imatrix img)
{
	// Output header
	out << "P6"<< ' ';
	out << nx << ' ' << ny  << ' ' ;
	out << "255\n";

	int i, j;
	unsigned int ired, igreen, iblue;
	unsigned char red, green, blue;

	// Ouput clamped [0, 255] values
	for (i = 0; i <ny; i++)
        {
		for (j = 0; j < nx; ++j)
		{
			ired = (unsigned int)img[i][j];
			igreen = (unsigned int)img[i][j];
			iblue = (unsigned int)img[i][j];

			red = (unsigned char)(ired);
			green = (unsigned char)(igreen);
			blue = (unsigned char)(iblue);
                        
			out.put(red);
			out.put(green);
			out.put(blue);
		}
        }
        out.close();
}

// Reads in a binary PPM
void readPPM(string file_name, imatrix &img)
{
	// Open stream to file
	ifstream in;
	in.open(file_name.c_str(), ios::binary);
	if (!in.is_open())
	{
		cerr << " ERROR -- Couldn't open file \'" << file_name << "\'.\n";
		return;
	}

	char ch, type;
	char red, green, blue;
	int i, j, cols, rows;
	int num;

	// Read in header info
	in.get(ch);
	in.get(type);
	in >> cols >> rows >> num;


	// Allocate raster
	img.init(rows, cols); 
                
	// Clean up newline
	in.get(ch);

	// Store PPM pixel values in raster
	//for (i = rows-1; i >= 0; i--)
        for (i = 0; i <rows ; i++)
		for (j = 0; j < cols; ++j)
		{
			in.get(red);
			in.get(green);
			in.get(blue);
			img[i][j] = (unsigned char)red;

		}
}


 main()
{
        // input image
     for (int i = 1; i <= 10; i++)
     {
        cout << i;
	imatrix img;
        char buff[256];
        sprintf(buff, "/homes/yl303/Documents/MATLAB/synthesis/data/images/face_img/%d.ppm", i);
        string file_name = string(buff);

	readPPM(file_name, img);
        
	// We assume that you have loaded your input image into an imatrix named "img" 
	
	int image_y = img.getRow();
	int image_x = img.getCol();
        
	//////////////////////////////////////////////////

	//////////////////////////////////////////////////
	ETF e;
	e.init(image_y, image_x);
	e.set(img); // get gradients from input image
	//e.set2(img); // get gradients from gradient map
	e.Smooth(4, 2);
	//////////////////////////////////////////////////////

	///////////////////////////////////////////////////
	double tao = 0.985;
	double thres = 0.7;
	GetFDoG(img, e, 1.0, 5.0, tao); 
	GrayThresholding(img, thres); 
	/////////////////////////////////////////////
        
        //output image
        ofstream out;
        
  
        sprintf(buff, "/homes/yl303/Documents/MATLAB/synthesis/data/images/face_img/%d_edge.ppm", i);
        file_name = string(buff);
        out.open(file_name.c_str(), ios::binary);
        writePPM(out, image_x, image_y, img);
        cout<<"done!"<<endl;
     }
}

