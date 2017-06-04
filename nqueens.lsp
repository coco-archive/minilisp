;;;
;;; N-QUEENS PUZZLE SOLVER.
;;;
;;; THE N QUEENS PUZZLE IS THE PROBLEM OF PLACING N CHESS QUEENS ON AN N X N
;;; CHESSBOARD SO THAT NO TWO QUEENS ATTACK EACH
;;; OTHER. HTTP://EN.WIKIPEDIA.ORG/WIKI/EIGHT_QUEENS_PUZZLE
;;;
;;; THIS PROGRAM SOLVES N-QUEENS PUZZLE BY DEPTH-FIRST BACKTRACKING.
;;;

;;;
;;; BASIC MACROS
;;;
;;; BECAUSE THE LANGUAGE DOES NOT HAVE QUASIQUOTE, WE NEED TO CONSTRUCT AN
;;; EXPANDED FORM USING CONS AND LIST.
;;;

;; (PROGN EXPR ...)
;; => ((LAMBDA () EXPR ...))
(DEFMACRO PROGN (EXPR . REST)
  (LIST (CONS 'LAMBDA (CONS () (CONS EXPR REST)))))

(DEFUN LIST (X . Y)
  (CONS X Y))

(DEFUN NOT (X)
  (IF X () T))

;; (LET1 VAR VAL BODY ...)
;; => ((LAMBDA (VAR) BODY ...) VAL)
(DEFMACRO LET1 (VAR VAL . BODY)
  (CONS (CONS 'LAMBDA (CONS (LIST VAR) BODY))
	(LIST VAL)))

;; (AND E1 E2 ...)
;; => (IF E1 (AND E2 ...))
;; (AND E1)
;; => E1
(DEFMACRO AND (EXPR . REST)
  (IF REST
      (LIST 'IF EXPR (CONS 'AND REST))
    EXPR))

;; (OR E1 E2 ...)
;; => (LET1 <TMP> E1
;;      (IF <TMP> <TMP> (OR E2 ...)))
;; (OR E1)
;; => E1
;;
;; THE REASON TO USE THE TEMPORARY VARIABLES IS TO AVOID EVALUATING THE
;; ARGUMENTS MORE THAN ONCE.
(DEFMACRO OR (EXPR . REST)
  (IF REST
      (LET1 VAR (GENSYM)
	    (LIST 'LET1 VAR EXPR
		  (LIST 'IF VAR VAR (CONS 'OR REST))))
    EXPR))

;; (WHEN EXPR BODY ...)
;; => (IF EXPR (PROGN BODY ...))
(DEFMACRO WHEN (EXPR . BODY)
  (CONS 'IF (CONS EXPR (LIST (CONS 'PROGN BODY)))))

;; (UNLESS EXPR BODY ...)
;; => (IF EXPR () BODY ...)
(DEFMACRO UNLESS (EXPR . BODY)
  (CONS 'IF (CONS EXPR (CONS () BODY))))

;;;
;;; NUMERIC OPERATORS
;;;

(DEFUN <= (E1 E2)
  (OR (< E1 E2)
      (= E1 E2)))

;;;
;;; LIST OPERATORS
;;;

;; APPLIES EACH ELEMENT OF LIS TO PRED. IF PRED RETURNS A TRUE VALUE, TERMINATE
;; THE EVALUATION AND RETURNS PRED'S RETURN VALUE. IF ALL OF THEM RETURN (),
;; RETURNS ().
(DEFUN ANY (LIS PRED)
  (WHEN LIS
    (OR (PRED (CAR LIS))
	(ANY (CDR LIS) PRED))))

;;; APPLIES EACH ELEMENT OF LIS TO FN, AND RETURNS THEIR RETURN VALUES AS A LIST.
(DEFUN MAP (LIS FN)
  (WHEN LIS
    (CONS (FN (CAR LIS))
	  (MAP (CDR LIS) FN))))

;; RETURNS NTH ELEMENT OF LIS.
(DEFUN NTH (LIS N)
  (IF (= N 0)
      (CAR LIS)
    (NTH (CDR LIS) (- N 1))))

;; RETURNS THE NTH TAIL OF LIS.
(DEFUN NTH-TAIL (LIS N)
  (IF (= N 0)
      LIS
    (NTH-TAIL (CDR LIS) (- N 1))))

;; RETURNS A LIST CONSISTS OF M .. N-1 INTEGERS.
(DEFUN %IOTA (M N)
  (UNLESS (<= N M)
    (CONS M (%IOTA (+ M 1) N))))

;; RETURNS A LIST CONSISTS OF 0 ... N-1 INTEGERS.
(DEFUN IOTA (N)
  (%IOTA 0 N))

;; RETURNS A NEW LIST WHOSE LENGTH IS LEN AND ALL MEMBERS ARE INIT.
(DEFUN MAKE-LIST (LEN INIT)
  (UNLESS (= LEN 0)
    (CONS INIT (MAKE-LIST (- LEN 1) INIT))))

;; APPLIES FN TO EACH ELEMENT OF LIS.
(DEFUN FOR-EACH (LIS FN)
  (OR (NOT LIS)
      (PROGN (FN (CAR LIS))
	     (FOR-EACH (CDR LIS) FN))))

;;;
;;; N-QUEENS SOLVER
;;;

;; CREATES SIZE X SIZE LIST FILLED WITH SYMBOL "X".
(DEFUN MAKE-BOARD (SIZE)
  (MAP (IOTA SIZE)
       (LAMBDA (_)
	 (MAKE-LIST SIZE 'X))))

;; RETURNS LOCATION (X, Y)'S ELEMENT.
(DEFUN GET (BOARD X Y)
  (NTH (NTH BOARD X) Y))

;; SET SYMBOL "@" TO LOCATION (X, Y).
(DEFUN SET (BOARD X Y)
  (SETCAR (NTH-TAIL (NTH BOARD X) Y) '@))

;; SET SYMBOL "X" TO LOCATION (X, Y).
(DEFUN CLEAR (BOARD X Y)
  (SETCAR (NTH-TAIL (NTH BOARD X) Y) 'X))

;; RETURNS TRUE IF LOCATION (X, Y)'S VALUE IS "@".
(DEFUN SET? (BOARD X Y)
  (EQ (GET BOARD X Y) '@))

;; PRINT OUT THE GIVEN BOARD.
(DEFUN PRINT (BOARD)
  (IF (NOT BOARD)
      '$
    (PRINTLN (CAR BOARD))
    (PRINT (CDR BOARD))))

;; RETURNS TRUE IF WE CANNOT PLACE A QUEEN AT POSITION (X, Y), ASSUMING THAT
;; QUEENS HAVE ALREADY BEEN PLACED ON EACH ROW FROM 0 TO X-1.
(DEFUN CONFLICT? (BOARD X Y)
  (ANY (IOTA X)
       (LAMBDA (N)
	 (OR
	  ;; CHECK IF THERE'S NO CONFLICTING QUEEN UPWARD
	  (SET? BOARD N Y)
	  ;; UPPER LEFT
	  (LET1 Z (+ Y (- N X))
		(AND (<= 0 Z)
		     (SET? BOARD N Z)))
	  ;; UPPER RIGHT
	  (LET1 Z (+ Y (- X N))
		(AND (< Z BOARD-SIZE)
		     (SET? BOARD N Z)))))))

;; FIND POSITIONS WHERE WE CAN PLACE QUEENS AT ROW X, AND CONTINUE SEARCHING FOR
;; THE NEXT ROW.
(DEFUN %SOLVE (BOARD X)
  (IF (= X BOARD-SIZE)
      ;; PROBLEM SOLVED
      (PROGN (PRINT BOARD)
	     (PRINTLN '$))
    (FOR-EACH (IOTA BOARD-SIZE)
	      (LAMBDA (Y)
		(UNLESS (CONFLICT? BOARD X Y)
		  (SET BOARD X Y)
		  (%SOLVE BOARD (+ X 1))
		  (CLEAR BOARD X Y))))))

(DEFUN SOLVE (BOARD)
  (PRINTLN 'START)
  (%SOLVE BOARD 0)
  (PRINTLN 'DONE))

;;;
;;; MAIN
;;;

(DEFINE BOARD-SIZE 4)
(DEFINE BOARD (MAKE-BOARD BOARD-SIZE))
(SOLVE BOARD)
