# Pipeline code to deal with DARK frames and MOON frames from the MLO project
#
import os
import sys
from shutil import rmtree
import numpy as np
from astropy.io import fits
from astropy.time import Time
import matplotlib.pyplot as plt
import imageio

def coaddslices_intelligently(im):
    if im.ndim < 3:
        return None
    im = np.mean(im, axis=2)
    return im

def go_filter_the_filenames(files, list_):
    for word in list_:
        files = [f for f in files if word not in f]
    return files

def read_fits(file):
    with fits.open(file) as hdul:
        data = hdul[0].data
        header = hdul[0].header
    return data, header

def get_info_from_header(header, key):
    return header.get(key, -999)

def gofind_all_star_fields(path, starname, dark_filter_list):
    print(os.listdir(path))
    files = [f for f in os.listdir(path) if "MOON" in f and f.endswith('.fits')]
    print(files)
    files = go_filter_the_filenames(files, dark_filter_list)
    
    listofDARKnames = []
    listofDARK_JDtimes = []

    with open('STARS.dat', 'w') as f:
        for file in files:
            im, header = read_fits(os.path.join(path, file))
            temp = get_info_from_header(header, 'UNSTTEMP')
            texp = get_info_from_header(header, 'EXPOSURE')
            JD = get_info_from_header(header, 'FRAME')

            if temp != -999 and 10000 < np.max(im) <= 55000:
                listofDARKnames.append(file)
                listofDARK_JDtimes.append(JD)
                f.write(f"{JD:.7f} {temp:.3f} {texp:.4f} {np.max(im):.4f}\n")

    return listofDARKnames, listofDARK_JDtimes

def gofind_all_dark_fields(path, dark_filter_list):
    files = [f for f in os.listdir(path) if "DARK" in f and f.endswith('.fits')]
    files = go_filter_the_filenames(files, dark_filter_list)
    
    listofDARKnames = []
    listofDARK_JDtimes = []

    with open('DARKS.dat', 'w') as f:
        for file in files:
            im, header = read_fits(os.path.join(path, file))
            temp = get_info_from_header(header, 'UNSTTEMP')
            texp = get_info_from_header(header, 'EXPOSURE')
            JD = get_info_from_header(header, 'FRAME')

            if temp == -999:
                listofDARKnames.append(file)
                listofDARK_JDtimes.append(JD)
                f.write(f"{JD:.7f} {temp:.3f} {texp:.4f} {np.mean(im):.4f}\n")

    return listofDARKnames, listofDARK_JDtimes

def go_add_to_the_right_one(im, exp_time2, summdimages, counts, exptimes):
    idx = np.where(exptimes == exp_time2)[0]
    if len(idx) == 0:
        print(f"I am unprepared for {exp_time2}, stopping.")
        return

    idx = idx[0]
    if counts[idx] == 0:
        summdimages[:, :, idx] = im
        counts[idx] = 1
    else:
        summdimages[:, :, idx] += im
        counts[idx] += 1

def get_exposure(header):
    exp_str = header.get('EXPOSURE')
    if exp_str:
        return float(exp_str)
    return 0.0

def get_cycletime(header):
    act_str = header.get('ACT')
    if act_str:
        return float(act_str)
    return 999.0

def get_temperature(header):
    temp_str = header.get('UNSTTEMP')
    if temp_str:
        return float(temp_str)
    return 999.0

def get_measuredexptime(header):
    exp_str = header.get('DMI_ACT_EXP')
    if exp_str:
        return float(exp_str)
    return 999.0

def get_filtername(header):
    filter_str = header.get('DMI_COLOR_FILTER')
    if filter_str:
        return filter_str
    return '999'

def get_time(header):
    frame_str = header.get('FRAME')
    if frame_str:
        yy = int(frame_str[0:4])
        mm = int(frame_str[5:7])
        dd = int(frame_str[8:10])
        hh = int(frame_str[11:13])
        mi = int(frame_str[14:16])
        se = float(frame_str[17:])
        return Time(f"{yy}-{mm}-{dd}T{hh}:{mi}:{se}", format='isot', scale='utc').jd
    return 999.0

def plot_darks_data(file_name, title):
    data = np.loadtxt(file_name)
    JD, temp, expT, mv = data.T

    plt.figure()
    plt.plot(JD - JD[0], mv, 'o')
    plt.xlabel('Fr. day')
    plt.ylabel('DARK field mean value [ADU]')
    plt.title(title)
    plt.savefig('DC_vs_time.png')
    plt.close()

    plt.figure()
    plt.plot(expT, mv, 'o')
    plt.xlabel('Exposure time [s]')
    plt.ylabel('DARK field mean value [ADU]')
    plt.title(title)
    plt.savefig('DARKCURRENT.png')
    plt.close()

def pipeline():
    path = '/media/pth/SSD2/MOONDROPBOX/JD2455854/'
    bias, _ = read_fits('superbias.fits')
    starname = 'MOON'
    
    rmtree('NEW_DARKCURRENTREDUCED/', ignore_errors=True)
    os.makedirs('NEW_DARKCURRENTREDUCED', exist_ok=True)
    os.makedirs('NEW_JPEG', exist_ok=True)
    print('Old output data cleared')

    listofSTARnames, listofSTAR_JDtimes = gofind_all_star_fields(path, starname, ['TAURI', 'DITHER', 'BAD', 'averaged'])
    listofDARKnames, listofDARK_JDtimes = gofind_all_dark_fields(path, ['BAD', 'median'])
    print(listofSTARnames, listofSTAR_JDtimes)
    plot_darks_data('DARKS.dat', 'NIGHT')


    names = []
    names_jpeg = []

    for k, starname in enumerate(listofSTARnames):
        bit1 = starname.replace('.fits', '_DCR.fits')
        bit2 = bit1.split('/245')[-1]
        names.append(f"NEW_DARKCURRENTREDUCED/{bit2}")
        names_jpeg.append(f"NEW_JPEG/{bit2}")
        print(f"a name: {names[-1]}")

    for istar, starname in enumerate(names):
        im, h = read_fits(listofSTARnames[istar])
        print(f"grappling with: {listofSTARnames[istar]}, {istar} of {len(names)}")
        im = coaddslices_intelligently(im)
        ijd = listofSTAR_JDtimes[istar]
        delta_dark = listofDARK_JDtimes - ijd

        JDbefore = max([jd for jd in listofDARK_JDtimes if jd < ijd])
        JDafter = min([jd for jd in listofDARK_JDtimes if jd > ijd])

        idx_1 = listofDARK_JDtimes.index(JDbefore)
        idx_2 = listofDARK_JDtimes.index(JDafter)

        print(idx_1, idx_2)
        print(f"MOON file used: {listofSTARnames[istar]}")
        print(f"Two DARK frames used: {listofDARKnames[idx_1]}, {listofDARKnames[idx_2]}")

        bestDCim = (read_fits(listofDARKnames[idx_1])[0] + read_fits(listofDARKnames[idx_2])[0]) / 2.0
        bestscaledsuperbias = bias / np.mean(bias) * np.mean(bestDCim)
        out = im - bestscaledsuperbias

        fits.writeto('bestDC.fits', bestscaledsuperbias, h, overwrite=True)
        fits.writeto(names[istar], out, h, overwrite=True)

        jpegname = names_jpeg[istar].replace('.fits', '.gif')
        imageio.imwrite(jpegname, out)

if __name__ == "__main__":
    pipeline()

