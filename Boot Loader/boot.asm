; ===== BOOTLOADER START =====

bits 16
org 0x7C00

start:
    ; Setup segments
    mov ax, 0x07C0
    mov ds, ax
    mov ax, 0x07E0
    mov ss, ax
    mov sp, 0x2000      ; Stack starts here (make sure it doesn't overwrite anything)

    ; Clear screen
    call clearscreen

    ; Move cursor to top-left (row 0, col 0 = DH=0, DL=0 => DX = 0x0000)
    push 0x0000
    call movecursor
    add sp, 2            ; Clean up stack

    ; Print message
    push msg
    call print
    add sp, 2

    cli
    hlt

; ===== Subroutines =====

clearscreen:
    push bp
    mov bp, sp
    pusha

    mov ah, 0x07        ; Scroll up window (clear)
    mov al, 0x00        ; Number of lines to scroll (0 = clear entire window)
    mov bh, 0x07        ; Attribute: white on black
    mov cx, 0x0000      ; Upper-left corner (row=0, col=0)
    mov dx, 0x184F      ; Lower-right corner (row=24, col=79)
    int 0x10

    popa
    mov sp, bp
    pop bp
    ret

movecursor:
    push bp
    mov bp, sp
    pusha

    mov dx, [bp+4]      ; Cursor position (row: DH, col: DL)
    mov ah, 0x02        ; Set cursor position
    mov bh, 0x00        ; Page number
    int 0x10

    popa
    mov sp, bp
    pop bp
    ret

print:
    push bp
    mov bp, sp
    pusha

    mov si, [bp+4]      ; Pointer to string
    mov bh, 0x00        ; Page number
    mov ah, 0x0E        ; BIOS teletype print function

.print_loop:
    mov al, [si]
    cmp al, 0
    je .done
    int 0x10
    inc si
    jmp .print_loop

.done:
    popa
    mov sp, bp
    pop bp
    ret

; ===== Data Section =====

msg: db "Oh boy do I sure love assembly!", 0

; ===== Boot Signature =====

times 510-($-$$) db 0
dw 0xAA55
