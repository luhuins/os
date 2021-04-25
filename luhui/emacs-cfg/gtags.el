(autoload 'gtags-mode "gtags" "" t)
(setq c-mode-hook
      '(lambda ()
         (gtags-mode 1)))
