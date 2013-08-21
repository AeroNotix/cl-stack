(in-package :cl-user)

(defpackage #:cl-stack-utils
  (:use #:cl)
  (:export #:drill-hash
           #:encode-hash
           #:md5-digest
           #:md5-digest-file))

(defpackage #:cl-stack-identity
  (:use #:cl #:cl-stack-utils)
  (:export #:login
           #:openstack-client
           #:tenantid
           #:access-token))

(defpackage #:cl-stack-objectstore
  (:use #:cl
        #:cl-stack-utils
        #:cl-stack-identity)
  (:export #:upload-file))
