import os
from shutil import rmtree
import numpy as np
from astropy.io import fits
from astropy.time import Time
import matplotlib.pyplot as plt
import imageio
import sys  # Importing the sys module

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
    files = [f for f in os.listdir(path) if "MOON" in f and f.endswith('.fit')]
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
    files = [f for f in os.listdir(path) if "DARK" in f and f.endswith('.fit')]
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
        sys.exit(1)  # Use sys.exit() to stop execution

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

def pipeline(darks_path, moon_path):
    bias, _ = read_fits('../TTAURI/superbias.fits')
    starname = 'MOON'
    
    rmtree('DARKCURRENTREDUCED/', ignore_errors=True)
    os.makedirs('DARKCURRENTREDUCED', exist_ok=True)
    os.makedirs('JPEG', exist_ok=True)
    print('Old output data cleared')

    listofSTARnames, listofSTAR_JDtimes = gofind_all_star_fields(moon_path, starname, ['TAURI', 'DITHER', 'BAD', 'averaged'])
    listofDARKnames, listofDARK_JDtimes = gofind_all_dark_fields(darks_path, ['BAD', 'median'])
    
    plot_darks_data('DARKS.dat', 'NIGHT')

    names = []
    names_jpeg = []
    for k in range(len(listofSTARnames)):
        bit1 = listofSTARnames[k].split('/')[-1].split('.fit')[0] + '_DCR.fits'
        bit2 = bit1.split('/245')[0] + bit1.split('/245')[1]
        names.append(os.path.join('DARKCURRENTREDUCED/', bit2))
        names_jpeg.append(os.path.join('JPEG/', bit2))
        print('a name:', names[k])

    summdimages = np.zeros((1, 1, len(listofDARKnames)))
    counts = np.zeros(len(listofDARKnames))
    exptimes = np.array([get_exposure(read_fits(file)[1]) for file in listofDARKnames])

    for istar, name in enumerate(listofSTARnames):
        im, header = read_fits(name)
        print('grappling with:', name, istar, 'of', len(names))
        coaddslices_intelligently(im)
        ijd = listofSTAR_JDtimes[istar]
        delta_dark = listofDARK_JDtimes - ijd
        JDbefore = max(listofDARK_JDtimes[np.where(delta_dark < 0)])
        JDafter = min(listofDARK_JDtimes[np.where(delta_dark > 0)])
        idx_1 = np.where(listofDARK_JDtimes == JDbefore)[0][0]
        idx_2 = np.where(listofDARK_JDtimes == JDafter)[0][0]
        print(idx_1, idx_2)
        print('MOON file used:', name)
        print('Two DARK frames used:', listofDARKnames[idx_1], listofDARKnames[idx_2])
        bestDCim = (read_fits(listofDARKnames[idx_1])[0] + read_fits(listofDARKnames[idx_2])[0]) / 2.0
        bestscaledsuperbias = bias / np.mean(bias) * np.mean(bestDCim)
        out = im - bestscaledsuperbias
        write_fits(names[istar], out, header)

        jpegname = names_jpeg[istar].split('.')[0] + '.gif'
        imageio.imwrite(jpegname, np.uint8(out))

