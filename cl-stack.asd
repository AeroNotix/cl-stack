(asdf:defsystem #:cl-stack
  :author "Aaron France <aaron.l.france@gmail.com>"
  :description "Bindings to the OpenStack API."
  :components
  ((:file "packages")
   (:file "identity"))
  :depends-on (#:drakma #:yason))
