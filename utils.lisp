(in-package :cl-stack-utils)

(ql:quickload :yason)

(defun encode-hash (hash)
  (with-output-to-string (*standard-output*)
    (yason:encode hash)))

(defun drill-hash (hash keys)
  (reduce #'(lambda (a b) (gethash b a)) keys :initial-value hash))
