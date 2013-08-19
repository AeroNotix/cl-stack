(in-package :cl-stack-identity)

(defun login (username password)
  (drakma:http-request "https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/"
		       :method :post
		       :content))
