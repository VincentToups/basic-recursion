;; Basic Tail Recursion
;; This package contains the `br-with-recur` macro
;;
;; We use it by wrapping either a `defun` or `lambda` and the result is a
;; function which may call `recur` in tail position to recur to the entry point
;; without growing the stack

(defmacro br-lambda-with-recur (lambda-expression)
  (if (or (not (listp lambda-expression))
          (not (eq 'lambda (car lambda-expression))))
      (error "br-lambda-with-recur expects a lambda expression."))
  (let ((res (gensym "recur-result-"))
        (args (gensym "recur-args-"))
        (f (gensym "recur-f-"))
        (recur-tag (gensym "recur-recur-tag-")))
    `#'(lambda (&rest ,args)
       (flet ((recur (&rest args)
                     (cons ',recur-tag args)))
         (let* ((,f ,lambda-expression)
               (,res (apply ,f ,args)))
           (loop while (and (listp ,res) (eq ',recur-tag (car ,res)))
                 do
                 (setq ,res (apply ,f (cdr ,res))))
           ,res)))))

(defmacro br-defun-with-recur (defun-expression)
  (if (or (not (listp defun-expression))
          (not (eq 'defun (car defun-expression)))
          (not (symbolp (cadr defun-expression))))
      (error "br-defun-with-recur expects a defun form."))
  (let* ((fun-name (cadr defun-expression))
         (arg-list (elt defun-expression 2))
         (body (subseq defun-expression 3)))
    `(setf (symbol-function ',fun-name)
           (br-lambda-with-recur (lambda ,arg-list ,@body)))))

(defmacro br-with-recur (form)
  (if (not (listp form)) (error "br-with-recur expects form to be either a defun or a lambda form."))
  (case (car form)
    ((defun) `(br-defun-with-recur ,form))
    ((lambda) `(br-lambda-with-recur ,form))))

(defmacro br-code-comment (&rest body)
  nil)

(br-code-comment
 (br-with-recur
  (defun br-test (x) (if (< x 10) (recur (+ x 1)) x)))
 (funcall (br-with-recur
           (lambda (x) (if (< x 10) (recur (+ x 1)) x))) 0))

