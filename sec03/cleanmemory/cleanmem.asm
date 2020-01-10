    processor 6502
    seg code
    org $F000      ; defines code origin at $F0000

Start:
    sei         ; disables interrupts
    cld         ; disables the BCD decimal math mode
    ldx #$FF    ; loads the X register with #$FF
    txs         ; transfer X register to S(tack) register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Clear the Zero Page region ($00 to $FF)
;;    the entire TIA register space and RAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #0      ; A = 0
    ldx #$FF    ; X = #$FF

MemLoop:
    sta $0,X    ; store ZERO (from "A" register) at address $0 + X
    dex         ; X--
    bne MemLoop ; loop until X==0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Fill ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start ; reset vector at $FFFC (where program starts)
    .word Start ; interrupt vector at $FFFE (unused in VCS)