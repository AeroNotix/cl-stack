(in-package :cl-user)

(defpackage #:cl-stack-identity
  (:use #:cl #:cl-stack-utils)
  (:export #:login))

(defpackage #:cl-stack-utils
  (:use #:cl)
  (:export #:drill-hash #:encode-hash))
