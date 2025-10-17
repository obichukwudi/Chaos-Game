;; title: Chaos-Game
;; version: 1.0.0
;; summary: Generates unpredictable on-chain fractal art using block hashes
;; description: A Chaos Game implementation that creates Sierpinski triangle fractals using block hash entropy

;; constants
(define-constant MAX-ITERATIONS u1000)
(define-constant SCALE-FACTOR u10000)
(define-constant CONTRACT-OWNER tx-sender)

;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-ITERATIONS (err u101))
(define-constant ERR-GENERATION-FAILED (err u102))

;; data vars
(define-data-var current-seed uint u0)
(define-data-var total-fractals-generated uint u0)

;; data maps
(define-map fractal-points uint (list 1000 {x: uint, y: uint}))
(define-map fractal-metadata uint {iterations: uint, block-height: uint, entropy: (buff 32)})

;; public functions

(define-public (generate-fractal (iterations uint))
  (begin
    (asserts! (<= iterations MAX-ITERATIONS) ERR-INVALID-ITERATIONS)
    (let (
      (block-hash (unwrap! (get-block-info? id-header-hash (- block-height u1)) ERR-GENERATION-FAILED))
      (fractal-id (+ (var-get total-fractals-generated) u1))
      (points (generate-sierpinski-points iterations block-hash))
      (metadata {
        iterations: iterations,
        block-height: block-height,
        entropy: block-hash
      })
    )
      (map-set fractal-points fractal-id points)
      (map-set fractal-metadata fractal-id metadata)
      (var-set total-fractals-generated fractal-id)
      (var-set current-seed (+ (var-get current-seed) u1))
      (ok fractal-id)
    )
  )
)

;; read only functions

(define-read-only (get-fractal-points (fractal-id uint))
  (map-get? fractal-points fractal-id)
)

(define-read-only (get-fractal-metadata (fractal-id uint))
  (map-get? fractal-metadata fractal-id)
)

(define-read-only (get-total-fractals)
  (var-get total-fractals-generated)
)

(define-read-only (get-vertex (index uint))
  (if (is-eq index u0)
    {x: u0, y: u0}
    (if (is-eq index u1)
      {x: SCALE-FACTOR, y: u0}
      {x: (/ SCALE-FACTOR u2), y: SCALE-FACTOR}
    )
  )
)

;; private functions

(define-private (generate-sierpinski-points (iterations uint) (entropy (buff 32)))
  (let (
    (iteration-list (get-iteration-list iterations))
  )
    (get points (fold chaos-game-step iteration-list {
      current: {x: (/ SCALE-FACTOR u2), y: (/ SCALE-FACTOR u3)},
      entropy: entropy,
      points: (list)
    }))
  )
)

(define-private (get-iteration-list (n uint))
  (if (<= n u50)
    (unwrap-panic (slice? (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50) u0 n))
    (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50)
  )
)

(define-private (chaos-game-step (iteration uint) (state {current: {x: uint, y: uint}, entropy: (buff 32), points: (list 1000 {x: uint, y: uint})}))
  (let (
    (random-vertex-index (mod (hash-to-uint (get entropy state) iteration) u3))
    (target-vertex (get-vertex random-vertex-index))
    (new-point {
      x: (/ (+ (get x (get current state)) (get x target-vertex)) u2),
      y: (/ (+ (get y (get current state)) (get y target-vertex)) u2)
    })
  )
    {
      current: new-point,
      entropy: (get entropy state),
      points: (unwrap-panic (as-max-len? (append (get points state) new-point) u1000))
    }
  )
)

(define-private (hash-to-uint (entropy (buff 32)) (salt uint))
  (let (
    (hash-result (keccak256 entropy))
    (salt-offset (mod salt u32))
    (selected-byte (unwrap-panic (element-at hash-result salt-offset)))
  )
    (buff-to-uint-le selected-byte)
  )
)

