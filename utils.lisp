(in-package :cl-stack-utils)

(defun encode-hash (hash)
  (with-output-to-string (*standard-output*)
    (yason:encode hash)))

(defun md5-digest (input)
  (format nil "~{~(~2,'0x~)~}" input))

(defun md5-digest-file (filename)
  (md5-digest (coerce (md5:md5sum-file filename) 'list)))

(defun drill-hash (hash keys)
  (reduce #'(lambda (a b) (gethash b a)) keys :initial-value hash))
