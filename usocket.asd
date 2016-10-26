;;;; -*- Mode: Lisp -*-
;;;;
;;;; See the LICENSE file for licensing information.

(in-package :asdf)

;;; NOTE: the key "art" here is, no need to recompile any file when switching
;;; between a native backend and IOlib backend. -- Chun Tian (binghe)

#+sample
(pushnew :usocket-iolib *features*)

(defsystem #:usocket
    :name "usocket (client)"
    :author "Erik Enge & Erik Huelsmann"
    :maintainer "Chun Tian (binghe) & Hans Huebner"
    :version "0.8.0-dev"
    :licence "MIT"
    :description "Universal socket library for Common Lisp"
    :depends-on (:split-sequence
                 #+(and (or sbcl ecl) (not usocket-iolib)) :sb-bsd-sockets
                 #+usocket-iolib :iolib)
    :components ((:file "package")
		 (:module "vendor" :depends-on ("package")
		  :components (#+mcl (:file "kqueue")
			       #+mcl (:file "OpenTransportUDP")))
		 (:file "usocket" :depends-on ("vendor"))
		 (:file "condition" :depends-on ("usocket"))
                 #-usocket-iolib
		 (:module "backend" :depends-on ("condition")
		  :components (#+abcl		(:file "abcl")
			       #+(or allegro cormanlisp)
						(:file "allegro")
			       #+clisp		(:file "clisp")
			       #+(or openmcl clozure)
                                                (:file "openmcl")
			       #+clozure	(:file "clozure" :depends-on ("openmcl"))
			       #+cmu		(:file "cmucl")
			       #+(or sbcl ecl)	(:file "sbcl")
			       #+ecl		(:file "ecl" :depends-on ("sbcl"))
			       #+lispworks	(:file "lispworks")
			       #+mcl		(:file "mcl")
			       #+mocl		(:file "mocl")
			       #+scl		(:file "scl")
                               #+usocket-iolib  (:file "iolib")))
                 #-usocket-iolib
                 (:file "option" :depends-on ("backend"))
                 #+usocket-iolib
		 (:module "backend" :depends-on ("condition")
                  :components ((:file "iolib" :depends-on ("iolib-sockopt"))
                               (:file "iolib-sockopt")))
		 ))

(defmethod perform ((op test-op) (c (eql (find-system :usocket))))
  (oos 'load-op :usocket-server)
  (oos 'load-op :usocket-test)
  (oos 'test-op :usocket-test))
