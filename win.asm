*=$3e00
          sei
          lda            #<irqq
          ldx            #>irqq
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
          sta            $d019     ; ACK any raster IRQs
          lda            #$00
          cli

          jmp            win

irqq
          lda            #$01
          sta            $d019     ; ACK any raster IRQs
          jmp            $ea31     
          
win
          ldy            #$00      
@lp1
          lda            wintxt,y  
          sta            $05c6,y   
          iny
          cpy            #11       
          bne            @lp1 
          ldy #$00
     
@lp2
          inx          
          stx            $d9c6,y   
          cpy            #11       
          bne            @lp1
          ldy #$00
          jmp @lp2
           

wintxt
        BYTE    $19,$0F,$15,$20,$17,$09,$0E,$21,$21,$21
