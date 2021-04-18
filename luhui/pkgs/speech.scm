(define-module (luhui pkgs speech)
  #:use-module (gnu packages)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages speech)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages pkg-config)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module (guix utils)
  #:use-module ((guix licenses) #:prefix license:))


(define-public ekho
  (package
    (name "ekho")
    (version "8.4")
    (source
     (origin
       (method url-fetch)
       (uri
        (string-append "mirror://sourceforge/e-guidedog/Ekho/"
                       version "/ekho-" version ".tar.xz"))
       (sha256
        (base32 "1v476kpw09ljj8mavasj4hya2w11jwlx7q22rh1lsn9jkkam5i2a"))))
    (native-inputs
     `(("pkg-config" ,pkg-config)))
    (inputs
     `(("alsa-lib" ,alsa-lib)
       ("espeak-ng" ,espeak-ng)
       ("libsndfile" ,libsndfile)
       ("pulseaudio" ,pulseaudio)))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'configure 'fix-datadir
           (lambda* (#:key outputs #:allow-other-keys)
             (let*
                 ((datadir
                   (string-append
                    (assoc-ref outputs "out") "/share/ekho-data")))
               (substitute* "src/ekho_dict.cpp"
                 (("/usr/local/share/ekho-data")
                  datadir)
                 (("/usr/share/ekho-data")
                  datadir))))))))
    (build-system gnu-build-system)
    (home-page "https://eguidedog.net/ekho.php")
    (synopsis "Chinese text-to-speech software")
    (description
     "Ehko is a Text-To-Speech (TTS) software.  It supports Cantonese,
Mandarin, Toisanese, Zhaoan Hakka, Tibetan, Ngangien and Korean (in trial).
It can also speak English through eSpeak or Festival.")
    (license (list license:gpl2+
                   ;; libmusicxml
                   license:mpl2.0))))
