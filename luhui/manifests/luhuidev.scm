(define-module (luhui manifests luhuidev)
  #:use-module (guix profiles)
  #:use-module (gnu packages)
  #:use-module (gnu packages tmux)
  #:use-module (gnu packages screen)
  #:use-module (gnu packages shellutils)
  #:use-module (gnu packages virtualization)
  #:use-module (gnu packages file)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages man)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages scheme)
  #:use-module ((luhui manifests guile-studio) #:prefix guile-studio:))

(define-public guix-profile
 (append
  (list
   tmux        ; bsd tmux
   screen      ; gnu screen
   direnv      ; environment
   qemu        ; virtual machine
   openssh     ; remote control
   file        ; file format
   ;; doc
   man-db
   man-pages
   texinfo
   sicp)
  guile-studio:guix-profile))



(packages->manifest
 guix-profile)
