Basic Recur Support
===================

This very short Emacs Lisp library implements one public form,
`br-with-recur` which provides a very simple, almost pedagogic,
support for self-recursion in such a way as to not blow the stack.

This form works by the application of a trampoline and a locally
scoped function `recur` which returns a tagged object indicating that
recursion is requested.

The strength of this approach is simplicity: `br-with-recur` is a form
which can wrap either a `defun` or a `lambda` and is about 50 lines of
simple code.

The weakness is that nothing prevents the user from calling `recur` in
a non-tail position, and the result of doing so is likely to cause
errors, some of which might conceivably be obscure.

Usage
=====

    (br-with-recur
        (defun br-test (x) (if (< x 10) (recur (+ x 1)) x)))
        
    (br-test 0) -> 10
    
    (funcall (br-with-recur
        (lambda (x) (if (< x 10) (recur (+ x 1)) x))) 0)
        -> 10
        

        

