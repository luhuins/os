(define-module (luhui pkgs phone)
  #:use-module (gnu packages)
  #:use-module (gnu packages video)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages sdl)
  #:use-module (guix packages)
  #:use-module (guix build-system meson)
  #:use-module (guix git-download)
  #:use-module (guix download)
  #:use-module (guix utils)
  #:use-module ((guix licenses) #:prefix license:))

(define-public scrcpy
  ;; No tagged version upstream.
  (let ((commit "f682b87ba5ed6a5126cc23dff905218b177a2436")
        (revision "0"))
    (package
      (name "scrcpy")
      (version "1.17")
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/Genymobile/scrcpy")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "168y4zyv6ln2j68s4jb9xpjfjb3mjiw39iga4ldyvgacd1nynb64"))))
      (build-system meson-build-system)
      (inputs
       `(("ffmpeg" ,ffmpeg)
         ("sdl2" ,sdl2)
         ("prebuilt-server"
          ,(origin
             (method url-fetch)
             (uri (string-append
                   "https://github.com/Genymobile/scrcpy/releases/download/v"
                   version
                   "/scrcpy-server-v"
                   version))
             (file-name (string-append  "scrcpy-server-v" version ".jar"))
             (sha256
              (base32
               "09b73cx6a6x28y74dzrq35mz93qsszpphji5nw7p7ff93cnsvd8i"))))))
      (native-inputs
       `(("pkg-config" ,pkg-config)))
      (arguments
       `(#:configure-flags
         (list (string-append "-Doverride_server_path="
                              (assoc-ref %build-inputs "prebuilt-server"))
               (string-append "-Dprebuilt_server="
                              (assoc-ref %build-inputs "prebuilt-server")))))
      (home-page "https://github.com/Genymobile/scrcpy")
      (synopsis #f)
      (description #f)
      (license #f))))
