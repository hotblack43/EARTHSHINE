set_plot,'ps'
device,xsize=18,ysize=24.5,yoffset=2
device,filename='/cmsaf/cmsaf-cld3/pthejll/CMSAF_OUTPUTS/TRSoverTIS_vs_combined_SALcorr_CFC_Model1or2_LANDonly.ps',/color,decomposed=0
openw,5,'test9.txt'
.r CM_SAF_include	; compile the special CMSAF utilities
.r example_includes.pro	; compile the subroutines example9.pro needs
.r example9
close,5
device,/close
exit
