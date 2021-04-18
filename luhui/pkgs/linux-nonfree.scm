(define-module (luhui pkgs linux-nonfree)
  #:use-module (gnu packages)
  #:use-module (gnu packages linux)
  #:use-module (guix build-system copy)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix utils))

(define-public linux-nonfree-5.10
  (package
    (inherit linux-libre)
    (name "linux-nonfree")
    (version "5.10.27")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kernel.org"
                           "/linux/kernel/v" (version-major version) ".x/"
                           "linux-" version ".tar.xz"))
       (sha256
        (base32 "1nb95ll66kxiz702gs903n3gy5ialz8cin58l19rqaai55kck7fr"))))
    (home-page "https://www.kernel.org/")
    (synopsis "Linux kernel")
    (description "The Linux kernel.")))

(define-public linux-firmware-nonfree-20210315
  (package
    (name "linux-firmware-nonfree")
    (version "20210315")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kernel.org"
                           "/linux/kernel/firmware/"
                           "linux-firmware-" version ".tar.xz"))
       (sha256
        (base32 "0w2y2pkqrcgqzjysgimywlzfdxaqdrn4j0pjmslxq4r7941qyd52"))))
    (build-system copy-build-system)
    (arguments
     `(#:install-plan '(("./" "lib/firmware/"))
       #:phases (modify-phases %standard-phases
                  (delete 'strip)
                  (delete 'validate-runpath))))
    (home-page "https://kernel.org/")
    (synopsis "Non-free Linux firmware")
    (description "Non-free firmware blobs for Linux kernel.")
    (license #f)))
