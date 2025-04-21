rand_8:
	lda R_SEED		; get seed
	and #$B8		; mask non feedback bits
				    ; for maximal length run with 8 bits we need
			    	; taps at b7, b5, b4 and b3
	ldx #$05		; bit count (shift top 5 bits)
	ldy #$00		; clear feedback count
F_loop:
	asl		        ; shift bit into carry
	bcc bit_clr		; branch if bit = 0

	iny			    ; increment feedback count (b0 is XOR all the	
			    	; shifted bits from A)
bit_clr:
	dex		    	; decrement count
	bne F_loop		; loop if not all done

no_clr:
	tya			    ; copy feedback count
	lsr		        ; bit 0 into Cb
	lda R_SEED		; get seed back
	rol		        ; rotate carry into byte
	sta R_SEED		; save number as next seed
	rts			    ; done