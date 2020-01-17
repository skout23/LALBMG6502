    processor 6502

    include "vcs.h"
    include "macro.h"

    seg code
    org $F000           ; defines the origin of the ROM at $F000

Reset:
    CLEAN_START         ; Macro to safely clear the memory

    ldx #$80            ; blue background color
    stx COLUBK

    lda #$1C            ; yellow playfield
    sta COLUPF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start a new frame by configuring VBLANK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:
    lda #02             ; same as binary value %00000010
    sta VBLANK          ; turn on VBLANK
    sta VSYNC           ; turn on VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate 3 lines of VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    REPEAT 3
        sta WSYNC       ; generate scanline
    REPEND
    lda #0
    sta VSYNC           ; turn off VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the TIA recommended 37 lines of VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    REPEAT 37
        sta WSYNC       ; hit WSYNC anc wait for the next scanline
    REPEND
    lda #0
    sta VBLANK          ; turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set the CTRLPF register to allow playfield reflection
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #%00000001      ; CTRLPF register (D0 means reflect the PF)
    stx CTRLPF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw 192 visible scanlines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Skip the 7 scanlines with no PF set
    ldx #0              ; same as #%00000000
    stx PF0
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND

    ; Set the PF0 to 1110 (LSB first) and PF1-PF2 as 1111 1111
    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND

    ; Set the next 164 lines only with PF0 third bit enabled
    ldx #%01100000
    stx PF0
    ldx #%00000000
    stx PF1
    ldx #%10000000
    stx PF2
    REPEAT 164
        sta WSYNC
    REPEND

    ; Set the PF0 to 1110 (LSB first) and PF1-PF2 as 1111 1111
    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND
 
    ; Skip the 7 scanlines with no PF set
    ldx #0              ; same as #%00000000
    stx PF0
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw 30 invisible scanlines (Overscan)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2              ; hit and turn on VBLANK for overscan
    sta VBLANK
    REPEAT 30
        sta WSYNC       ; hit WSYNC anc wait for the next scanline
    REPEND
    lda #0
    sta VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Lopp to the next frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Fill ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Reset ; reset vector at $FFFC (where program starts)
    .word Reset ; interrupt vector at $FFFE (unused in VCS)