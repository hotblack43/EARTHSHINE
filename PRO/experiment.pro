; $Id$
PRO experiment_event, ev                                          ; event handler
  widget_control, ev.id, get_uvalue=uvalue                        ; get the uvalue

  CASE uvalue OF                                                  ; choose case
  'go'  : print, 'GO button'                                      ; GO button
  'draw': print, 'draw event', ev.x, ev.y, ev.press, ev.release   ; graphics event
  END
END

PRO experiment
  main = widget_base (title='A401 experiments', /row)             ; main base
  btn = widget_button (main, uvalue='go', value='GO')             ; GO button
  draw = widget_draw (main, uvalue='draw', /button)               ; graphics pane
  widget_control, main, /realize                                  ; create the widgets
  xmanager, 'experiment', main, /no_block                         ; wait for events
END

