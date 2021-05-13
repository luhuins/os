(define-module (luhui pkgs web)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages pcre)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages web)
  #:use-module (gnu packages javascript)
  #:use-module (gnu packages pkg-config))

(define-public edbrowse
  (let ((commit "09508a0f3d9b87f8aa8dec612671527c81a6122d")
        (revision "0"))
    (package
      (name "edbrowse")
      (version "3.8.0")
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/CMB/edbrowse")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "15a12la56z3m552m9c5wqfwws59cqgx87sn8vq6bkfr621076z35"))))
      (build-system gnu-build-system)
      (arguments
       `(#:make-flags
         (list (string-append "CC=" ,(cc-for-target))
               (string-append "PREFIX=" (assoc-ref %outputs "out")))
         #:tests? #f
         #:phases
         (modify-phases %standard-phases
           (delete 'configure)
           (add-before 'build 'patch-replace-harcode-path
             (lambda* (#:key inputs #:allow-other-keys)
               (let* ((perl
                       (string-append
                        (assoc-ref inputs "perl") "/bin/perl")))
                 (substitute* "tools/buildebrcstring.pl"
                   (("/usr/bin/perl") perl)))
               #t))
           (add-before 'build 'fix-quickjs-libdir
             (lambda* (#:key inputs #:allow-other-keys)
               (let* ((libdir-quickjs
                       (string-append
                        (assoc-ref inputs "quickjs") "/lib/quickjs")))
                 (substitute* "src/makefile"
                   (("-L/usr/local/lib/quickjs")
                    (string-append
                     "-L" libdir-quickjs)))
                 #t)))
           (replace 'install
             (lambda* (#:key outputs #:allow-other-keys)
               (let* ((out (assoc-ref outputs "out")))
                 (mkdir-p (string-append out "/bin/"))
                 (install-file "src/edbrowse"
                               (string-append out "/bin/"))))))))
      (inputs
       `(("readline" ,readline)
         ("pcre" ,pcre)
         ("curl" ,curl)
         ("tidy-html" ,tidy-html)
         ("quickjs" ,quickjs)))
      (native-inputs
       `(("perl" ,perl)
         ("pkg-config" ,pkg-config)))
      (home-page "https://github.com/CMB/edbrowse")
      (synopsis "Line oriented editor browser")
      (description "Ed-like web browser with javascript support")
      (license license:gpl3+))))
