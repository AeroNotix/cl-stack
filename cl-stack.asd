(asdf:defsystem #:cl-stack-identity
  :author "Aaron France <aaron.l.france@gmail.com>"
  :description "Bindings to the OpenStack API."
  :components
  ((:file "packages")
   (:file "identity"))
  :depends-on (#:drakma #:com.gigamonkeys.json))
