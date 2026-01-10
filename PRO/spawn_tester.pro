; spawn to the OS and run a simple code
PRO spawn_tester
;spawn, 'python3 tester.py'
spawn,/SH, 'python3 tester.py'
;print,'Hejsa det gik godt!'
; print current working directory
;print, 'Current working directory:', !DIR
end
