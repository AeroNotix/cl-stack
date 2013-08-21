(in-package :cl-stack-objectstore)

(ql:quickload :drakma)
(ql:quickload :yason)
(ql:quickload :sb-md5)

(defvar computeurl "https://region-b.geo-1.objects.hpcloudsvc.com/v1/")

(defmethod upload-file ((client openstack-client) (filename string)
                        &key (container "/testainer") (content-type "application/text") headers)
  (let* ((url (format nil "~a~a~a/~a"
                      computeurl
                      (slot-value client 'tenantid)
                      container
                      (pathname-name filename)))
         (auth-token (slot-value client 'access-token))
         (req-headers `(("X-Auth-Token" . ,auth-token)))
         (headers (append headers req-headers)))
    ;; TODO: this returns (or should return, you never know with
    ;; OpenStack) the MD5 of the file in an ETag header, we should
    ;; compare that here.
    (drakma:http-request url :method :POST
                             :content-type content-type
                             :content (pathname filename)
                             :additional-headers headers)))
