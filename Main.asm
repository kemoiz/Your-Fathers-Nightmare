*=$c000
incbin    "charbin.bin"
*=$3000
SB        = $D400
;;;;;;;;;;;;;;;;;;;;;;;;;;;
; start&setup!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start
; turning off the music
          jsr            $2c00
          sei
          lda            #<irq2
          ldx            #>irq2
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
          jsr            $8000
          cli
; music is turned off now, doing regular stuff
          lda            #$00
          sta            $d020
          lda            #$1b
          sta            $d011
; copying rom characters to $2000
          sei                       
          ldx            #$08       
          lda            #%00110011 
          sta            $01        
          lda            #$c0   
          sta            $fc
          ldy            #$00      
          sty            $fb
          lda            #$20
          sta            $59
          ldy            #$00
          sty            $58
                                  
loop      lda            ($fb),y   
          sta            ($58),y    
          iny                       
          bne            loop      
          inc            $fc
          inc            $59
                                    
          dex                     
          bne            loop      
          lda            #%00110111 
          sta            $01        
          cli
          lda            #$18       
          sta            $d018
          clc
          jmp            drawscreen
start2
          lda            #$00
start3    sta            $d020
          sta            $d021
          jmp            initplayer
          jmp            initenemy
;--------------------------
;loop
gameloop
          jsr            moveplayer
          jsr            debug
          jsr            setanim
          jsr            checkforsprcol
          jsr            noploop
          jsr            noploop
          jsr            noploop
          jsr            checktime
          jsr            checkifwin
          jsr            checkforbkgcol
          jsr            drawplayerslife
          jsr            checkforcoins
          jsr            checkgameover
          jsr            sound
          jmp            gameloop
drawscreen
          lda            #$1b
          sta            $d011
          lda            $8
          sta            $d016
          ldx            #$00
@dr1                               ;d800-dbff
;; screendata init
          lda            #$00
          sta            $d020
          sta            $d021
          lda            $9500,x
          sta            $0400,x
          lda            $9600,x
          sta            $0500,x
          lda            $9700,x
          sta            $0600,x
          lda            $9800,x
          sta            $0700,x
;; colourdata init
          lda            #$01
          sta            $d020
          sta            $d021
          lda            $9000,x
          sta            $d800,x
          lda            $9100,x
          sta            $d900,x
          lda            $9200,x
          sta            $da00,x
          lda            $9300,x
          sta            $db00,x
          inx
          cpx            $fe
          bne            @dr1
@dr2
          jmp            start2
initplayer
          lda            #$30
          sta            $07f8
          lda            #$01
          sta            $d015
          lda            #$50
          sta            $d000
          sta            $d001
          sta            pbuffer
          sta            pbuffer+1
          lda            #$03
          sta            $d027
                                   ;
initenemy
;multi layer
          lda            #$35
          sta            $07f9
          lda            #%00000100
          sta            $d01c
          lda            #10
          sta            $d025
          lda            #07
          sta            $d026
          lda            #01
          sta            $d029
;mono layer
          lda            #$36
          sta            $07fa
          lda            #%00001111
          sta            $d015
          lda            #$30
          sta            $d002
          sta            $d003
          sta            $d004
          sta            $d005
          lda            #$00
          sta            $d028
;secondsrak
          lda            #$37
          sta            $07fb
          lda            #02
          sta            $d030
          lda            #$40
          sta            $d006
          sta            $d007
          jmp            gameloop
;--------
;routines
;-----------------------------------
checkgameover
          clc
          lda            playerlife
          cmp            #$00
          beq            @gameover
          cmp            #$ff
          beq            @gameover
          rts
@gameover
          lda            #$10
          sta            playerlife
          lda            #$00
          sta            $8f05
          sta            $8f06
          sta            $8f07
          sta            $8f08
          lda            #$17
          sta            timeleft
          inc            $d021
          ldx            #$00
@rescons
          lda            $9a80,x
          sta            $9a00,x
          inx
          cpx            #$80
          bne            @rescons
          jmp            $3000
checktime
          lda            timeleft
          cmp            #$00
          bne            @comeback
          lda            #$10
          sta            playerlife
          lda            #$00
          sta            $8f05
          sta            $8f06
          sta            $8f07
          sta            $8f08
          lda            #$17
          sta            timeleft
          inc            $d021
          ldx            #$00
@rescons
          lda            $9a80,x
          sta            $9a00,x
          inx
          cpx            #$80
          bne            @rescons
          jmp            $3000
          rts
@comeback
          rts
checkifwin
          lda            coins
          cmp            #13
          bne            @comeback
          inc            $d82a
          inc            $d852
          lda            $d000
          sec
          sbc            #$14
          lsr
          lsr
          lsr
          cmp            #3
          bne            @comeback
          lda            $d001
          sec
          sbc            #$14
          lsr
          lsr
          lsr
          cmp            #5
          bne            @comeback
          jmp            $3c00     ;win
@comeback
          rts
drawplayerslife
          lda            playerlife
          lsr
          sta            playerlifeshift
          ldy            #$00
@loop
          lda            #$53
          sta            $07b6,y
          iny
          cpy            playerlifeshift
          bne            @loop
@loop2    lda            #$20
          sta            $07b6,y
          iny
          cpy            #9
          bne            @loop2
          rts
secenemyloop
          ldx            secenemypointer
          lda            $9c00,x
          sta            secenemypos
          sta            $d006
          lda            $9c01,x
          sta            secenemypos+1
          sta            $d007
          lda            secenemyinvert
          cmp            #$01
          beq            @dexx
          inx
          inx
          jmp            @cm
@dexx
          dex
          dex
@cm
          stx            secenemypointer
          cpx            #156
          bne            @comeback
          lda            #$01
          sta            secenemyinvert
          stx            secenemypointer
@comeback
          ldx            secenemypointer
          cpx            #00
          beq            @inv
          rts
@inv
          lda            #$00
          sta            secenemyinvert
          rts
enemyloop
          ldx            enemypointer
          lda            $9b00,x
          sta            enemypos
          lda            $9b01,x
          sta            enemypos+1
          lda            enemypos
          sta            $d002
          sta            $d004
          lda            enemypos+1
          sta            $d003
          sta            $d005
          inx
          inx
          stx            enemypointer
          rts
checkforsprcol
          LDA            $D01E     ;Read hardware sprite/sprite collision
          LSR                      ; (LSR A for TASM users) Collision for sprite 1
          BCS            HIT
          RTS                      ;No collision
HIT
          LDA            #15
          STA            SB+24
                                   ; VOICE 3 FREQUENCY, LO-HI BYTE
          LDA            #112
          STA            SB+14
          LDA            #4
          STA            SB+15
                                   ; VOICE 3 ADSR
          LDA            #14
          STA            SB+19
          LDA            #6
          STA            SB+20
                                   ; VOICE 3 WAVEFORM(S) GATE
          LDA            #129
          STA            SB+18
          INC            $D020
          dec            playerlife
          rts
sound
          lda            playermoving
          cmp            #$00
          beq            @comeback
          clc
          lda            gotcoin
          cmp            #$01
          bcs            @comeback
; FILTER MODE AND VOLUME
          LDA            #15
          STA            SB+24
; VOICE 3 FREQUENCY, LO-HI BYTE
          LDA            #48
          STA            SB+14
          LDA            #38
          STA            SB+15
; VOICE 3 ADSR
          LDA            #%00010010
          STA            SB+19
          LDA            #4
          STA            SB+20
; VOICE 3 WAVEFORM(S) GATE
          LDA            #129
          STA            SB+18
@comeback
          lda            gotcoin
          cmp            #$00
          beq            @comeback2
          inc            gotcoin
; FILTER MODE AND VOLUME
          LDA            #15
          STA            SB+24
                                   ; VOICE 3 FREQUENCY, LO-HI BYTE
          LDA            #130
          STA            SB+14
          LDA            gotcoin
          adc            #$35
          STA            SB+15
                                   ; VOICE 3 PULSE WAVEFORM WIDTH, LO-HI BYTE
          LDA            #33
          STA            SB+16
          LDA            #22
          STA            SB+17
                                   ; VOICE 3 ADSR
          LDA            #14
          STA            SB+19
          LDA            #6
          STA            SB+20
          lda            gotcoin
          cmp            $03
          bcs            @nogate
                                   ; VOICE 3 WAVEFORM(S) GATE
@gate     LDA            #65
          jmp            @return
@nogate   lda#64
@return   STA            SB+18
          lda            gotcoin
          cmp            #$07
          bne            @comeback2
          lda            #$00
          sta            gotcoin
@comeback2
          rts
checkforcoins
          lda            coins
          cmp            #13
          bne            @next
          ldy            #$00
@lp1
          lda            txtok,y
          sta            $0629,y
          iny
          cpy            #3
          bne            @lp1
@next     ldy            #$00      ;loop counter
          lda            $d000
          sec
          sbc            #$14
          lsr
          lsr
          lsr
          sta            pbuffer2
          lda            $d001
          sec
          sbc            #$14
          lsr
          lsr
          lsr
          sta            pbuffer2+1
@loop
          lda            $9a00,y
          cmp            pbuffer2
          beq            @check1
@cbe      tya
          clc
          adc            #$04
          tay
          cpy            #4*20
          bne            @loop
          rts
@check1
          lda            $9a01,y
          cmp            pbuffer2+1
          bne            @cbe
          inc            coins
;-- clearing char
          ldx            $9a02,y
          stx            $58
          ldx            $9a03,y
          stx            $59
          tya
          tax
          lda            #$20
          ldy            #$00
          sta            ($58),y
          inc            $d020     ;-- removing pointer
          lda            #$00
          sta            $9a00,x
          sta            $9a01,x
          sta            $9a02,x
          sta            $9a03,x
          lda            #$01
          sta            gotcoin
          rts
@comeback
          rts
debug
          lda            timeleft
          jsr            accto3digit
          sty            $04e7
          stx            $04e8
          sta            $04e9
          lda            $01
          sta            $d8e7
          sta            $d8e8
          sta            $d8e9
          lda            coins
          jsr            accto3digit
          sty            $0717
          stx            $0718
          sta            $0719
          lda            $01
          sta            $db17
          sta            $db18
          sta            $db19
          rts
setanim
          clc
          lda            playermoving
          cmp            #0
          beq            @none
          cmp            #1
          beq            @up
          cmp            #2
          beq            @left
          rts
@left
          clc
          lda            $00a2
          asl
          asl
          asl
          asl
          cmp            #%10000000
          bcs            @left2
          lda            #$33
          sta            $07f8
          rts
@left2
          lda            #$34
          sta            $07f8
          rts
@up
          clc
          lda            $00a2
          asl
          asl
          asl
          asl
          cmp            #%10000000
          bcs            @up2
          lda            #$31
          sta            $07f8
          rts
@up2
          lda            #$32
          sta            $07f8
          rts
@none
          lda            #$30
          sta            $07f8
          rts
accto3digit
          ldy            #$2f
          ldx            #$3a
          sec
@s        iny
          sbc            #100
          bcs            @s
@w        dex
          adc            #10
          bmi            @w
          adc            #$2f
          rts
moveplayer2
          lda            playerx
          sta            $d000
          lda            playery
          sta            $d001
          rts
checkforbkgcol
          lda            $d01f
          lsr
          bcs            bounce
                                   ;
          lda            playerx
          sta            pbuffer
          lda            playery
          sta            pbuffer+1
          rts
bounce    lda            pbuffer
          sta            $d000
          lda            pbuffer+1
          sta            $d001
          sec
          rts
moveplayer
          jsr            checkforbkgcol
          bcs            @comeback
          lda            $00c5
          cmp            #64
          beq            @comeback
          clc
                                   ;; 9 - w, 10 - a, 13 - s, 18 - d (dec)
          lda            $00c5
          cmp            #9
          beq            @moveup
          cmp            #10
          beq            @moveleft
          cmp            #13
          beq            @movedown
          cmp            #18
          beq            @moveright
          rts
@moveup
          lda            #$01
          sta            playermoving
          dec            playery
          rts
@movedown
          lda            #$01
          sta            playermoving
          inc            playery
          rts
@moveleft
          lda            #$02
          sta            playermoving
          dec            playerx
          rts
@moveright
          lda            #$02
          sta            playermoving
          inc            playerx
          rts
@comeback
          lda            #0
          sta            playermoving
          rts
noploop
          ldy            #$00
@nl1
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          iny
          cpy            #$ff
          bne            @nl1
          rts
irq2
          lda            #$01
          sta            $d019    
          jsr            $8003     
          jsr            enemyloop
          jsr            secenemyloop
          lda            $00a2
          cmp            $f0
          beq            @dectimer
          jmp            $ea31
@dectimer
          dec            timeleft
          jmp            $ea31
;data, constants etc $1175
;;;;;;;;;;;;;;;;;;;
*=$d000
playerx
          BYTE            $50
*=$d001
playery
          BYTE            $50
;-------------------------
;variables in ram
;--------------------------
*=$8f00
pbuffer
          byte            $50,$50
pbuffer2
          byte            $00,$00
boolcolision
          byte            $00
playermoving
;0-false, 1-up/down, 2-left/right
          byte            $00
coins
          byte            $00
gotcoin
          byte            $00
colourtable1
          byte            00,11,12,15
pointer1
          byte            $00
enemypointer
          byte            $00
enemypos
          byte            $1c,$1c
playerlife
          byte            $10
playerlifeshift
          byte            $10
secenemypos
          byte            $1c,$1c
secenemypointer
          byte            $00
secenemyinvert
          byte            $00
timeleft
          byte            $17
txtok
          BYTE            $0F,$0B
*=$0c00
playersprite
;;;;;;;;;;;;;;;;;;;
          BYTE            $00,$00,$00,$3C,$00,$00,$3C,$00,$00
          BYTE            $18,$00,$00,$3C,$00,$00,$5A,$00,$00
          BYTE            $18,$00,$00,$24,$00,$00,$24,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
*=$0c40
          BYTE            $00,$00,$00,$3C,$00,$00,$3C,$00,$00
          BYTE            $18,$00,$00,$3C,$00,$00,$5A,$00,$00
          BYTE            $38,$00,$00,$24,$00,$00,$04,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
*=$0c80
          BYTE            $00,$00,$00,$3C,$00,$00,$3C,$00,$00
          BYTE            $18,$00,$00,$3C,$00,$00,$5A,$00,$00
          BYTE            $1C,$00,$00,$24,$00,$00,$20,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
*=$0cc0
;
          BYTE            $00,$00,$00,$38,$00,$00,$38,$00,$00
          BYTE            $38,$00,$00,$D0,$00,$00,$28,$00,$00
          BYTE            $C4,$00,$00,$02,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
*=$0d00
;
          BYTE            $00,$00,$00,$38,$00,$00,$38,$00,$00
          BYTE            $38,$00,$00,$16,$00,$00,$28,$00,$00
          BYTE            $4E,$00,$00,$80,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
*=$0d40
; badguy s
          BYTE            $00,$00,$00,$03,$FF,$E0,$07,$00,$F0
          BYTE            $0E,$00,$78,$1D,$FF,$BC,$39,$18,$9E
          BYTE            $31,$9C,$8E,$61,$FF,$86,$40,$00,$02
          BYTE            $40,$20,$02,$40,$20,$02,$40,$30,$02
          BYTE            $40,$00,$02,$41,$FF,$02,$41,$55,$02
          BYTE            $41,$FF,$02,$31,$01,$0C,$0C,$00,$30
          BYTE            $03,$00,$C0,$00,$FF,$00,$00,$00,$00
*=$0d80
; badguy color
          BYTE            $00,$00,$00,$00,$00,$00,$01,$55,$00
          BYTE            $01,$55,$40,$05,$AA,$40,$05,$AA,$50
          BYTE            $05,$AA,$50,$05,$AA,$54,$15,$55,$54
          BYTE            $15,$55,$54,$15,$55,$54,$15,$55,$54
          BYTE            $15,$55,$54,$15,$55,$54,$15,$55,$54
          BYTE            $3D,$55,$54,$3F,$55,$5C,$0F,$FF,$F0
          BYTE            $03,$FF,$C0,$00,$FF,$00,$00,$00,$00
; srak
          BYTE            $00,$00,$00,$7E,$00,$00,$66,$00,$00
          BYTE            $5A,$00,$00,$5A,$00,$00,$42,$00,$00
          BYTE            $7E,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
          BYTE            $00,$00,$00,$00,$00,$00,$00,$00,$00
;xd
;
