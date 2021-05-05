(define-module (luhui manifests luhui)
  #:use-module (guix profiles)
  #:use-module (gnu packages)
  #:use-module (gnu packages tmux)
  #:use-module (gnu packages screen)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages password-utils)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages rsync)
  #:use-module (gnu packages aidc)
  #:use-module (gnu packages shellutils)
  #:use-module (luhui pkgs uim)
  #:use-module (gnu packages ed)
  #:use-module (gnu packages dictionaries)
  #:use-module (luhui pkgs stardict)
  #:use-module ((luhui manifests guile-studio) #:prefix guile-studio:)
  #:use-module ((luhui manifests wayland) #:prefix wayland:))

(define-public guix-profile
 (append
  (list
   tmux        ; bsd tmux
   screen      ; gnu screen
   vim         ; editor
   ncurses     ; clear command
   openssh     ; ssh
   password-store ; password manager
   qrencode    ; qrcode
   gnupg       ; encrypt
   pinentry    ; gnupg
   git         ; version control
   uim-console ; console zh input method
   rsync       ; file sync
   direnv      ; direnv
   mosh        ; use for shanghai.guix.org.cn
   ed          ; editor
   sdcv        ; dict
   stardict-ecdict)  ; dict data
  wayland:guix-profile
  guile-studio:guix-profile))


(packages->manifest
 guix-profile)
