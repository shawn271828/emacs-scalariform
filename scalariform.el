;;; scalariform.el --- Use scalariform to format your scala source code

;; Author: Shuo Tan <shuo.tan@vsoft.io>
;; Keywords: scala format
;; URL: https://github.com/shuo-tan/emacs-scalariform/scalariform.el
;; Emacs: GNU Emacs 25 or later
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; scalariform allows you to format your scala source

;;; Install:

;; Put this file into load-path'ed directory, and byte compile it if
;; desired. And put the following expression into your ~/.emacs.
;;
;;     (require 'scalariform)

;;; Usage:

;; Bind `scalariform-buffer' and `scalariform-region' to your key map

;;; Code:

(defgroup scalariform nil
  "Customize scalariform"
  :prefix "scalariform-"
  :group 'scalariform)

(defcustom
  scalariform-options
  '("+alignSingleLineCaseStatements"
    "+doubleIndentConstructorArguments"
    "+doubleIndentMethodDeclaration"
    "+preserveSpaceBeforeArguments"
    "-alignSingleLineCaseStatements.maxArrowIndent=40"
    "-indentSpaces=2")
  "All scalariform arguments."
  :type 'list
  :group 'scalariform)

(defun scalariform-call-bin (input-buffer output-buffer start end)
  "Call process scalariform on INPUT-BUFFER saving the output to OUTPUT-BUFFER.

START and END specify region to format.
Return the exit code."
  (let ((args (append (list start end "scalariform" nil output-buffer nil "--stdin") scalariform-options)))
    (with-current-buffer input-buffer
      (apply 'call-process-region args))))

;;;###autoload
(defun scalariform-region (start end)
  "Try to scalariform the current region specified by START and END."
  (interactive "r")
  (let* ((original-buffer (current-buffer))
         (original-point (point))
         (original-window-pos (window-start))
         (tmpbuf (generate-new-buffer "*scalariform*"))
         (exit-code (scalariform-call-bin original-buffer tmpbuf start end))
         (formatted (with-current-buffer tmpbuf (buffer-string))))
    (deactivate-mark)
    (cond ((eq exit-code 0)
           (progn
             (delete-region start end)
             (goto-char start)
             (insert formatted)))
          ((eq exit-code 1)
           (error "Scalariform failed, see %s buffer for details" (buffer-name tmpbuf))))
    ;; Clean up tmpbuf
    (kill-buffer tmpbuf)
    ;; restore window to similar state
    (goto-char original-point)
    (set-window-start (selected-window) original-window-pos)))

;;;###autoload
(defun scalariform-buffer ()
  "Scalariform the whole buffer."
  (interactive)
  (scalariform-region (point-min) (point-max)))

(provide 'scalariform)

;;; scalariform.el ends here
