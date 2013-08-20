(in-package :cl-stack-identity)

(ql:quickload :drakma)
(ql:quickload :yason)

(defvar identurl "https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/")

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

(defun login (username password tenantid)
  (let ((auth (make-auth-hash username password tenantid)))
    (drakma:http-request (format nil "~atokens" identurl)
                         :method :post
                         :content (encode-hash auth)
                         :content-type "application/json"
                         :additional-headers '(("Accept" . "application/json")))))
