; *******************
; ** funcion menor **
; *******************

(defun min_value 
    ; parametros y descripcion
    (arr) "funcion que devuelve el valor menor de un array" 
    ; definir variable menor = arr[0]
    (setq menor (car arr))
    ; iterar lista 
    (dolist (i arr)
        ; if ( i < menor ) then
        (if (< i menor)
            ; menor = i
            (setq menor i)
        )
    )
    ;The return value of the function is the value returned by the last executed form of the body.
    menor
)

; *******************
; ** funcion mayor **
; *******************

(defun max_value 
    (arr) "funcion que devuelve el valor mayor de un array" 
    (setq max (car arr))
    (dolist (i arr)
        (if (> i max)
            (setq max i)
        )
    )
    max
)

; **********************
; ** funcion promedio **
; **********************

(defun prom
    (arr) "funcion que devuelve el promedio de un array" 
    (setq sum 0)
    (setq cant 0)
    (dolist (i arr)
        (setq sum (+ sum i))
        (setq cant (+ cant 1))
    )
    (setq prom (/ sum cant))
)


;crear lista numerica
(setf v1 
    (list 8 5 2 7 3 9 1 4 6 ))

(print "Sea el array")
(write v1)

(print "Sin funciones nativas:")

; ejecutar funciones 
(setq result (max_value v1))
(print "El mayor es:")
(write result)

(setq result (min_value v1))
(print "El menor es:")
(write result)

(setq result (prom v1))
(print "El promedio de elementos es:")
(write result)

(print "Con funciones nativas:")

(setq result (apply 'max v1))
(print "El mayor es:")
(write result)

(setq result (apply 'min v1))
(print "El menor es:")
(write result)

(setq result (prom v1))
(print "El mayor es:")
(write result)

