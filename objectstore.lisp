(in-package :cl-stack-objectstore)

(ql:quickload :drakma)
(ql:quickload :yason)
(ql:quickload :sb-md5)

(defvar computeurl "https://region-b.geo-1.objects.hpcloudsvc.com:443/v1/")

(defmethod upload-file ((client openstack-client) (filename string)
                        &key path content-type headers)
  (let ((md5hash (md5-digest-file filename))
        (url (format nil "~a~a/~a" computeurl (slot-value client 'tenantid) filename)))
    (print (list url path content-type headers md5hash))))
