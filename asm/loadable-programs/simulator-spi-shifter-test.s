        .include "setup.s"

VAL=ZP_USAGE_TOP + 1

        jsr sys_newline

        lda #(SPI_DEVICE_3 | SPI_MODE_0)
        ldy #0
        jsr run_test
        bcs .tests_done

        jsr sys_newline

        lda #(SPI_DEVICE_4 | SPI_MODE_1)
        ldy #1
        jsr run_test
        bcs .tests_done

        jsr sys_newline
        lda #(SPI_DEVICE_5 | SPI_MODE_2)
        ldy #2
        jsr run_test
        bcs .tests_done

        jsr sys_newline
        lda #(SPI_DEVICE_6 | SPI_MODE_3)
        ldy #3
        jsr run_test

.tests_done:
        jsr sys_newline
        rts


error_string: .string "Error! "
expected_string: .string "Expected "
got_string: .string " but got "
mode_string: .string "Mode: "
success_string: .string " tested successfully!"

; A should contain valid data for spi_set_device
run_test:
        jsr sys_spi_set_device

        ldx #0
.try_next:
        txa
        jsr sys_spi_transcieve
        lda #$ff
        jsr sys_spi_transcieve

        ; a now holds the value... check it against the expected value
        sta VAL

        txa
        cmp VAL
        bne .error

        inx
        beq .success
        bra .try_next

.success:
        putstr_addr mode_string
        tya
        jsr sys_puthex
        putstr_addr success_string
        jsr sys_newline

        clc
        bra .done

.error:
        pha
        putstr_addr error_string
        jsr sys_newline
        putstr_addr expected_string

        pla
        jsr sys_puthex
        putstr_addr got_string

        lda VAL
        jsr sys_puthex
        jsr sys_newline

        putstr_addr mode_string
        tya
        jsr sys_puthex
        jsr sys_newline        

        sec
.done:
        lda #SPI_DEVICES_DISABLED
        jsr sys_spi_set_device

        rts
