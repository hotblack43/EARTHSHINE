data=get_data('VE2_rainbow.dat')
data=reform(data(0:1,*))
l=size(data,/dimensions)
xx=findgen(l(1))
data(1,*)=10000.0
data(0,*)=data(0,*)-data(0,0)
;
; Compute the Euclidean distance between each point.
DISTANCE = DISTANCE_MEASURE(data)

; Now compute the cluster analysis.
CLUSTERS = CLUSTER_TREE(distance, linkdistance)

PRINT, 'Item# Item# Distance'
PRINT, [clusters, TRANSPOSE(linkdistance)], $
   FORMAT='(I3, I7, F10.2)'
;
DENDRO_plot, Clusters, Linkdistance
end
