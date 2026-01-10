set_plot,'ps'
device,filename='/cmsaf/cmsaf-cld3/pthejll/CMSAF_OUTPUTS/dataproperties_2009Marchproblem.ps',/landscape,/color
openw,5,'test.txt'
.r get_lsmask_gridded
.r CM_SAF_include
.r get_one_file
.r test_probelm2009March.pro
close,5
device,/close
exit
