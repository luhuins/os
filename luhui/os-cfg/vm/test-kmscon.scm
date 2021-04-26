(define-module (luhui os-cfg vm test-kmscon)
  #:use-module (gnu)
  #:use-module (gnu services dbus)
  #:use-module (gnu services base)
  #:use-module (luhui os-cfg vm vm-root))

(define test-kmscon:os-services
  (append
   (list
    (dbus-service)
    (syslog-service)
    ;; default
    (service kmscon-service-type
             (kmscon-configuration
              (virtual-terminal "tty3")))
    ;; us
    (service kmscon-service-type
             (kmscon-configuration
              (virtual-terminal "tty4")
              (keyboard-layout (keyboard-layout "us"))))
    ;; us with ctrl:nocaps options
    (service kmscon-service-type
             (kmscon-configuration
              (virtual-terminal "tty5")
              (keyboard-layout
               (keyboard-layout "us" #:options '("ctrl:nocaps")))))
    ;; us with two options
    (service kmscon-service-type
             (kmscon-configuration
              (virtual-terminal "tty6")
              (keyboard-layout
               (keyboard-layout "us" #:options '("ctrl:nocaps" "compose:menu"))))))
   os-services))


(define-public test-kmscon:os
  (operating-system
    (inherit root:os)
    (services test-kmscon:os-services)))

test-kmscon:os
