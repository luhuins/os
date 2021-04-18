(define-module (luhui os-cfg vm vm-root)
  #:use-module (gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages busybox)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages certs)
  #:use-module (gnu services base)
  #:use-module (gnu services networking)
  #:use-module (gnu services linux)
  #:use-module (gnu services sysctl))

;; public config
(define-public os-timezone "UTC")
(define-public os-locale "en_US.utf8")
(define-public os-kernel linux-libre)
(define-public os-firmware (list)) ; 虚拟机不需要固件
(define-public os-host-name "guix-vm")

(define-public os-services
  (list
   (service virtual-terminal-service-type)
   (service login-service-type)
   (service agetty-service-type (agetty-configuration
                                 (extra-options '("-L")) ; no carrier detect
                                 (term "vt100")
                                 (tty #f))) ; automatic
   (service mingetty-service-type (mingetty-configuration
                                   (tty "tty1")))
   (service mingetty-service-type (mingetty-configuration
                                   (tty "tty2")))
   (service static-networking-service-type
            (list (static-networking (interface "lo")
                                     (ip "127.0.0.1")
                                     (requirement '())
                                     (provision '(loopback)))))
   (service dhcp-client-service-type)
   (service urandom-seed-service-type)
   (service udev-service-type)
   (service sysctl-service-type)
   (service special-files-service-type
            `(("/bin/sh" ,(file-append bash "/bin/sh"))
              ("/usr/bin/env" ,(file-append coreutils "/bin/env"))))))

(define-public os-packages
  (list
   busybox ; 基础命令基础工具集合
   kmod    ; 加载卸载内核模块
   nss-certs)) ; TLS 证书

;; dummy bootloder config
(define os-bootloader
  (bootloader-configuration
   (bootloader grub-bootloader)
   (target "nodev")
   (terminal-outputs '(console))))

;; dummy file-systems config
(define-public os-file-systems
  (cons (file-system
         (mount-point "/")
         (device "nodev")
         (type "none"))
        %base-file-systems))

(define-public root:os
  (operating-system
    (timezone os-timezone)
    (locale os-locale)
    (kernel os-kernel)
    (host-name os-host-name)
    (file-systems os-file-systems)
    (bootloader os-bootloader)
    (services os-services)
    (packages os-packages)))

root:os
