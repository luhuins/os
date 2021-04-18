(define-module (luhui pkgs uim)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages libedit)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages autotools))



(define-public uim-console
  (package
   (name "uim-console")
   (version "1.8.8")
   (source
    (origin
     (method url-fetch)
     (uri (string-append "https://github.com/uim/uim/releases/download/"
                         version "/uim-" version ".tar.bz2"))
     (sha256
      (base32
       "1p7sl0js47ja4glmax93ci59h02ipqw3wxkh4f1qgaz5qjy9nn9l"))))
   (build-system gnu-build-system)
   (inputs
    `(("libedit" ,libedit)
      ("m17n-lib" ,m17n-lib)
      ("ncurses" ,ncurses)))
   (native-inputs
    `(("intltool" ,intltool)
      ("emacs" ,emacs-minimal)
      ("pkg-config" ,pkg-config)))
   (arguments
    `(#:modules ((guix build gnu-build-system)
                  (guix build utils)
                  (guix build emacs-utils))
       #:imported-modules (,@%gnu-build-system-modules
                           (guix build emacs-utils))
      #:configure-flags
      (list
       ;; Set proper runpath
       (string-append "LDFLAGS=-Wl,-rpath=" %output "/lib")
       ;; Emacs plugin
       (string-append "--with-lispdir=" %output "/share/emacs"))
      #:phases
      (modify-phases %standard-phases
        ;; Set path of uim-el-agent and uim-el-helper-agent executables
        (add-after 'configure 'configure-uim-el
          (lambda* (#:key outputs #:allow-other-keys)
            (let
                ((out (assoc-ref outputs "out")))
              (emacs-substitute-variables "emacs/uim-var.el"
                ("uim-el-agent" (string-append out "/bin/uim-el-agent"))
                ("uim-el-helper-agent"
                 (string-append out "/bin/uim-el-helper-agent"))))
            #t))
        ;; Fix installation path by renaming share/emacs/uim-el to
        ;; share/emacs/site-lisp
        (add-after 'install 'fix-install-path
          (lambda* (#:key outputs #:allow-other-keys)
            (let ((share-emacs (string-append (assoc-ref outputs "out")
                                              "/share/emacs")))
              (rename-file (string-append share-emacs "/uim-el")
                           (string-append share-emacs "/site-lisp")))
            #t))
        ;; Generate emacs autoloads for uim.el
        (add-after 'fix-install-path 'make-autoloads
          (lambda* (#:key outputs #:allow-other-keys)
            (emacs-generate-autoloads
             ,name (string-append (assoc-ref outputs "out")
                                  "/share/emacs/site-lisp"))
            #t)))))
   (home-page "https://github.com/uim/uim")
   (synopsis "Multilingual input method framework")
   (description "Uim is a multilingual input method library and environment.
It provides a simple, easily extensible and high code-quality input method
development platform, and useful input method environment for users of desktop
and embedded platforms.")
   (license
    (list
     license:lgpl2.1+ ; scm/py.scm, pixmaps/*.{svg,png} (see pixmaps/README)
     license:gpl2+ ; scm/pinyin-big5.scm
     license:gpl3+ ; scm/elatin-rules.cm
     license:public-domain ; scm/input-parse.scm, scm/match.scm
     ;; gtk2/toolbar/eggtrayicon.{ch},
     ;; qt3/chardict/kseparator.{cpp,h},
     ;; qt3/pref/kseparator.{cpp,h}
     license:lgpl2.0+
     ;; pixmaps/*.{svg,png} (see pixmaps/README),
     ;; all other files
     license:bsd-3))))
