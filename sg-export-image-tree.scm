; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; Save layers of an XCF image to PNG files (in the same directory as original XCF).
; Layer modes, offsets, opacity, and hierarchy are saved as a PNG comment (for
; later reconstruction, perhaps?).

(define (script-fu-sg-export-image-tree image)
 
(define (clean str)
  (list->string (filter (lambda (ch) (or (char-alphabetic? ch)
                                         (char-numeric? ch)))
                        (string->list str)))
  )

  (define (gen-next)
    (let ((count 0))
      (lambda ()
        (set! count (succ count))
        (number->string count) )))
  (define next-group-id (gen-next))
  
  (define (process-group layers prefix hierarchy)
    (let ((next-layer-id (gen-next)))
      (let loop ((layers layers)
                 (layer-id (next-layer-id)) )
        (unless (null? layers)
          (let ((layer (car layers)))
            (if (zero? (car (gimp-item-is-group layer)))
              (let* ((filename (string-append prefix "~" (clean (car (gimp-drawable-get-name layer) ) ) ".png"))
                     (width (car (gimp-drawable-width layer)))
                     (height (car (gimp-drawable-height layer)))
                     (temp-image (car (gimp-image-new width height RGB)))
                     (temp-layer (car (gimp-layer-new-from-drawable layer temp-image))) )
                (gimp-image-add-layer temp-image temp-layer 0)
                (gimp-image-parasite-attach temp-image 
                                            (list "gimp-comment"
                                                  3
                                                  (string-append "("
                                                                 (number->string (car (gimp-layer-get-opacity layer)))
                                                                 " "
                                                                 (number->string (car (gimp-layer-get-mode layer)))
                                                                 " "
                                                                 (number->string (car (gimp-drawable-offsets layer)))
                                                                 " "
                                                                 (number->string (cadr (gimp-drawable-offsets layer)))
                                                                 "):"
                                                                 (string-append hierarchy "-" layer-id) )))
                (display filename) (newline)
                (file-png-save2 RUN-NONINTERACTIVE 
                                temp-image 
                                temp-layer
                                filename 
                                filename 
                                FALSE ; interlace
                                9 ; compression
                                FALSE ; bkgd
                                (car (gimp-drawable-has-alpha layer))
                                FALSE ; offs
                                FALSE ; phys
                                FALSE ; time
                                TRUE  ; comment
                                FALSE ; svtrans
                                )
                (gimp-image-delete temp-image) )
                (process-group (vector->list (cadr (gimp-item-get-children layer)))
                               prefix
                               (string-append hierarchy "~" layer-id) ))
          (loop (cdr layers) (next-layer-id)) )))))
  ; main program
  (let ((basename (car  (strbreakup (car (gimp-image-get-filename image)) ".xcf"))))
    (process-group (vector->list (cadr (gimp-image-get-layers image)))  basename "")
    )
  (gimp-progress-end)
  )
(script-fu-register "script-fu-sg-export-image-tree"
  "Export Image Tree"
  "Save all layers as PNG"
  "Saul Goode"
  "saulgoode"
  "Nov 2012"
  "*"
  SF-IMAGE    "Image"    0
  )
(script-fu-menu-register "script-fu-sg-export-image-tree"
  "<Image>/File/Export"
  )
