(require 'tree-sitter)

(defun tmy-select-node (node)
  (let* ((node-beg (tsc-node-start-position node))
		 (node-end (tsc-node-end-position node)))
	(set-mark node-end)
	(goto-char node-beg)))

(defun tmy-cursor-node ()
  ;; Get the syntax node the cursor is on.
  (let ((p (point)))
	(tsc-get-descendant-for-position-range
	 (tsc-root-node tree-sitter-tree) p p)))

(defun tmy-mark-node ()
  (interactive)
  (let ((node (tmy-cursor-node)))
	(message (tsc-node-to-sexp node))
	(tmy-select-node node)
	(setq tmy-cursor-node node)))

(defun do-until-selection-changes (fn)
  (interactive)
  (defun go (fn oldbeg oldend)
	(let* ((newbeg (ts-node-start-position tmy-cursor-node))
		   (newend (ts-node-end-position tmy-cursor-node)))
	  (when (and (= newbeg oldbeg) (= newend oldend))
		(funcall fn)
		(go fn newbeg newend))))

  (let* ((node-beg (ts-node-start-position tmy-cursor-node))
		 (node-end (ts-node-end-position tmy-cursor-node)))
	(funcall fn)
	(go fn node-beg node-end)))

(defun tmy-select-parent-once ()
  (interactive)
  (setq tmy-cursor-node (tsc-get-parent tmy-cursor-node))
  (tmy-select-node tmy-cursor-node))

; (node -> node?) -> nil
(defun tmy-try-select (selector)
  (when-let ((new-node (funcall selector tmy-cursor-node)))
	(message "sibling found")
	(setq tmy-cursor-node new-node)
	(tmy-select-node tmy-cursor-node)))

(defun tmy-select-right-once ()
  (setq tmy-cursor-node (tsc-get-prev-named-sibling tmy-cursor-node))
  (tmy-select-node tmy-cursor-node))

; (node -> node?) -> nil
(defun try (selector)
  (do-until-selection-changes '(lambda () (tmy-try-select selector))))

(defun tmy-select-up ()
  (interactive)
  (try 'tsc-get-parent))

(defun tmy-select-left ()
  (interactive)
  (try 'tsc-get-next-sibling))

(defun tmy-select-right ()
  (interactive)
  (try 'tsc-get-prev-sibling))

(defhydra symex2 (global-map "<f2>")
  "navigate"
  ("H" tmy-select-up "out")
  ("h" tmy-select-parent-once "out")
  ("n" tmy-select-left "left")
  ("e" tmy-select-right "right")
  ("m" tmy-mark-node "mark"))
