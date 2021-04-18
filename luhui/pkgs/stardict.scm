(define-module (luhui pkgs stardict)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages compression)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (guix utils))




(define-public stardict-ecdict
  (package
    (name "stardict-ecdict")
    (version "1.0.28")
    (source (origin
              (method url-fetch)
              (uri
               (string-append
                "https://github.com/skywind3000/ECDICT/releases/download/"
                version
                "/ecdict-stardict-28.zip"))
            (sha256
             (base32
              "0b3gijq9qzyrp87i575gllyp0x70fhalmnk6cjwpkv6nvvrx01y7"))))
    (build-system gnu-build-system)
    (native-inputs
     `(("unzip" ,unzip)))
    (arguments
     `(#:tests? #f ; no tests
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (delete 'build)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((destdir
                    (string-append
                     (assoc-ref outputs "out")
                     "/share/stardict/dic/" "ecdict")))
               (mkdir-p destdir)
               (copy-recursively
                "./" destdir)))))))
    (home-page "https://github.com/skywind3000/ECDICT")
    (synopsis "Free Stardict English to Chinese Dictionary data")
    (description "Big Stardict data use to English to Chinese")
    (license license:expat)))
