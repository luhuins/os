(define-module (luhui services notebook)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services linux)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (gnu packages)
  #:export (brightness-configuration
            brightness-service-type
            thinkpad-fan-configuration
            thinkpad-fan-service-type))


(define-record-type* <brightness-configuration>
  brightness-configuration make-brightness-configuration
  brightness-configuration?
  (suffix brightness-configuration-suffix
          (default "default"))
  (device brightness-configuration-device
          (default #f))
  (save-dir brightness-configuration-save-dir
            (default "/var/lib/brightness-save/")))

(define brightness-service-type
  (shepherd-service-type
   'brightness
   (lambda (config)
     (let* ((suffix (brightness-configuration-suffix config))
            (device (brightness-configuration-device config))
            (device-control-file ; 控制亮度的节点
             (string-append
              "/sys/class/backlight/"
              device
              "/brightness"))
            (level-save-file ; 存放亮度的文件
             (string-append
              (brightness-configuration-save-dir config)
              "/"
              device
              "/brightness")))
       (define (dump-level-saved-to-brightness-control)
         #~(begin
             (call-with-input-file #$level-save-file
               (lambda (level-save-port)
                 (call-with-output-file #$device-control-file
                   (lambda (device-control-port)
                     (dump-port
                      level-save-port device-control-port)))))))
       (define (dump-brightness-control-to-level-saved)
         #~(begin
             (call-with-output-file #$level-save-file
               (lambda (level-save-port)
                 (call-with-input-file #$device-control-file
                   (lambda (device-control-port)
                     (dump-port
                      device-control-port level-save-port)))))))
       (shepherd-service
        (documentation "save & restore brightness level on device")
        (requirement '(user-processes udev))
        (provision (list (symbol-append 'brightness- (string->symbol suffix))))
        (start
         #~(lambda _
             (if (file-exists? #$device-control-file)
                 (if (file-exists? #$level-save-file)
                     (begin
                       #$(dump-level-saved-to-brightness-control))
                     (begin ; 存放亮度的文件不存在,创建并存储现有屏幕亮度
                       (mkdir-p (dirname #$level-save-file))
                       #$(dump-brightness-control-to-level-saved)))
                 #f)))
        (stop
         #~(lambda _
             (if (file-exists? #$device-control-file)
                 (if (file-exists? #$level-save-file)
                     (begin ; 存储现有屏幕亮度
                       #$(dump-brightness-control-to-level-saved))
                     (begin ; 存放亮度的文件不存在,创建并存储现有屏幕亮度
                       (mkdir-p (dirname #$level-save-file))
                       #$(dump-brightness-control-to-level-saved)))
                 #f)))
        (modules `((rnrs io ports)
                   ,@%default-modules)))))
   (description "save & restore on service start/stop")))

(define %thinkpad-fan-device-config
  `("modprobe.d/thinkpad-fan.conf"
    ,(plain-file "thinkpad-fan.conf"
                 "options thinkpad_acpi fan_control=1")))

(define-record-type* <thinkpad-fan-configuration>
  thinkpad-fan-configuration make-thinkpad-fan-configuration
  thinkpad-fan-configuration?
  (speed thinkpad-fan-configuration-speed
         (default "auto"))) ; string:  0-7 | auto

(define thinkpad-fan-shepherd-service
  (lambda (config)
    (let* ((speed (thinkpad-fan-configuration-speed config))
           (speed-command (string-append "level" " " speed))
           (level-control-file ; 控制风扇的文件
            "/proc/acpi/ibm/fan"))
      (shepherd-service
       (documentation "set up thinkpad's fan")
       (provision (list 'thinkpad-fan))
       (start
        #~(lambda _
            (call-with-output-file #$level-control-file
              (lambda (level-control-port)
                (format level-control-port #$speed-command)))))
       (modules `((rnrs io ports)
                  ,@%default-modules))))))

(define thinkpad-fan-service-type
  (service-type
   (name 'thinkpad-fan)
   (extensions
    (list
     (service-extension kernel-module-loader-service-type
                        (const (list "thinkpad_acpi")))
     (service-extension etc-service-type
                        (const (list %thinkpad-fan-device-config)))
     (service-extension shepherd-root-service-type
                        (compose list thinkpad-fan-shepherd-service))))
   (description "set up thinkpad's fan")
   (default-value (thinkpad-fan-configuration))))

