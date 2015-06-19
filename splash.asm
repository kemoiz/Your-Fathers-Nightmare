; 10 SYS (2080)
*=$801
          BYTE $0E, $08, $0A, $00, $9E, $20, $28, $32, $30, $38, $30, $29, $00, $00, $00
bordercolour = 0
backgroundcolour = 0
vidmem    = $4F40
colmem    = $5328
*=$820
;;;;;;;;;
;sfx
;;;;;;;;;
          sei
          lda            #<irq
          ldx            #>irq
          sta            $314
          stx            $315
          lda            #$1b
          ldx            #$00
          ldy            #$7f
          sta            $d011
          stx            $d012
          sty            $dc0d
          lda            #$01
          sta            $d01a
          sta            $d019    
          lda            #$00
          jsr            $1000
          cli
          jmp            $3000
irq
          lda            #$01
          sta            $d019    
          jsr            $1003    
          jmp            $ea31
*=$0ffe
incbin    "splashmusic.prg"
*=$7ffe
incbin    "ing2.c64.prg"
;;;;;;;;;;;;;;;;;;;;;;;;;
;gfx
;;;;;;;;;;;;;
;Picture displayer

buffer
          BYTE            $00
