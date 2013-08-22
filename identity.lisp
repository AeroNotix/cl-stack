(in-package :cl-stack-identity)

(defvar identurl "https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/")

(defclass openstack-client ()
  ((access-token :initarg :access-token :accessor access-token)
   (tenantid :initarg :tenantid :accessor tenantid)
   (expires :initarg :expires :accessor expires)))

(defun make-auth-hash (username password tenantid)
  (let ((auth (make-hash-table :test #'equal))
	(sub-auth (make-hash-table :test #'equal))
	(pass-creds (make-hash-table :test #'equal)))
    (setf (gethash "auth" auth) sub-auth
	  (gethash "passwordCredentials" sub-auth) pass-creds
	  (gethash "tenantId" sub-auth) tenantid
	  (gethash "username" pass-creds) username
	  (gethash "password" pass-creds) password)
    auth))

(defun handle-api-error (code)
  (print code))

(defun make-client-from-response (response)
  (make-instance 'openstack-client
		 :access-token (drill-hash response '("access" "token" "id"))
		 :expires (drill-hash response '("access" "token" "expires"))
		 :tenantid (drill-hash response '("access" "token" "tenant" "id"))))

(defun login (username password tenantid)
  (let* ((auth (make-auth-hash username password tenantid))
	 (resp (multiple-value-list (drakma:http-request (format nil "~atokens" identurl)
							 :method :post
							 :content (encode-hash auth)
							 :content-type "application/json"
							 :additional-headers '(("Accept" . "application/json"))
							 :want-stream T)))
	 (body (nth 0 resp))
	 (status-code (nth 1 resp)))
    (if (= status-code 200)
	(make-client-from-response (yason:parse body))
      (handle-api-error status-code))))
