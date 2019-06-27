#!/usr/bin/guile -e main -s
!#

(use-modules (dbi dbi))

(define conxion (dbi-open "postgresql" "ln_admin:welcome:lndb:socket:192.168.1.11:5432"))
(define ret #f)
 

(define main
  (lambda (args)
    (list mylist)
   (display mylist)(newline)
    (display "HERE")(newline)
    (display conxion)(newline)
    (dbi-query conxion "select project_sys_name, project_name, descr  from project")
    (display conxion)(newline)
    (set! ret (dbi-get_row conxion))
    (while (not (equal? ret #f))
      (display ret)(newline)
      (set! mylist (append `(,(ret) ,(mylist))))
	   (set! ret (dbi-get_row conxion))
	   )
    (display ret)(newline)
(display mylist)(newline)
))

(main ret)


