(in-package :cl-stack-objectstore)

;; TODO: Have this come from a configuration file to allow for
;; OpenStack vendor agnostic URLs.
(defvar *computeurl* "https://region-b.geo-1.objects.hpcloudsvc.com/v1/")

(defmethod base-headers ((client openstack-client) &optional (additional nil additional-p))
  "Each request has a set of basic headers which are required in each
  and every request we send to the OpenStack vendor.

  These include:
      * X-Auth-Token: An authentication token which we receive after
        logging in.
      * Accept: We always accept application/json"
  (let* ((auth-token (slot-value client 'access-token))
         (req-headers `(("X-Auth-Token" . ,auth-token)
                        ("Accept" . "application/json")))
         (headers (if additional-p
                      (append additional req-headers)
                      req-headers)))
    headers))

(defun base-request (url method &key content headers
		     (status-code 201)
		     (content-type "application/json")
		     (after-request nil))
  (let ((request nil))
    (if content
	(setf request (multiple-value-list
		       (drakma:http-request url :method method
					    :content-type content-type
					    :content content
					    :additional-headers headers)))
	(setf request (multiple-value-list
		       (drakma:http-request url :method method
					    :content-type content-type
					    :additional-headers headers))))
    (if (= (nth 1 request) status-code)
        (if after-request
            (funcall after-request request)
            t)
        (nth 1 request))))

(defmethod upload-file ((client openstack-client) (filename string)
                        &key (container "/testainer") (content-type "application/text") headers)
  "Upload file will upload `filename' into the ObjectStore."
  (let* ((url (format nil "~a~a~a/~a"
                      *computeurl*
                      (slot-value client 'tenantid)
                      container
                      (pathname-name filename)))
         (md5-hash (md5-digest-file filename)))
    (base-request url :PUT
                  :content-type content-type
                  :content (pathname filename)
                  :headers (base-headers client headers)
                  :after-request #'(lambda (request)
                                     (let* ((recvdheaders (nth 2 request))
                                           (etag (cdr (assoc :ETAG recvdheaders))))
                                       (string= etag md5-hash))))))

(defmethod file-operation ((client openstack-client) filename
                           method &key content headers
                                    (status-code 201)
                                    (content-type "application/json")
                                    after-request)
  (let* ((url (concatenate 'string
                            *computeurl*
                            (slot-value client 'tenantid)
                            filename)))
    (base-request url method
                  :status-code status-code
                  :content content
                  :content-type content-type
                  :headers headers
                  :after-request after-request)))

(defmethod retrieve-file ((client openstack-client) (filename string) &key headers)
  (file-operation client filename :GET :status-code 200 :headers (append (base-headers client) headers)
                  :after-request #'(lambda (request)
                                     (nth 0 request))))

(defmethod retrieve-file-metadata ((client openstack-client) (filename string) &key headers)
  (file-operation client filename :HEAD :status-code 200 :headers (append (base-headers client) headers)
                  :after-request #'(lambda (request)
                                     (nth 2 request))))

(defmethod remove-file ((client openstack-client) (filename string))
  "Remove file will remove the `filename' from the ObjectStore."
  (file-operation client filename :DELETE :status-code 204 :headers (base-headers client)))

(defmethod create-directory ((client openstack-client) (directory string) &key headers)
  "Create directory will create the `directory' in the ObjectStore as
  a basic container."
  (let ((headers (base-headers client (append headers '(("Content-Length" . 0))))))
    (file-operation client directory :PUT :content-type "application/directory" :headers headers)))
