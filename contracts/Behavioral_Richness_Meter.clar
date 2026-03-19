;; ---------------------------------------------------------
;; Behavioral Richness Meter
;; Measures diversity and non-monotony of user behavior
;; ---------------------------------------------------------

;; -----------------------------
;; Error codes
;; -----------------------------

(define-constant ERR-ACTION-REPEATED u700)
(define-constant ERR-INVALID-ACTION u701)

;; -----------------------------
;; Configuration constants
;; -----------------------------

(define-constant MAX-ACTION-TYPE u10)       ;; allowed action types: 0-10
(define-constant DIVERSITY-WINDOW u2016)    ;; ~2 weeks

(define-constant RICHNESS-REWARD u1)
(define-constant MONOTONY-PENALTY u1)

;; -----------------------------
;; Data storage
;; -----------------------------

;; Last action type per user
(define-map last-action-type
  principal
  uint
)

;; Last action block
(define-map last-action-block
  principal
  uint
)

;; Count of unique actions in window
(define-map unique-action-count
  principal
  uint
)

;; Behavioral richness score
(define-map richness-score
  principal
  uint
)

;; -----------------------------
;; Read-only helpers
;; -----------------------------

(define-read-only (get-richness-score (user principal))
  (default-to u0 (map-get? richness-score user))
)

(define-read-only (get-unique-count (user principal))
  (default-to u0 (map-get? unique-action-count user))
)

;; -----------------------------
;; Core logic
;; -----------------------------

(define-public (record-behavior (action-type uint))
  (let (
        (user tx-sender)
        (current-block burn-block-height)
       )

    ;; Validate action type
    (if (> action-type MAX-ACTION-TYPE)
        (err ERR-INVALID-ACTION)

        (let (
              (last-action (map-get? last-action-type user))
              (last-block (map-get? last-action-block user))
              (current-score (default-to u0 (map-get? richness-score user)))
              (current-unique (default-to u0 (map-get? unique-action-count user)))
             )

          ;; First interaction
          (if (is-none last-action)
              (begin
                (map-set last-action-type user action-type)
                (map-set last-action-block user current-block)
                (map-set unique-action-count user u1)
                (map-set richness-score user u1)
                (ok u1)
              )

              ;; Returning user
              (let (
                    (previous-action (unwrap-panic last-action))
                    (previous-block (unwrap-panic last-block))
                    (gap (- current-block previous-block))
                   )

                ;; Reset diversity window
                (if (> gap DIVERSITY-WINDOW)
                    (begin
                      (map-set unique-action-count user u1)
                      (map-set last-action-type user action-type)
                      (map-set last-action-block user current-block)
                      (map-set richness-score user (+ current-score RICHNESS-REWARD))
                      (ok (+ current-score RICHNESS-REWARD))
                    )

                    ;; Same action repeated - monotony penalty
                    (if (is-eq action-type previous-action)
                        (let (
                              (penalized-score
                                (if (> current-score MONOTONY-PENALTY)
                                    (- current-score MONOTONY-PENALTY)
                                    u0
                                )
                              )
                             )
                          (map-set richness-score user penalized-score)
                          (map-set last-action-block user current-block)
                          (err ERR-ACTION-REPEATED)
                        )

                        ;; New action type - richness reward
                        (let (
                              (new-unique (+ current-unique u1))
                              (new-score (+ current-score RICHNESS-REWARD))
                             )
                          (map-set unique-action-count user new-unique)
                          (map-set richness-score user new-score)
                          (map-set last-action-type user action-type)
                          (map-set last-action-block user current-block)
                          (ok new-score)
                        )
                    )
                )
              )
          )
        )
    )
  )
)
