data=get_data('slopes.dat')                                     
z1=reform(data(3,*))                                            
delta=reform(data(7,*))                                         
set_plot,'ps'                                                    
plot,z1,delta,xtitle='Z',ytitle='!7D!3(B-V)!dBS-DS!n',charsize=2
oplot,[-3,-3],[!Y.crange],linestyle=2
oplot,[3,3],[!Y.crange],linestyle=2
end
