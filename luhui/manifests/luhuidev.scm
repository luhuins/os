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
  #:use-module (gnu packages mail)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages gdb)
  #:use-module (gnu packages code)
  #:use-module (gnu packages dictionaries)
  #:use-module (luhui pkgs stardict)
  #:use-module (gnu packages ed)
  #:use-module (gnu packages speech)
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
   ed ; editor
   sdcv ; dict
   stardict-ecdict ; dict data
   espeak ; english speech
   ;; doc
   man-db
   man-pages
   texinfo
   sicp
   ;; mail
   mutt
   msmtp
   fdm
   ;; c
   gcc-toolchain
   clang-toolchain
   gdb
   global)
  guile-studio:guix-profile))



(packages->manifest
 guix-profile)
