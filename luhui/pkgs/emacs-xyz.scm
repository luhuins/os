(define-module (luhui pkgs emacs-xyz)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages ibus))

(define-public emacs-rime-fix
  (package
    (name "emacs-rime")
    (version "1.0.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/DogLooksGood/emacs-rime")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1a50cziwg7lpgh26yvwxs46jfyfq1m0l6igbg5g5m288mz4d3an9"))))
    (build-system emacs-build-system)
    (arguments
     '(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-rime-module-path
           (lambda* (#:key outputs #:allow-other-keys)
             (make-file-writable "rime.el")
             (emacs-substitute-variables "rime.el"
               ("rime--module-path"
                (string-append (assoc-ref outputs "out") "/lib/librime-emacs.so")))
             #t))
         (add-after 'unpack 'patch-rime-data-path
           (lambda* (#:key inputs #:allow-other-keys)
             (make-file-writable "rime.el")
             (emacs-substitute-variables "rime.el"
               ("rime-share-data-dir"
                (string-append (assoc-ref inputs "rime-data")
                               "/share/rime-data")))
             #t))
         (add-before 'install 'build-emacs-module
           (lambda _
             (invoke "make" "lib")))
         (add-after 'install 'install-emacs-module
           (lambda* (#:key outputs #:allow-other-keys)
             (install-file "librime-emacs.so"
                           (string-append (assoc-ref outputs "out")
                                          "/lib/"))
             #t)))))
    (inputs
     `(("librime" ,librime)
       ("rime-data" ,rime-data)))
    (propagated-inputs
     `(("emacs-dash" ,emacs-dash)
       ("emacs-popup" ,emacs-popup)
       ("emacs-posframe" ,emacs-posframe)))
    (home-page "https://github.com/DogLooksGood/emacs-rime")
    (synopsis "Rime input method in Emacs")
    (description
     "Rime is an Emacs input method built upon Rime input method engine.")
    (license license:gpl3+)))
