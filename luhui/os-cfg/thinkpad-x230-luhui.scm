(define-module (luhui os-cfg thinkpad-x230-luhui)
  #:use-module (gnu)
  #:use-module (guix modules)
  #:use-module (gnu packages)
  #:use-module (gnu packages screen)
  #:use-module (gnu packages tmux)
  #:use-module (gnu packages vpn)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages cryptsetup)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages radio)
  #:use-module (gnu packages glib)
  #:use-module (gnu services ssh)
  #:use-module (gnu services networking)
  #:use-module (gnu services linux)
  #:use-module (gnu services virtualization)
  #:use-module (gnu services dbus)
  #:use-module (gnu services desktop)
  #:use-module (gnu services xorg)
  #:use-module (gnu services avahi)
  #:use-module (gnu services mcron)
  #:use-module (gnu services sound)
  #:use-module (gnu services pm)
  #:use-module (gnu services dns)
  #:use-module (gnu services base)
  #:use-module (luhui services notebook)
  #:use-module (luhui pkgs linux-nonfree)
  #:use-module (gnu system nss)
  #:use-module (luhui os-cfg root))


(define %battery-low-job
  #~(job
     '(next-minute (range 0 60 1))
     #$(program-file
        "battery-low.scm"
        (with-imported-modules (source-module-closure
                                '((guix build utils)))
          #~(begin
              (use-modules (guix build utils)
                           (ice-9 popen)
                           (ice-9 regex)
                           (ice-9 textual-ports)
                           (srfi srfi-2))

              ;; Shutdown when the battery percentage falls below %MIN-LEVEL.

              (define %min-level 10)
              (setenv "LC_ALL" "C")     ;ensure English output
              (and-let* ((input-pipe (open-pipe*
                                      OPEN_READ
                                      #$(file-append acpi "/bin/acpi")))
                         (output (get-string-all input-pipe))
                         (m (string-match "Discharging, ([0-9]+)%" output))
                         (level (string->number (match:substring m 1)))
                         ((< level %min-level)))
                (format #t "warning: Battery level is low (~a%)~%" level)
                (invoke #$(file-append shepherd "/sbin/shutdown")))

              ;; sleep when the battery percentage falls below %SLEEP-LEVEL.
              (define %sleep-level 20)

              (setenv "LC_ALL" "C")     ;ensure English output
              (and-let* ((input-pipe (open-pipe*
                                      OPEN_READ
                                      #$(file-append acpi "/bin/acpi")))
                         (output (get-string-all input-pipe))
                         (m (string-match "Discharging, ([0-9]+)%" output))
                         (level (string->number (match:substring m 1)))
                         ((< level %sleep-level)))
                (format #t "warning: Battery level is low (~a%)~%" level)
                (call-with-output-file "/sys/power/state"
                  (lambda (port)
                    (format port "mem")))))))))

(define-public thinkpad-x230-luhui:os-host-name "thinkpad-x230-luhui")
(define-public thinkpad-x230-luhui:os-services
  (append
   (list
    (service openntpd-service-type
             (openntpd-configuration
              (constraint-from (list "www.gnu.org"))))
    (service earlyoom-service-type)
    (service openssh-service-type
             (openssh-configuration
              (port-number 222)
              (password-authentication? #f)))
    (service nftables-service-type
             (nftables-configuration
              (ruleset "/etc/nftables.rule")))
    (service zram-device-service-type
             (zram-device-configuration
              (size "4G")
              (compression-algorithm 'zstd)
              (memory-limit "6G")
              (priority 100)))
    (dbus-service)
    (elogind-service)
    (service network-manager-service-type
             (network-manager-configuration
              (dns "none")))
    (service wpa-supplicant-service-type)
    (bluetooth-service #:auto-enable? #t)
    (screen-locker-service hikari "hikari-unlocker")
    (screen-locker-service kbd "vlock")
    (service qemu-binfmt-service-type
             (qemu-binfmt-configuration
              (platforms
               (lookup-qemu-platforms
                "arm" "aarch64"
                "mips" "mips64"
                "riscv"))))
    (service guix-publish-service-type
             (guix-publish-configuration
              (host "0.0.0.0")
              (port 8090)
              (compression '(("zstd" 3)))
              (workers 4)
              (advertise? #t)))
    (service avahi-service-type
             (avahi-configuration
              (wide-area? #t)))
    (simple-service 'battery-cron-jobs
                    mcron-service-type
                    (list %battery-low-job))
    (service alsa-service-type
             (alsa-configuration
              (pulseaudio? #t)))
    (service pulseaudio-service-type)
    (service tlp-service-type
             (tlp-configuration
              (tlp-default-mode "BAT")
              (cpu-scaling-governor-on-ac (list "ondemand"))
              (cpu-scaling-governor-on-bat (list "powersave"))
              (sched-powersave-on-bat? #t)
              (sata-linkpwr-on-ac "min_power")
              (sata-linkpwr-on-bat "min_power")
              (nmi-watchdog? #t)))
    (service dnsmasq-service-type
             (dnsmasq-configuration
              (listen-addresses (list "127.0.0.1"))
              (servers (list
                        "8.8.8.8"
                        "1.1.1.1"
                        "114.114.114.114"))
              (cache-size 1024)))
    (rngd-service)
    (service brightness-service-type
             (brightness-configuration
              (suffix "builtin-screen")
              (device "intel_backlight")))
    (udev-rules-service 'rtl-sdr rtl-sdr))
   (modify-services
       os-services
     (guix-service-type
      config =>
      (guix-configuration
       (inherit config)
       (authorized-keys
        (append
         (list
          (local-file "../key/thinkpad-x230-luhui.pub"))
         %default-authorized-guix-keys))
       (discover? #t))))))

(define-public thinkpad-x230-luhui:os-packages
  (append
   (list
    ;; VPN
    wireguard-tools
    ;; cpu 频率调整
    cpupower
    ;; btrfs
    btrfs-progs
    ;; cryptsetup
    cryptsetup
    ;; battery
    acpi
    ;; ncurses, clear command
    ncurses
    ;; bluetooth
    bluez dbus
    ;; alsa
    alsa-utils)
   os-packages))


;; 
(define-public thinkpad-x230-luhui:os-bootloader
  (bootloader-configuration
   (bootloader grub-bootloader)
   (target "/dev/sda")))


(define-public thinkpad-x230-luhui:os-mapped-devices
  (list
   (mapped-device
    (source
     (uuid "774c8bbd-719d-459f-8490-7242f0a30b85"))
    (target "cryptroot-thinkpad-x230-luhui")
    (type luks-device-mapping))))

(define-public thinkpad-x230-luhui:os-file-systems
  (append
   (list
    (file-system
      (mount-point "/")
      (device "/dev/mapper/cryptroot-thinkpad-x230-luhui")
      (type "btrfs")
      (options "compress-force=zstd")
      (check? #t)))
   %base-file-systems))

(define-public thinkpad-x230-luhui:users
  (append
   (list
    (user-account
     (name "luhui")
     (comment "admin")
     (group "luhui")
     (supplementary-groups
      (list
       "wheel"
       "audio"
       "video"
       "kvm"
       "users")))
    (user-account
     (name "luhuidev")
     (comment "devel")
     (group "luhui")
     (supplementary-groups
      (list
       "audio"
       "video"
       "kvm"
       "users")))
    (user-account
     (name "luhuiweb")
     (comment "web browser")
     (group "luhui")
     (supplementary-groups
      (list
       "audio"
       "video"
       "users")))
    )
    %base-user-accounts))

(define-public thinkpad-x230-luhui:groups
  (append
   (list
    (user-group
     (name "luhui")))
   %base-groups))


(define-public thinkpad-x230-luhui:os-swap-devices
  (list
   "/var/swapfiles/0"))

(define-public thinkpad-x230-luhui:os-setuid-programs
  (append
   (list)
   %setuid-programs))

(define-public thinkpad-x230-luhui:os-name-service-switch
  %mdns-host-lookup-nss)

(define-public thinkpad-x230-luhui:os-kernel linux-nonfree-5.10)
(define-public thinkpad-x230-luhui:os-firmware (list linux-firmware-nonfree-20210315))

(define-public thinkpad-x230-luhui:os-kernel-arguments
  (append
   (list "acpi_backlight=vendor"         ; fn key
         "acpi_osi=\"!Windows 2012\""    ; fn key
         "modprobe.blacklist=dvb_usb_rtl28xxu")   ; rtl-sdr
   os-kernel-arguments))

(define-public thinkpad-x230-luhui:os
  (operating-system
    (inherit root:os)
    (kernel thinkpad-x230-luhui:os-kernel)
    (kernel-arguments thinkpad-x230-luhui:os-kernel-arguments)
    (firmware thinkpad-x230-luhui:os-firmware)
    (host-name thinkpad-x230-luhui:os-host-name)
    (services thinkpad-x230-luhui:os-services)
    (packages thinkpad-x230-luhui:os-packages)
    (users thinkpad-x230-luhui:users)
    (groups thinkpad-x230-luhui:groups)
    (mapped-devices thinkpad-x230-luhui:os-mapped-devices)
    (file-systems thinkpad-x230-luhui:os-file-systems)
    (swap-devices thinkpad-x230-luhui:os-swap-devices)
    (bootloader thinkpad-x230-luhui:os-bootloader)
    (setuid-programs thinkpad-x230-luhui:os-setuid-programs)
    (name-service-switch thinkpad-x230-luhui:os-name-service-switch)))

thinkpad-x230-luhui:os
