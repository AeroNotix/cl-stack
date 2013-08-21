(in-package :cl-stack-objectstore)

(ql:quickload :drakma)
(ql:quickload :yason)
(ql:quickload :sb-md5)

(defvar computeurl "https://region-b.geo-1.objects.hpcloudsvc.com/v1.0/")

(defmethod upload-file ((client openstack-client) (filename string)
                        &key (container "/") (content-type "application/text") headers)
  (let* ((md5hash (md5-digest-file filename))
         (url (format nil "~a~a~a/~a"
                      computeurl
                      (slot-value client 'tenantid)
                      container
                      (pathname-name filename)))
         (auth-token (slot-value client 'access-token))
         (req-headers `(("X-Auth-Token" ,auth-token) ("ETag" ,md5hash)))
         (headers (append headers req-headers)))
    (drakma:http-request url :method :POST
                             :content-type content-type
                             :content (pathname filename)
                             :additional-headers headers)))
