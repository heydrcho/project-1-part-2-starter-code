#include <iostream>
#include <vector>

#include <cuda.h>
#include <vector_types.h>

#include "bitmap_image.hpp"

using namespace std;

__global__ void color_to_grey(uchar3 *input_image, uchar3 *output_image, int width, int height)
{

    // TODO: Convert color to grayscale by mapping components of uchar3 to RGB
    // x -> R; y -> G; z -> B
    // Apply the formula:
    // output = 0.299f * R + 0.578f * G + 0.114f * B
    // Hint: First create a mapping from 2D block and grid locations to an
    // absolute 2D location in the image then use that to calculate a 1D offset
}


int main(int argc, char **argv)
{
    if (argc != 2) {
        cerr << "format: " << argv[0] << " { 24-bit BMP Image Filename }" << endl;
        exit(1);
    }
    
    bitmap_image bmp(argv[1]);

    if(!bmp)
    {
        cerr << "Image not found" << endl;
        exit(1);
    }

    int height = bmp.height();
    int width = bmp.width();
    
    cout << "Image dimensions:" << endl;
    cout << "height: " << height << " width: " << width << endl;

    cout << "Converting " << argv[1] << " from color to grayscale..." << endl;

    //Transform image into vector of doubles
    vector<uchar3> input_image;
    rgb_t color;
    for(int x = 0; x < width; x++)
    {
        for(int y = 0; y < height; y++)
        {
            bmp.get_pixel(x, y, color);
            input_image.push_back( {color.red, color.green, color.blue} );
        }
    }

    vector<uchar3> output_image(input_image.size());

    uchar3 *d_in, *d_out;
    int img_size = (input_image.size() * sizeof(char) * 3);
    cudaMalloc(&d_in, img_size);
    cudaMalloc(&d_out, img_size);

    cudaMemcpy(d_in, input_image.data(), img_size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_out, input_image.data(), img_size, cudaMemcpyHostToDevice);

    // TODO: Fill in the correnct blockSize and gridSize
    // currently only one block with one thread is being launched
    dim3 dimGrid(ceil(1, 1, 1);
    dim3 dimBlock(1, 1, 1);

    color_to_grey<<< dimGrid , dimBlock >>> (d_in, d_out, width, height);
    cudaDeviceSynchronize();

    cudaMemcpy(output_image.data(), d_out, img_size, cudaMemcpyDeviceToHost);
    
    
    //Set updated pixels
    for(int x = 0; x < width; x++)
    {
        for(int y = 0; y < height; y++)
        {
            int pos = x * width + y;
            bmp.set_pixel(x, y, output_image[pos].x, output_image[pos].y, output_image[pos].z);
        }
    }

    cout << "Conversion complete." << endl;
    
    bmp.save_image("./grayscaled.bmp");

    cudaFree(d_in);
    cudaFree(d_out);
}