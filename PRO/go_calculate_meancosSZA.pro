set_plot,'ps'
device,filename='/cmsaf/cmsaf-cld3/pthejll/CMSAF_OUTPUTS/meancosszaplots.ps',/landscape
openw,5,'test2.txt'
.r get_lsmask_gridded
.r CM_SAF_include
.r get_one_file
.r calculate_mean_cossza.pro
close,5
device,/close
exit
