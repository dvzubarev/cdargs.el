;;; cdargs.el --- Directory Bookmarks
;; $Id: $
;; Copyright (C) 2003 by Stefan Kamphausen
;; Author: Stefan Kamphausen <mail@skamphausen.de>
;; Keywords: tools, unix
;; This file is not part of XEmacs.

;; This program is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING. If not, write to the Free
;; Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
;; 02111-1307, USA.


;;; Commentary:
;; This is an Emacs front-end to cdargs. It provides a function (cv or
;; cdargs) which uses the same bookmarks list as the terminal program
;; cdargs and lets the user quickly make a directory listed there the
;; current working directory.
;; CDargs is available from
;; http://www.skamphausen.de/software/cdargs/
;;
;;; Installation:
;; Since version 1.24 there is a cdargs.el which you just put
;; somewhere where Emacs can find it (see variable load-path) and the
;; require it in your personal init file (may be one of ~/.emacs,
;; ~/.xemacs/init.el ~/.xemacs/my/config/personal.el or something
;; else):
;; (require 'cdargs)
;; This defines the function cdargs and an alias cv

;;; Code:

(eval-when-compile
  (require 'tramp))

(defgroup cdargs nil
  "Jump to directories quickly."
  :tag "CDargs"
  :link '(url-link :tag "Home Page"
                   "http://www.skamphausen.de/software/cdargs/")
  :link '(emacs-commentary-link
          :tag "Commentary in cdargs.el" "cdargs.el")
  :prefix "cdargs-"
  :group 'editing-basics)

(defcustom cdargs-list-file "~/.cdargs"
  "The filename of the cdargs bookmarks."
  :type 'string
  :group 'cdargs)


(defcustom cdargs-find-file-function 'find-file
  "A function that will be used for accessing bookmarked directory."
  :type 'function
  :group 'cdargs)

(defcustom cdargs-dired-find-file-function 'find-alternate-file
  "A function that will be used in dired-mode."
  :type 'function
  :group 'cdargs)

(defcustom cdargs-warped-hook nil
  "List of function to run after changing to a directory with cdargs.
For example it can be useful to add the `desktop-read' function here.
This way you can restore a whole session saved earlier with
desktop-save without having to start Emacs from a terminal.

It's probably a good idea to use some kind of wrapper to check whether
a desktop exists because otherwise it would delete all open buffers:

\(add-hook 'cdargs-warped-hook
          '(lambda ()
             (when (file-exists-p
                    (expand-file-name desktop-basefilename \"./\"))
               (desktop-read))))"
  :type 'hook
  :group 'cdargs)


;;;###autoload
(defun cdargs ()
  "open a directory in dired (by default) using a bookmarks file.
This function behaves similar to the command line program cdargs
together with which it is distributed.
You can use TAB completion and the usual history repeat keys for
quick access."
  (interactive)
  (if (eq major-mode 'dired-mode)
      (cdargs-do-cdargs cdargs-dired-find-file-function)
    (cdargs-do-cdargs cdargs-find-file-function)))

(defun cdargs-do-cdargs (find-file-func)
  (let* ((alist (cdargs-make-list))
         (hist (mapcar 'car alist))
         (dir (cdr (assoc
                    (completing-read
                     "warp to: " alist
                     nil t nil 'hist nil)
                    alist))))
    (funcall find-file-func dir)
    (run-hooks 'cdargs-warped-hook)))

(defalias 'cv 'cdargs)

(defun cdargs--compose-remote-prefix ()
  (with-parsed-tramp-file-name default-directory cdargs-tramp
    (tramp-make-tramp-file-name
     cdargs-tramp-method
     cdargs-tramp-user
     cdargs-tramp-domain
     cdargs-tramp-host
     cdargs-tramp-port
     "" ;localname empty for now
     cdargs-tramp-hop)))

(defun cdargs--compose-prefix ()
  (if (tramp-tramp-file-p default-directory)
      (cdargs--compose-remote-prefix)
    ""))


(defun cdargs--compose-local-file-name ()
  (expand-file-name cdargs-list-file))

(defun cdargs--compose-list-file-name (prefix)
  (if (tramp-tramp-file-p default-directory)
      (concat prefix cdargs-list-file)
    (cdargs--compose-local-file-name)))


(defun cdargs-make-list ()
  "Return an ALIST with descriptions and paths."
  (let* ((prefix (cdargs--compose-prefix))
         (file (cdargs--compose-list-file-name prefix))
         (the-list) (desc) (path) (start))
    (when (file-readable-p file)
      (with-temp-buffer
        (insert-file-contents file)
        (goto-char (point-min))
        (while (not (eobp))
          (setq
           desc (buffer-substring
                 (point) (- (search-forward " /") 2)))
          (setq path (buffer-substring
                      (- (point) 1) (progn
                                      (end-of-line)
                                      (point))))
          (setq the-list
                (cons (cons desc (concat prefix path))
                      the-list))
          (forward-line))))
    the-list))

;;;###autoload
(defun cdargs-edit ()
  "Simply open the bookmarks file"
  (interactive)
  (find-file cdargs-list-file))

(provide 'cdargs)

;;; cdargs.el ends here
