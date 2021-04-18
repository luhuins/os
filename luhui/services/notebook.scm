(define-module (luhui services notebook)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (gnu packages)
  #:export (brightness-configuration
            brightness-service-type))


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
