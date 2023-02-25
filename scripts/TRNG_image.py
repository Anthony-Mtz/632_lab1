# import required libraries
import os
import numpy as np
from PIL import Image as im

def create_image(data_file, outpath):    
    # create a numpy array
    # np.uint8 is a data type containing
    # numbers ranging from 0 to 255 
    # and no non-negative integers
    size = 1000000
    array = np.arange(0, size, 1, np.uint8)


    # image file
    # data_name = 'output_ring_1'
    # data_file = os.path.join('results/', data_name+'.txt')

    data_name = data_file.split('/')[-1].split('.')[0]

    with open(data_file, 'r') as f:
        for i in range(len(array)):
            array[i] = 255 if f.read(1)=='1' else 0

        
    # Reshape the array into a 
    # familiar resoluition --> kept 1000x1000 instead
    array = np.reshape(array, (1000, 1000))
        
    # show the shape of the array
    print(array.shape)

    # show the array
    print(array)
        
    # creating image object of
    # above array
    data = im.fromarray(array)
        
    # saving the final output 
    # as a PNG file
    outfile = os.path.join(outpath, data_name+'.png')
    data.save(outfile)




# Paths
TRNG_data_path = 'TRNG_data/Old'
outpath = 'TRNG_data/Old/pictures'

# Generate all images
for file_name in os.listdir(TRNG_data_path):
    if(file_name.endswith('.txt')):
        datafile = os.path.join(TRNG_data_path, file_name)
        create_image(datafile, outpath)