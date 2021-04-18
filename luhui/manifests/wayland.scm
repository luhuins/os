(define-module (luhui manifests wayland)
  #:use-module (guix profiles)
  #:use-module (gnu packages)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages image)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages suckless))

(define-public guix-profile
   (list
    hikari       ; wayland wm
    wl-clipboard ; wayland clipboard
    foot               ; terminal emulator
    adwaita-icon-theme ; icon theme
    fontconfig   ; fc-cache command
    font-gnu-unifont ; basic font
    font-terminus    ; terminal font
    grim             ; wayland screenshot
    ))

(packages->manifest
 guix-profile)
