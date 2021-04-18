(define-module (luhui manifests guile-studio)
  #:use-module (guix profiles)
  #:use-module (gnu packages)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages man)
  #:use-module (gnu packages scheme)
  #:use-module (gnu packages base))

(define-public guix-profile
   (list
    emacs-next-pgtk
    emacs-rime
    emacs-magit git
    emacs-paredit
    guile-3.0 guix 
    texinfo))

(packages->manifest
 guix-profile)
