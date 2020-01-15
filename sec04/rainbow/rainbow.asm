    processor 6502

    include "vcs.h"
    include "macro.h"

    seg code
    org $F000           ; defines the origin of the ROM at $F000

START:
    CLEAN_START         ; Macro to safely clear the memory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start a new fram eby turning on VBLANK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NextFrame:
    lda #2              ; same as binary value %00000010
    sta VBLANK          ; turn on VBLANK
    sta VSYNC           ; turn on VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate 3 lines of VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    sta WSYNC           ; first scanline
    sta WSYNC           ; second scanline
    sta WSYNC           ; third scanline

    lda #0
    sta VSYNC           ; turn off VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the TIA recommended 37 lines of VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #37             ; X = 37 (to count the scan lines)
LoopVBlank:
    sta WSYNC           ; hit WSYNC ans wait for the next scanline
    DEX                 ; decrement X counter (X--)
    bne LoopVBlank      ; loop until X == 0

    lda #0
    sta VBLANK          ; turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw 192 visible scanlines (kernel) (where the magic happens)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #192            ; set the ititrator of the counter
LoopVisible:
    stx COLUBK          ; store A into BackgroundColor Address $09
    sta WSYNC           ; wait for the next scanline
    dex                 ; decrement X counter (X--)
    bne LoopVisible     ; loop until X == 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw 30 invisible scanlines (Overscan)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2              ; hit and turn on VBLANK for overscan
    sta VBLANK

    ldx #30             ; X = 37 (to count the scan lines)
LoopOverScan:
    sta WSYNC           ; hit WSYNC and wait for the next scanline
    DEX                 ; decrement X counter (X--)
    bne LoopOverScan    ; loop until X == 0

    jmp NextFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Fill ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word START ; reset vector at $FFFC (where program starts)
    .word START ; interrupt vector at $FFFE (unused in VCS)