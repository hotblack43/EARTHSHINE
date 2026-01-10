# build_cubes.py
import numpy as np
from astropy.io import fits
import os
from glob import glob

def get_coords_from_header(header):
    def get_value(keyword, default):
        line = next((h for h in header if keyword in h), None)
        if line:
            return float(line[15:24])
        print(f"{keyword} not in header. Assigning dummy value")
        return default

    x0 = get_value('DISCX0', 256.0)
    y0 = get_value('DISCY0', 256.0)
    discra = get_value('DISCRA', 134.32788)
    radius = get_value('RADIUS', 134.32788)
    return x0, y0, radius, discra

def determine_flip2(ideal_in, raw_in, x0, y0):
    raw = raw_in / np.max(raw_in)
    ideal = ideal_in / np.max(ideal_in)
    
    def shift(img):
        return np.roll(np.roll(img, int(x0 - 256), axis=0), int(y0 - 256), axis=1)

    options = [
        shift(ideal_in / np.max(ideal_in)),
        shift(np.flip(ideal_in / np.max(ideal_in), axis=0)),
        shift(np.flip(ideal_in / np.max(ideal_in), axis=1)),
        shift(np.flip(np.flip(ideal_in / np.max(ideal_in), axis=0), axis=1))
    ]
    
    scores = [np.sum(raw * opt) for opt in options]
    idx = int(np.argmax(scores))

    return [int(bool(idx & 1)), int(bool(idx & 2))]  # flip, flop

def do_the_flipflop(image, x0, y0, flip, flop):
    if flip:
        image = np.flip(image, axis=0)
    if flop:
        image = np.flip(image, axis=1)
    return np.roll(np.roll(image, int(x0 - 256), axis=0), int(y0 - 256), axis=1)

def build_cubes():
    with open('JDlist.txt') as f:
        for jdstr in f:
            jdstr = jdstr.strip()
            if jdstr == 'stop':
                break

            im_files = glob(f"/home/pth/DARKCURRENTREDUCED/SELECTED_4b/{jdstr}*")
            print(im_files)
            if not im_files:
                continue

            obs, header = fits.getdata(im_files[0], header=True)
            x0, y0, radius, discra = get_coords_from_header(header)

            ideal_file = f'OUTPUT/IDEAL/ideal_LunarImg_SCA_0p310_JD_{jdstr}.fit'
            if not os.path.exists(ideal_file):
                continue

            ideal = fits.getdata(ideal_file)
            lonlat = fits.getdata(f'/home/pth/WORKSHOP/EARTHSHINE_CODE/OUTPUT/IDEAL/lonlatSELimage_JD{jdstr}.fits')
            inout = fits.getdata(f'/home/pth/WORKSHOP/EARTHSHINE_CODE/OUTPUT/IDEAL/Angles_JD{jdstr}.fits')

            lonim, latim = lonlat[..., 0], lonlat[..., 1]
            inangle, outangle, obsangle = inout[..., 0], inout[..., 1], inout[..., 2]

            flip, flop = determine_flip2(ideal, obs, x0, y0)

            blank = np.zeros_like(obs)
            cube = np.stack([
                obs,
                blank,
                blank,
                blank,
                do_the_flipflop(ideal, x0, y0, flip, flop),
                do_the_flipflop(lonim, x0, y0, flip, flop),
                do_the_flipflop(latim, x0, y0, flip, flop),
                do_the_flipflop(inangle, x0, y0, flip, flop),
                do_the_flipflop(outangle, x0, y0, flip, flop),
                do_the_flipflop(obsangle, x0, y0, flip, flop)
            ])

            fits.writeto(f'CUBES/cube_MkV_JD{jdstr}.fits', cube, header, overwrite=True)

if __name__ == '__main__':
    build_cubes()

