(define-module (luhui os-cfg installer linux-nonfree)
  #:use-module (gnu)
  #:use-module (luhui pkgs linux-nonfree)
  #:use-module (gnu system install))

(define-public os-kernel linux-nonfree-5.10)
(define-public os-kernel-arguments
  (append (list
           "panic=120")
          (operating-system-user-kernel-arguments installation-os)))
(define-public os-firmware (list linux-firmware-nonfree-20210315))

(define-public linux-nonfree-installer-os
  (operating-system
    (inherit installation-os)
    (kernel os-kernel)
    (kernel-arguments
     os-kernel-arguments)
    (firmware os-firmware)))

linux-nonfree-installer-os
