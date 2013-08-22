(in-package :cl-stack-objectstore)

(ql:quickload :drakma)
(ql:quickload :yason)
(ql:quickload :sb-md5)

(defvar computeurl "https://region-b.geo-1.objects.hpcloudsvc.com/v1/")

(defmethod base-headers ((client openstack-client) &optional (additional nil additional-p))
  (let* ((auth-token (slot-value client 'access-token))
         (req-headers `(("X-Auth-Token" . ,auth-token)))
         (headers (if additional-p
                      (append additional req-headers)
                      req-headers)))
    headers))

(defmethod upload-file ((client openstack-client) (filename string)
                        &key (container "/testainer") (content-type "application/text") headers)
  (let* ((url (format nil "~a~a~a/~a"
                      computeurl
                      (slot-value client 'tenantid)
                      container
                      (pathname-name filename)))
         (md5-hash (md5-digest-file filename))
         (headers (base-headers client headers))
         (request (multiple-value-list
                   (drakma:http-request url :method :PUT
                                            :content-type content-type
                                            :content (pathname filename)
                                            :additional-headers headers)))
         (recvdheaders (nth 2 request))
         (status-code (nth 1 request))
         (etag (cdr (assoc :ETAG recvdheaders))))
    (if (= status-code 201)
        (string= etag md5-hash)
        status-code)))

(defmethod remove-file ((client openstack-client) (filename string))
  (let* ((url (format nil "~a~a~a"
                      computeurl
                      (slot-value client 'tenantid)
                      filename))
         (request (multiple-value-list
                   (drakma:http-request url :method :DELETE
                                            :additional-headers (base-headers client))))
         (status-code (nth 1 request)))
    (if (= status-code 204) T status-code)))

(defmethod create-directory ((client openstack-client) (directory string) &key headers)
  (let* ((url (format nil "~a~a~a"
                      computeurl
                      (slot-value client 'tenantid)
                      directory))
         (headers (base-headers client (append headers '(("Content-Length" . 0)))))
         (request (multiple-value-list
                   (drakma:http-request url :method :PUT
                                            :content-type "application/directory"
                                            :additional-headers headers)))
         (status-code (nth 1 request)))
    (if (= status-code 201) T status-code)))
