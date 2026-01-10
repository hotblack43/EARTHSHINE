;########################################################################################
;
;	This is version 1.0 of the Widget GUI definition for the IDL Object Genetic Algorithm
;
; Last update on: 15/3/2002
;
; Allard de Wit
; Centre for Geo-information
; P.O. Box 47
; 6700 AA Wageningen
; The Netherlands
;
; Email: a.j.w.dewit@alterra.wag-ur.nl
; Tel: +31-317-474761
; Fax: +31-317-419000
;
;#######################################################################################
;
; This piece of code defines the GA Interface. It has not been written using object-
; oriented programming techniques, but it is plain IDL code. Note: If you want to see
; the code properly, change the tab settings to 2 positions.
;
;#######################################################################################

pro restore_settings, ev

; Restores settings from a previously saved GA session

	widget_control, ev.top, get_uvalue=tmp

	infile=dialog_pickfile(filter="*.sav",/read)
	if infile NE "" then begin
		r=file_test(infile)
		if r eq 1 then begin
			restore, filename=infile
			ptr_free, tmp[0], tmp[1]
			tmp[0]=ptr_new(gasettings)
			tmp[1]=ptr_new(gasettings)
			widget_control, ev.top, set_uvalue=tmp
		endif
	endif

end

;==============================================================================

pro save_settings, ev

; Saves current GA settings to a IDL .sav file

	widget_control, ev.top, get_uvalue=tmp
	gasettings=*(tmp[0])
	outfile=dialog_pickfile(filter="*.sav",/write)
	if outfile NE "" then begin
		r=file_test(outfile)
		if r eq 1 then begin
			chk=dialog_message("File exists! overwrite?", /question,/default_no)
			if chk eq "Yes" then save, gasettings, filename=outfile
		endif else begin
			save, gasettings, filename=outfile
		endelse
	endif

end

;==============================================================================
pro restore_defaults, ev

; Restores default settings if the file 'ga_defaults.sav' exists

	widget_control, ev.top, get_uvalue=tmp
	log_id=*(tmp[4])
	r=file_test('ga_defaults.sav')
	if r eq 1 then begin
		restore, filename='ga_defaults.sav'
		widget_control, log_id, set_value="Defaults restored from 'ga_defaults.sav'", /append
	endif else begin
	gasettings={ $
		maxgen:50, $
		nselect:2, $
		pop_size:10, $
		p_creep:0.05, $
		p_mutate:0.05, $
		p_crossover:0.5, $
		npar:2, $
		parmin:[0.0,0.0], $
		parmax:[1.0,1.0], $
		parbits:[15,15], $
		seed:0, $
		microga:1, $
		outfile:'ga.out'}
		widget_control, log_id, set_value="Defaults restored"
	endelse
	ptr_free, tmp[0], tmp[1]
	tmp[0]=ptr_new(gasettings)
	tmp[1]=ptr_new(gasettings)
	widget_control, ev.top, set_uvalue=tmp

end

;==============================================================================

pro save_defaults, ev

; Saves the current settings as GA defaults, which are loaded when the GA is
; started using the GUI interface.

	widget_control, ev.top, get_uvalue=tmp
	gasettings=*(tmp[0])
	log_id=*(tmp[4])
	save, gasettings, filename='ga_defaults.sav'
	widget_control, log_id, set_value="Defaults saved to 'ga_defaults.sav'", /append

end

;==============================================================================

function get_defaults

; This function is only called when the GUI is started to restore the default
; GA settings

	r=file_test('ga_defaults.sav')
	if r eq 1 then begin
		restore, filename='ga_defaults.sav'
	endif else begin
	gasettings={ $
		maxgen:50, $
		nselect:2, $
		pop_size:10, $
		p_creep:0.05, $
		p_mutate:0.05, $
		p_crossover:0.5, $
		npar:2, $
		parmin:[0.0,0.0], $
		parmax:[1.0,1.0], $
		parbits:[15,15], $
		seed:0, $
		microga:1, $
		outfile:'ga.out'}
	endelse

	return, gasettings

end

;==============================================================================

pro finish_wizard, ev

; This procedure is called at the end of the GA settings wizard to effectuate
; the new GA settings

	widget_control, ev.top, get_uvalue=tmp
	wbase=*(tmp[2])
	gasettings=*(tmp[1])
	ptr_free, tmp[0]
	tmp[0]=ptr_new(gasettings)
	widget_control, wbase, set_uvalue=tmp
	widget_control, ev.top, /destroy

end

;==============================================================================

pro button_ev, ev

; Sets MicroGA mode on/off

	widget_control, ev.id, get_uvalue=mga
	widget_control, ev.top, get_uvalue=tmp
	gasettings=*(tmp[1])

	case mga of
		'mga_on'	: gasettings.microga=1
		'mga_off'	:	gasettings.microga=0
	endcase

	ptr_free, tmp[1]
	tmp[1]=ptr_new(gasettings)
	widget_control, ev.top, set_uvalue=tmp

end

;===============================================================================

pro get_wtext, ev

; Handles the user input data from a variety of text and table widgets

	widget_control, ev.id, get_uvalue=select
	widget_control, ev.id, get_value=wvalue
	widget_control, ev.top, get_uvalue=tmp
	gasettings=*(tmp[1])
	case select[0] of
	'npar'	    : begin
									wvalue=strtrim(wvalue,1)
									wvalue_byte=byte(wvalue)
									str=''
									len=strlen(wvalue)-1
									for i=0, len[0] do begin
										char=byte(wvalue_byte[i])
										if (char ge 48) and (char le 57) then str=str+string(char)
									endfor
									if (long(str) NE gasettings.npar) then begin
										if (long(str) GT 10) then str='10'
										widget_control, ev.id, set_value=str, set_text_select=[i,0]
										gasettings.npar=fix(str)
									endif
								end
	'table'			: begin
									for i=0,gasettings.npar-1 do begin
											gasettings.parmin[i]=wvalue[0,i]
											gasettings.parmax[i]=wvalue[1,i]
											gasettings.parbits[i]=wvalue[2,i]
									endfor
								end
	'maxgen'		:	begin
									wvalue=strtrim(wvalue,1)
									wvalue_byte=byte(wvalue)
									str=''
									len=strlen(wvalue)-1
									for i=0, len[0] do begin
										char=byte(wvalue_byte[i])
										if (char ge 48) and (char le 57) then str=str+string(char)
									endfor
									if (long(str) NE gasettings.maxgen) then begin
										widget_control, ev.id, set_value=str, set_text_select=[i,0]
										gasettings.maxgen=fix(str)
									endif

								end
	'nselect'		:	begin
									wvalue=strtrim(wvalue,1)
									wvalue_byte=byte(wvalue)
									str=''
									len=strlen(wvalue)-1
									for i=0, len[0] do begin
										char=byte(wvalue_byte[i])
										if (char ge 48) and (char le 57) then str=str+string(char)
									endfor
									if (long(str) NE gasettings.nselect) then begin
										widget_control, ev.id, set_value=str, set_text_select=[i,0]
										gasettings.nselect=fix(str)
									endif
								end
	'pop_size'	:	begin
									wvalue=strtrim(wvalue,1)
									wvalue_byte=byte(wvalue)
									str=''
									len=strlen(wvalue)-1
									for i=0, len[0] do begin
										char=byte(wvalue_byte[i])
										if (char ge 48) and (char le 57) then str=str+string(char)
									endfor
									if (long(str) NE gasettings.pop_size) then begin
										widget_control, ev.id, set_value=str, set_text_select=[i,0]
										gasettings.pop_size=fix(str)
									endif
								end
	'seed'			:	begin
									wvalue=strtrim(wvalue,1)
									wvalue_byte=byte(wvalue)
									str=''
									len=strlen(wvalue)-1
									for i=0, len[0] do begin
										char=byte(wvalue_byte[i])
										if (char ge 48) and (char le 57) then str=str+string(char)
									endfor
									if (long(str) NE gasettings.seed) then begin
										widget_control, ev.id, set_value=str, set_text_select=[i,0]
										gasettings.seed=fix(str)
									endif
								end
	'outfile'		:	begin
									wvalue=strtrim(wvalue,1)
										widget_control, ev.id, set_value=wvalue, set_text_select=[strlen(wvalue),0]
										gasettings.outfile=wvalue
								end
	'p_mutate'	:	begin
									wvalue=strtrim(wvalue,1)
									wvalue_byte=byte(wvalue)
									str=''
									len=strlen(wvalue)-1
									for i=0, len[0] do begin
										char=byte(wvalue_byte[i])
										if ((char ge 48) and (char le 57)) or (char eq 46) $
											then str=str+string(char)
									endfor
									if (float(str) NE gasettings.p_mutate) then begin
										widget_control, ev.id, set_value=str, set_text_select=[i,0]
										gasettings.p_mutate=float(str)
									endif
								end
	'p_creep'		:	begin
									wvalue=strtrim(wvalue,1)
									wvalue_byte=byte(wvalue)
									str=''
									len=strlen(wvalue)-1
									for i=0, len[0] do begin
										char=byte(wvalue_byte[i])
										if ((char ge 48) and (char le 57)) or (char eq 46) $
											then str=str+string(char)
									endfor
									if (float(str) NE gasettings.p_creep) then begin
										widget_control, ev.id, set_value=str, set_text_select=[i,0]
										gasettings.p_creep=float(str)
									endif
								end
	'p_crossover' :	begin
										wvalue=strtrim(wvalue,1)
										wvalue_byte=byte(wvalue)
										str=''
										len=strlen(wvalue)-1
										for i=0, len[0] do begin
											char=byte(wvalue_byte[i])
											if ((char ge 48) and (char le 57)) or (char eq 46) $
												then str=str+string(char)
										endfor
										if (float(str) NE gasettings.p_crossover) then begin
											widget_control, ev.id, set_value=str, set_text_select=[i,0]
											gasettings.p_crossover=float(str)
										endif
									end

	endcase
;	print, gasettings
	ptr_free, tmp[1]
	tmp[1]=ptr_new(gasettings)
	widget_control, ev.top, set_uvalue=tmp

end

;======================================================================================

pro set_ga_npar_back, ev

; Handles the first wizard window, which asks for the nr of parameters that are
; to be optimised. The difference between this pro and the next is that this pro
; is called when the user presses the 'back' button in the wizard. It therefore
; destroys the top-level widget before it creates its own widget.

	widget_control, ev.top, get_uvalue=tmp
	widget_control, ev.top, /destroy

	gasettings=*(tmp[1])
	wizardbase=widget_base(title='Set nr. of GA parameters',/column)
	parambase=widget_base(wizardbase, /row)
	backnextbase=widget_base(wizardbase, /row)

	l1=widget_label(parambase, value='Nr of GA parameters: ')
	t1=widget_text(parambase, value=string(gasettings.npar),/all_events, /editable, $
		event_pro='get_wtext', uvalue='npar')
	cancel=widget_button(backnextbase, value='Cancel', event_pro='killwizard')
	next=widget_button(backnextbase, value='Next >>', event_pro='set_ga_chromsettings')

	widget_control, wizardbase, /realize
	widget_control, wizardbase, set_uvalue=tmp

end

;======================================================================================

pro set_ga_npar, ev

; Handles the first wizard window, which asks for the nr of parameters that are
; to be optimised.

	widget_control, ev.top, get_uvalue=tmp

	gasettings=*(tmp[1])
	wizardbase=widget_base(title='Set nr. of GA parameters',/column)
	parambase=widget_base(wizardbase, /row)
	backnextbase=widget_base(wizardbase, /row)

	l1=widget_label(parambase, value='Nr of GA parameters: ')
	t1=widget_text(parambase, value=string(gasettings.npar),/all_events, /editable, $
		event_pro='get_wtext', uvalue='npar')
	cancel=widget_button(backnextbase, value='Cancel', event_pro='killwizard')
	next=widget_button(backnextbase, value='Next >>', event_pro='set_ga_chromsettings')

	widget_control, wizardbase, /realize
	widget_control, wizardbase, set_uvalue=tmp

end
;======================================================================================

pro set_ga_chromsettings, ev

; Handles the Wizard window where the GA parameter ranges can be typed into a
; table widget.

	widget_control, ev.top, get_uvalue=tmp
	widget_control, ev.top, /destroy

	gasettings=*(tmp[1])
	npar=gasettings.npar
	if (npar eq 0) then npar=1
	tablevalues=fltarr(3,npar)
	if (npar eq n_elements(gasettings.parmin)) then begin
		tablevalues[0,*]=gasettings.parmin
		tablevalues[1,*]=gasettings.parmax
		tablevalues[2,*]=gasettings.parbits
	endif

	gasettings_copy={ $
		maxgen:gasettings.maxgen, $
		nselect:gasettings.nselect, $
		pop_size:gasettings.pop_size, $
		p_creep:gasettings.p_creep, $
		p_mutate:gasettings.p_mutate, $
		p_crossover:gasettings.p_crossover, $
		npar:gasettings.npar, $
		parmin:tablevalues[0,*], $
		parmax:tablevalues[1,*], $
		parbits:tablevalues[2,*], $
		seed:gasettings.seed, $
		microga:gasettings.microga, $
		outfile:gasettings.outfile}
	ptr_free, tmp[1]
	tmp[1]=ptr_new(gasettings_copy)


	columnlabels=['Min value','Max value','Nr of bits']
	stra=strarr(npar) + ' Parameter '
	strb=strtrim(string(indgen(npar)), 1)
	rowlabels=stra+strb+' '

	wizardbase=widget_base(title='Set optimisation range and nr. of bits', /column)
	tablebase=widget_base(wizardbase,/row)
	backnextbase=widget_base(wizardbase, /row)

	table=widget_table(tablebase, xsize=3, ysize=npar, column_labels=columnlabels, $
		row_labels=rowlabels, /all_events, /editable, value=tablevalues, uvalue='table',$
		event_pro='get_wtext')

	back=widget_button(backnextbase, value='<< Back', event_pro='set_ga_npar_back')
	cancel=widget_button(backnextbase, value='Cancel', event_pro='killwizard')
	next=widget_button(backnextbase, value='Next >>', event_pro='set_ga_misc')

	widget_control, wizardbase, /realize
	widget_control, wizardbase, set_uvalue=tmp


end

;======================================================================================
pro set_ga_misc, ev

; Set other GA options

	widget_control, ev.top, get_uvalue=tmp
	widget_control, ev.top, /destroy
	toplevel=*(tmp[1])

	wizardbase=widget_base(title='Set GA parameters and options', /column)
	miscbase=widget_base(wizardbase,/column,/grid_layout,/base_align_right)
	backnextbase=widget_base(wizardbase, /row)

	b1=widget_base(miscbase, /row,/base_align_left)
	b2=widget_base(miscbase, /row)
	b3=widget_base(miscbase, /row)
	b4=widget_base(miscbase, /row)
	b5=widget_base(miscbase, /row)
	b6=widget_base(miscbase, /row)
	b7=widget_base(miscbase, /row)
	b8=widget_base(miscbase, /row)
	b9=widget_base(miscbase, /row)


	l1=widget_label(b1, value='Maxgen :')
	l2=widget_label(b2, value='Nselect :')
	l3=widget_label(b3, value='Pop_size :')
	l4=widget_label(b4, value='P_creep :')
	l5=widget_label(b5, value='P_mutate :')
	l6=widget_label(b6, value='P_crossover :')
	l7=widget_label(b7, value='Random seed :')
	l8=widget_label(b8, value='Output file :')
	l9=widget_label(b9, value='Micro GA :')

	t1=widget_text(b1, value=string(toplevel.maxgen),/all_events, /editable, $
		event_pro='get_wtext', uvalue='maxgen', /align_right)
	t2=widget_text(b2, value=string(toplevel.nselect),/all_events, /editable, $
		event_pro='get_wtext', uvalue='nselect',/align_right)
	t3=widget_text(b3, value=string(toplevel.pop_size),/all_events, /editable, $
		event_pro='get_wtext', uvalue='pop_size',/align_right)
	t4=widget_text(b4, value=string(toplevel.p_creep),/all_events, /editable, $
		event_pro='get_wtext', uvalue='p_creep',/align_right)
	t5=widget_text(b5, value=string(toplevel.p_mutate),/all_events, /editable, $
		event_pro='get_wtext', uvalue='p_mutate',/align_right)
	t6=widget_text(b6, value=string(toplevel.p_crossover),/all_events, /editable, $
		event_pro='get_wtext', uvalue='p_crossover',/align_right)
	t7=widget_text(b7, value=string(toplevel.seed),/all_events, /editable, $
		event_pro='get_wtext', uvalue='seed',/align_right)
	t8=widget_text(b8, value=string(toplevel.outfile),/all_events, /editable, $
		event_pro='get_wtext', uvalue='outfile',/align_right)

	radiob_base=widget_base(b9, /row,/exclusive,xsize=123)
	microga_on=widget_button(radiob_base, value='on',/no_release, $
		event_pro='button_ev', uvalue='mga_on')
	microga_off=widget_button(radiob_base, value='off',/no_release, $
		event_pro='button_ev', uvalue='mga_off')


	back=widget_button(backnextbase, value='<< Back', event_pro='set_ga_chromsettings')
	cancel=widget_button(backnextbase, value='Cancel', event_pro='killwizard')
	next=widget_button(backnextbase, value='Finish >>', event_pro='finish_wizard')


	widget_control, wizardbase, /realize
	if toplevel.microga eq 0 then widget_control, microga_off, set_button=1 $
		else widget_control, microga_on, set_button=1
	widget_control, wizardbase, set_uvalue=tmp

end
;======================================================================================

pro start_ga, ev

;Run the IDL Genetic Algorithm

;Get info from toplevel widget
	widget_control, ev.top, get_uvalue=tmp
	gasettings=*(tmp[0])
	draw_id=*(tmp[3])
	log_id=*(tmp[4])

;Copy GA settings to variables
	maxgen=gasettings.maxgen
	nselect=gasettings.nselect
	pop_size=gasettings.pop_size
	p_creep=gasettings.p_creep
	p_mutate=gasettings.p_mutate
	p_crossover=gasettings.p_crossover
	npar=gasettings.npar
	parmin=gasettings.parmin
	parmax=gasettings.parmax
	parbits=gasettings.parbits
	seed=gasettings.seed
	microga=gasettings.microga
	outfile=gasettings.outfile

	avgfit_ar=dblarr(maxgen)
	maxfit_ar=dblarr(maxgen)

;Initialise GA Population
	pop1=obj_new('population',nselect=nselect, pop_size=pop_size, p_creep=p_creep, $
	    p_mutate=p_mutate, p_crossover=p_crossover, npar=npar, parmin=parmin, $
			parmax=parmax, parbits=parbits, seed=seed, microga=microga, outfile=outfile)
	r=obj_valid(pop1)

;Define Pixmap buffer
	window, 1, /pixmap, xsize=400, ysize=300

;Start generation loop
	if (r eq 1) then begin
		for gen=1, maxgen do begin
			pop1->new_generation, params=params, avgfitness=avgfitness, $
	    	maxfitness=maxfitness, gen=gen
			avgfit_ar[gen-1]=avgfitness
	  	maxfit_ar[gen-1]=maxfitness
	  	wset, 1
			plot, maxfit_ar[0:gen-1], psym=-1, xrange=[0,maxgen], $
				xtitle='# Generations', ytitle='Fitness', symsize=0.8, font=0
			oplot, avgfit_ar[0:gen-1], psym=-6, symsize=0.8
			wset, draw_id
			device, copy=[0,0,400,300,0,0,1]
		endfor

		parstring=""
		for i=0,n_elements(params)-1 do parstring=parstring+strtrim(params[i],2)+", "
		str= "Best solution: "+ parstring+" with fitness: "+ strtrim(maxfit_ar[maxgen-1],2)
		widget_control, log_id, set_value=str, /append
		str="GA output written to file: "+outfile
		widget_control, log_id, set_value=str, /append

		obj_destroy, pop1
	endif else begin
		str="Population failed to initialise, see console for details!"
		widget_control, log_id, set_value=str, /append
	endelse

end

;======================================================================================

pro quit, ev

; Quits the Widget interface

	widget_control, ev.top, get_uvalue=tmp
	ptr_free, tmp
	widget_control, ev.top, /destroy

end

;======================================================================================

pro killwizard, ev

; Kills the GA wizard, all changes are lost.

	widget_control, ev.top, get_uvalue=tmp
	wbase=*(tmp[2])
	original_toplevel=*(tmp[0])
	ptr_free, tmp[1]
	tmp[1]=ptr_new(original_toplevel)
	widget_control, wbase, set_uvalue=tmp
	widget_control, ev.top, /destroy

end

;======================================================================================

pro idlga

; Start routine for widget interface

;Define top base and child bases
	wbase=widget_base(title='IDL Object Genetic Algorithm',/column)
	defbase=widget_base(wbase,/column, frame=2)
	lab1=widget_base(defbase,/row,/align_left)
	but1=widget_base(defbase,/row,/grid_layout)
	setbase=widget_base(wbase,/column, frame=2)
	lab2=widget_base(setbase,/row,/align_left)
	but3=widget_base(setbase,/row,/grid_layout)
	drawbase=widget_base(wbase,/row)
	startbase=widget_base(wbase,/column, frame=2)
	lab3=widget_base(startbase,/row,/align_left)
	but2=widget_base(startbase,/row, frame=2)
	log=widget_text(wbase,/scroll, font='6x10',ysize=5)

;Define buttons and labels for change, save and restore
	label_set=widget_label(lab1, value='Current GA Settings:')
	button_set=widget_button(but1, value='Change', event_pro='set_ga_npar')
	button_save=widget_button(but1, value='Save', event_pro='save_settings')
	button_restore=widget_button(but1, value='Restore', event_pro='restore_settings')

;Define buttons for saving and restoring default settings
	label_set=widget_label(lab2, value='Default GA Settings:')
	button_defsave=widget_button(but3, value='Save defaults', event_pro='save_defaults')
	button_defrestore=widget_button(but3, value='Restore defaults', event_pro='restore_defaults')

;Define draw widget
	draw_gahist=widget_draw(drawbase, xsize=400, ysize=300, retain=2)

;Define buttons for start, stop, pause and quit
	label_run=widget_label(lab3, value='Execute GA options:')
	button_start=widget_button(but2, value='Start GA', event_pro='start_ga')
	button_stop=widget_button(but2, value='Stop GA', event_pro='')
	button_pause=widget_button(but2, value='Pause GA', event_pro='')
	button_quit=widget_button(but2, value='Quit GA', event_pro='quit')
	widget_control,wbase, /realize

;Get window value of draw widget
	widget_control,draw_gahist, get_value=draw_id

;restore default settings from 'ga_defaults.sav' (if exists)
	gasettings=get_defaults()

;Assign various settings to ptr_array that will be stored in the toplevel widget
	toplevel=ptrarr(5)
	toplevel[0]=ptr_new(gasettings)
	toplevel[1]=ptr_new(gasettings)
	toplevel[2]=ptr_new(wbase)
	toplevel[3]=ptr_new(draw_id)
	toplevel[4]=ptr_new(log)

;Assign toplevel widget and start xmanager
	widget_control, wbase, set_uvalue=toplevel
	xmanager, 'IDL Object Genetic Algorithm', wbase


end
