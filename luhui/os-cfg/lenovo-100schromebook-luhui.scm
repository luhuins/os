(define-module (luhui os-cfg lenovo-100schromebook-luhui)
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
  #:use-module (luhui os-cfg root)
  #:use-module (luhui os-cfg thinkpad-x230-luhui))


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

(define-public lenovo-100schromebook-luhui:os-host-name "lenovo-100schromebook-luhui")
(define-public lenovo-100schromebook-luhui:os-services
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
              (size "1000M")
              (compression-algorithm 'zstd)
              (memory-limit "1500M")
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
              (device "intel_backlight"))))
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

(define-public lenovo-100schromebook-luhui:os-packages
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
    ;; efibootmgr
    efibootmgr
    ;; ncurses, clear command
    ncurses)
   os-packages))


;; 
(define-public lenovo-100schromebook-luhui:os-bootloader
  (bootloader-configuration
   (bootloader grub-efi-bootloader)
   (target "/boot/efi")))


(define-public lenovo-100schromebook-luhui:os-mapped-devices
  (list
   (mapped-device
    (source
     (uuid "774c8bbd-719d-459f-8490-7242f0a30b85"))
    (target "cryptroot-lenovo-100schromebook-luhui")
    (type luks-device-mapping))))

(define-public lenovo-100schromebook-luhui:os-file-systems
  (append
   (list
    (file-system
      (mount-point "/boot/efi")
      (device (uuid "1234-ABCD" 'fat))
      (type "vfat")
      (check? #t))
    (file-system
      (mount-point "/")
      (device "/dev/mapper/cryptroot-lenovo-100schromebook-luhui")
      (type "btrfs")
      (options "compress-force=zstd:15")
      (check? #t)))
   %base-file-systems))

(define-public lenovo-100schromebook-luhui:users
  thinkpad-x230-luhui:users)

(define-public lenovo-100schromebook-luhui:groups
  thinkpad-x230-luhui:groups)


(define-public lenovo-100schromebook-luhui:os-swap-devices
  (list
   "/var/swapfiles/0"))

(define-public lenovo-100schromebook-luhui:os-setuid-programs
  (append
   (list)
   %setuid-programs))

(define-public lenovo-100schromebook-luhui:os-name-service-switch
  %mdns-host-lookup-nss)

(define-public lenovo-100schromebook-luhui:os-kernel linux-nonfree-5.10)
(define-public lenovo-100schromebook-luhui:os-firmware (list linux-firmware-nonfree-20210315))

(define-public lenovo-100schromebook-luhui:os-kernel-arguments
  (append
   (list)
   os-kernel-arguments))

(define-public lenovo-100schromebook-luhui:os
  (operating-system
    (timezone os-timezone)
    (locale os-locale)
    (kernel-arguments lenovo-100schromebook-luhui:os-kernel-arguments)
    (kernel lenovo-100schromebook-luhui:os-kernel)
    (firmware lenovo-100schromebook-luhui:os-firmware)
    (issue os-issue)
    (host-name lenovo-100schromebook-luhui:os-host-name)
    (services lenovo-100schromebook-luhui:os-services)
    (packages lenovo-100schromebook-luhui:os-packages)
    (users lenovo-100schromebook-luhui:users)
    (groups lenovo-100schromebook-luhui:groups)
    (mapped-devices lenovo-100schromebook-luhui:os-mapped-devices)
    (file-systems lenovo-100schromebook-luhui:os-file-systems)
    (swap-devices lenovo-100schromebook-luhui:os-swap-devices)
    (bootloader lenovo-100schromebook-luhui:os-bootloader)
    (setuid-programs lenovo-100schromebook-luhui:os-setuid-programs)
    (name-service-switch lenovo-100schromebook-luhui:os-name-service-switch)))

lenovo-100schromebook-luhui:os
