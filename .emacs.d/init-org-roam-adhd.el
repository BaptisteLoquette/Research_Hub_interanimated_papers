;;; init-org-roam-adhd.el --- ADHD-specific Helpers -*- lexical-binding: t -*-
;;
;; Part of the Research_Hub_interanimated_papers Org-Roam setup.
;;
;;; Commentary:
;;
;; This module provides tools that reduce cognitive load and support ADHD:
;;
;;   - Pomodoro / focus timer (org-pomodoro or lightweight custom timer)
;;   - "Where was I?" — shows recently edited Org-Roam notes
;;   - Orphan note finder — for weekly review
;;   - Quick stats (note / link / tag counts)
;;   - Auto-save on idle (prevents "I forgot to save" anxiety)
;;   - Breadcrumb trail — recent node navigation history
;;   - Focus mode — hides modeline, maximizes writing area
;;   - Streak tracker — consecutive days with captures
;;   - Gentle session reminder after long hyperfocus sessions
;;
;;; Code:

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 1. org-pomodoro — Focus timer with visual feedback
;;; ─────────────────────────────────────────────────────────────────────────────

(use-package org-pomodoro
  :ensure t
  :commands org-pomodoro
  :custom
  ;; Standard Pomodoro intervals.
  (org-pomodoro-length 25)               ; 25-minute focus sprint
  (org-pomodoro-short-break-length 5)    ; 5-minute break
  (org-pomodoro-long-break-length 20)    ; 20-minute long break
  (org-pomodoro-long-break-frequency 4)  ; Long break after 4 pomodoros
  ;; Audio cues (requires `aplay' / `afplay').
  (org-pomodoro-play-sounds t)
  :config
  ;; Show remaining time in the modeline via the standard hook.
  (add-hook 'org-pomodoro-started-hook
            (lambda () (message "🍅 Pomodoro started! Focus for %d minutes." org-pomodoro-length)))
  (add-hook 'org-pomodoro-finished-hook
            (lambda () (message "✅ Pomodoro done! Take a %d-minute break." org-pomodoro-short-break-length)))
  (add-hook 'org-pomodoro-break-finished-hook
            (lambda () (message "🔔 Break over — start a new Pomodoro with C-c n p"))))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 2. Lightweight fallback timer (no org-pomodoro required)
;;; ─────────────────────────────────────────────────────────────────────────────

(defvar rh/focus-timer nil
  "Active focus timer object, or nil when no timer is running.")

(defvar rh/focus-timer-duration 25
  "Default focus timer duration in minutes.")

(defun rh/start-focus-timer (&optional minutes)
  "Start a focus countdown for MINUTES (default: `rh/focus-timer-duration').
Displays a message when time is up.  Cancels any existing timer."
  (interactive "P")
  (when rh/focus-timer
    (cancel-timer rh/focus-timer))
  (let ((mins (or minutes rh/focus-timer-duration)))
    (setq rh/focus-timer
          (run-at-time (* mins 60) nil
                       (lambda ()
                         (message "🔔 %d-minute focus session complete! Take a break." mins)
                         (setq rh/focus-timer nil))))
    (message "🍅 Focus timer started: %d minutes. Go!" mins)))

(defun rh/cancel-focus-timer ()
  "Cancel the running focus timer, if any."
  (interactive)
  (if rh/focus-timer
      (progn
        (cancel-timer rh/focus-timer)
        (setq rh/focus-timer nil)
        (message "⏹ Focus timer cancelled."))
    (message "No focus timer is running.")))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 3. "Where was I?" — recently edited Org-Roam notes
;;; ─────────────────────────────────────────────────────────────────────────────

(defvar rh/roam-recent-history '()
  "List of recently visited Org-Roam node file paths (most recent first).
Capped at `rh/roam-history-limit' entries.")

(defvar rh/roam-history-limit 20
  "Maximum number of entries kept in `rh/roam-recent-history'.")

(defun rh/roam-record-visit ()
  "Add the current file to `rh/roam-recent-history' if it is an Org-Roam node."
  (when (and buffer-file-name (org-roam-file-p buffer-file-name))
    (setq rh/roam-recent-history
          (seq-take
           (delete-dups (cons buffer-file-name rh/roam-recent-history))
           rh/roam-history-limit))))

(add-hook 'find-file-hook  #'rh/roam-record-visit)
(add-hook 'after-save-hook #'rh/roam-record-visit)

(defun rh/where-was-i ()
  "Show the list of recently visited Org-Roam notes and jump to one.
This is the ADHD \"where was I?\" recovery tool — use it after a distraction
or at the start of a new session to quickly re-orient yourself."
  (interactive)
  (if (null rh/roam-recent-history)
      (message "No recently visited Org-Roam notes yet. Start writing!")
    (let* ((candidates
            (mapcar (lambda (f)
                      (cons (file-name-nondirectory f) f))
                    rh/roam-recent-history))
           (choice (completing-read "Where was I? Recent notes: "
                                    candidates nil t)))
      (find-file (cdr (assoc choice candidates))))))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 4. Orphan note finder — weekly review helper
;;; ─────────────────────────────────────────────────────────────────────────────

(defun rh/org-roam-find-orphans ()
  "Open a note that has zero backlinks (no other note links to it).
Orphan notes are good candidates for linking, expanding, or archiving.
Run this during your weekly review to keep the graph well-connected."
  (interactive)
  (let ((orphans (org-roam-db-query
                  [:select [nodes:title nodes:file]
                   :from nodes
                   :left-join links :on (= nodes:id links:dest)
                   :where (is links:dest :null)
                   :and (not-like nodes:file "%daily%")])))
    (if (null orphans)
        (message "🎉 No orphan notes — your graph is well-connected!")
      (let* ((candidates
              (mapcar (lambda (row)
                        (cons (or (car row) (cadr row)) (cadr row)))
                      orphans))
             (choice (completing-read
                      (format "Orphan notes (%d): " (length orphans))
                      candidates nil t)))
        (find-file (cdr (assoc choice candidates)))))))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 5. Quick stats — note / link / tag count
;;; ─────────────────────────────────────────────────────────────────────────────

(defun rh/org-roam-stats ()
  "Display a summary of your Org-Roam knowledge base in the minibuffer.
Shows: total notes, total links, unique tags, orphan count."
  (interactive)
  (let* ((nodes  (caar (org-roam-db-query
                        [:select (funcall count *) :from nodes])))
         (links  (caar (org-roam-db-query
                        [:select (funcall count *) :from links])))
         (tags   (caar (org-roam-db-query
                        [:select (funcall count :distinct dest) :from tags])))
         (orphans (length
                   (org-roam-db-query
                    [:select [nodes:id]
                     :from nodes
                     :left-join links :on (= nodes:id links:dest)
                     :where (is links:dest :null)]))))
    (message
     "📊 Org-Roam — Notes: %d | Links: %d | Tags: %d | Orphans: %d"
     nodes links tags orphans)))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 6. Auto-save on idle — never lose work
;;; ─────────────────────────────────────────────────────────────────────────────

(defvar rh/auto-save-idle-seconds 30
  "Seconds of idle time before auto-saving all modified Org-Roam buffers.")

(defun rh/auto-save-roam-buffers ()
  "Save all modified Org-Roam buffers silently.
Called automatically after `rh/auto-save-idle-seconds' of idle time."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and (eq major-mode 'org-mode)
                 buffer-file-name
                 (buffer-modified-p)
                 (org-roam-file-p buffer-file-name))
        (save-buffer)))))

(run-with-idle-timer rh/auto-save-idle-seconds t #'rh/auto-save-roam-buffers)

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 7. Focus mode — maximized, modeline-hidden writing environment
;;; ─────────────────────────────────────────────────────────────────────────────

(defvar rh/focus-mode-active nil
  "Non-nil when `rh/focus-mode' is active.")

(defvar rh/focus-mode--saved-mode-line nil
  "Saved value of `mode-line-format' before entering focus mode.")

(defun rh/focus-mode ()
  "Toggle a distraction-free writing environment.
Hides the modeline, hides the fringe, and maximises the current window.
Pressing the same key again restores the previous layout."
  (interactive)
  (if rh/focus-mode-active
      ;; ── Deactivate ────────────────────────────────────────────────────────
      (progn
        (setq-local mode-line-format rh/focus-mode--saved-mode-line)
        (set-fringe-style nil)
        (winner-undo)
        (setq rh/focus-mode-active nil)
        (message "🖊 Focus mode OFF"))
    ;; ── Activate ──────────────────────────────────────────────────────────
    (progn
      (setq rh/focus-mode--saved-mode-line mode-line-format)
      (setq-local mode-line-format nil)
      (set-fringe-style 0)
      (winner-save-unconditionally)
      (delete-other-windows)
      (setq rh/focus-mode-active t)
      (message "🎯 Focus mode ON — press C-c n F to exit"))))

;; Enable winner-mode so we can restore the window layout.
(winner-mode 1)

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 8. Streak tracker — consecutive capture days
;;; ─────────────────────────────────────────────────────────────────────────────

(defvar rh/capture-streak-file
  (expand-file-name ".roam-streak" (or (bound-and-true-p org-roam-directory)
                                       user-emacs-directory))
  "File that stores the capture streak data (last-date and count).")

(defun rh/load-streak ()
  "Return (LAST-DATE . COUNT) plist from the streak file, or nil."
  (when (file-exists-p rh/capture-streak-file)
    (with-temp-buffer
      (insert-file-contents rh/capture-streak-file)
      (read (current-buffer)))))

(defun rh/save-streak (last-date count)
  "Persist LAST-DATE (string YYYY-MM-DD) and COUNT to the streak file."
  (with-temp-file rh/capture-streak-file
    (prin1 (cons last-date count) (current-buffer))))

(defun rh/update-streak ()
  "Update the capture streak.  Call this after every capture."
  (let* ((today   (format-time-string "%Y-%m-%d"))
         (data    (rh/load-streak))
         (last    (car data))
         (count   (or (cdr data) 0))
         (yesterday (format-time-string "%Y-%m-%d"
                                        (time-subtract (current-time)
                                                       (seconds-to-time 86400)))))
    (cond
     ((equal today last)
      ;; Already captured today — no change.
      count)
     ((equal yesterday last)
      ;; Captured yesterday → extend the streak.
      (let ((new-count (1+ count)))
        (rh/save-streak today new-count)
        new-count))
     (t
      ;; Streak broken → reset to 1.
      (rh/save-streak today 1)
      1))))

(defun rh/show-streak ()
  "Display the current capture streak in the minibuffer."
  (interactive)
  (let* ((data  (rh/load-streak))
         (count (or (cdr data) 0))
         (last  (or (car data) "never")))
    (message "🔥 Capture streak: %d day%s (last: %s)"
             count (if (= count 1) "" "s") last)))

;; Hook into org-roam capture finalization.
(add-hook 'org-roam-capture-new-node-hook
          (lambda ()
            (let ((streak (rh/update-streak)))
              (when (> streak 1)
                (message "🔥 %d-day capture streak! Keep it up!" streak)))))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 9. Long-session reminder — gentle nudge after 90 minutes
;;; ─────────────────────────────────────────────────────────────────────────────

(defvar rh/session-start-time (current-time)
  "Time when the current Emacs session started (used for session reminders).")

(defvar rh/session-reminder-minutes 90
  "Minutes of continuous work before a gentle reminder to take a break.")

(defvar rh/session-reminder-timer nil
  "Timer object for the long-session reminder.")

(defun rh/start-session-reminder ()
  "Start the long-session reminder timer."
  (when rh/session-reminder-timer
    (cancel-timer rh/session-reminder-timer))
  (setq rh/session-reminder-timer
        (run-at-time (* rh/session-reminder-minutes 60) nil
                     (lambda ()
                       (message
                        "☕ You've been working for %d minutes — consider a proper break!"
                        rh/session-reminder-minutes)
                       ;; Restart so the reminder fires again if they keep working.
                       (rh/start-session-reminder)))))

(rh/start-session-reminder)

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 10. Working memory dump — quick capture to today's daily
;;; ─────────────────────────────────────────────────────────────────────────────

(defun rh/brain-dump ()
  "Open today's daily note with a new heading for a brain dump.
Use this when your head is full and you need to offload to the system."
  (interactive)
  (org-roam-dailies-capture-today nil "d"))

(provide 'init-org-roam-adhd)
;;; init-org-roam-adhd.el ends here
