(define-module (luhui manifests luhuiweb)
  #:use-module (guix profiles)
  #:use-module (gnu packages)
  #:use-module (gnu packages tmux)
  #:use-module (gnu packages screen)
  #:use-module (gnu packages gnuzilla)
  #:use-module (gnu packages chromium)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages w3m)
  #:use-module (gnu packages web-browsers)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages ed)
  #:use-module (gnu packages dictionaries)
  #:use-module (luhui pkgs stardict)
  #:use-module ((luhui manifests wayland) #:prefix wayland:)
  #:use-module ((luhui manifests guile-studio) #:prefix guile-studio:))

(define-public guix-profile
 (append
  (list
   tmux        ; bsd tmux
   screen      ; gnu screen
   icecat      ; icecat
   ungoogled-chromium/wayland  ; ungoogled-chromium
   ed                   ; editor
   sdcv                 ; dict
   stardict-ecdict)     ; dict data
  wayland:guix-profile
  (list
   curl
   w3m
   lynx
   links
   emacs-w3m)
  guile-studio:guix-profile))



(packages->manifest
 guix-profile)
