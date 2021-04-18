(define-module (luhui manifests luhuiweb)
  #:use-module (guix profiles)
  #:use-module (gnu packages)
  #:use-module (gnu packages tmux)
  #:use-module (gnu packages screen)
  #:use-module (gnu packages gnuzilla)
  #:use-module (gnu packages chromium)
  #:use-module ((luhui manifests wayland) #:prefix wayland:))

(define-public guix-profile
 (append
  (list
   tmux        ; bsd tmux
   screen      ; gnu screen
   icecat      ; icecat
   ungoogled-chromium/wayland) ; ungoogled-chromium
  wayland:guix-profile))



(packages->manifest
 guix-profile)
