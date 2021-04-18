(define-module (luhui os-cfg root)
  #:use-module (gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages tmux)
  #:use-module (gnu packages screen)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages shellutils)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages certs)
  #:use-module (gnu services base)
  #:use-module (gnu services networking)
  #:use-module (gnu services linux))

;; public config
(define-public os-timezone "Hongkong")
(define-public os-locale "en_US.utf8")
(define-public os-kernel linux-libre)
(define-public os-kernel-arguments
  (append
   (list
    "panic=120")
   %default-kernel-arguments))
(define-public os-firmware %base-firmware)
(define-public os-host-name "guix")
(define-public os-issue "Welcome!\n")

(define-public %china-substitute-urls
  (list
   "https://mirrors.sjtug.sjtu.edu.cn/guix"))

(define-public os-services
  (append
   (list)
   (modify-services
       %base-services
     (guix-service-type
      config =>
      (guix-configuration
       (inherit config)
       (substitute-urls
        %china-substitute-urls))))))

(define-public os-packages
  (append
   (list
    ;; 终端复用器
    tmux
    screen
    ;; 编辑器
    vim
    ;; 输入法
    uim
    ;; 环境
    direnv
    ;; 版本管理
    git
    nss-certs)
   %base-packages))

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
    (kernel-arguments os-kernel-arguments)
    (firmware os-firmware)
    (host-name os-host-name)
    (issue os-issue)
    (services os-services)
    (packages os-packages)
    (bootloader os-bootloader)
    (file-systems os-file-systems)))

root:os
