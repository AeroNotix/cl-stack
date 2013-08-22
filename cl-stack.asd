(asdf:defsystem #:cl-stack
  :author "Aaron France <aaron.l.france@gmail.com>"
  :description "Bindings to the OpenStack API."
  :components
  ((:file "packages")
   (:file "utils"       :depends-on ("packages"))
   (:file "identity"    :depends-on ("packages" "utils"))
   (:file "objectstore" :depends-on ("packages" "utils" "identity")))
   :depends-on (#:drakma #:yason #:sb-md5))
