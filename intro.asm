*=$2c00
startintro
          lda            #%00000000
          sta            $d015
          lda            #$00
          sta            $d020
          sta            $d021
          ldx            #$00      
          lda            #$1b
          sta            $d011
          lda            $8
          sta            $d016
          ldx            #$00
@l2
          lda            #$20
          sta            $0400,x   
          sta            $0500,x   
          sta            $0600,x   
          sta            $0700,x   
          dex
          cpx            #$00     
          bne @l2
          
drawtext
          ldx            #$00
@loop
          jsr xdxd
          lda            string,x
          sta            $05ba,x   
          cmp            #$ff

          lda            #$01
          sta            $d9ba,x
          inx
          lda            string,x          
          cmp            #$00
          bne            @loop     
          ldx            #$00      
          jmp waitforkey
          
xdxd
          jsr            noop      
          jsr            noop
          jsr noop 
          jsr noop
          jsr noop 
          jsr noop   
          jsr noop 
          jsr            noop      
          rts
waitforkey

         lda $00c5
         cmp #60
         bne waitforkey 
          rts
noop
          ldy #$00
@sd          iny
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          cpy            #$ff      
          bne            @sd   
          rts
string
; Screen 2 - 
        BYTE    $02,$05,$20,$11,$15,$09,$03,$0B,$2C,$20,$10,$12,$15,$04,$05,$0E,$14,$2C,$20,$01,$0E,$04,$20,$10,$12,$05,$10,$01,$12,$05,$04,$20,$06,$0F,$12,$20,$20,$20,$20,$20
        BYTE    $17,$08,$01,$14,$05,$16,$05,$12,$20,$0D,$09,$07,$08,$14,$20,$08,$01,$10,$10,$05,$0E,$21,$21,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
        BYTE    $10,$12,$05,$13,$13,$20,$13,$10,$01,$03,$05,$20,$28,$3A,$00