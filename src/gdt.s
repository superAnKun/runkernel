DESC_G_4K   equ  1_00000000000000000000000b
DESC_D_32   equ  1_0000000000000000000000b
DESC_L      equ  0_000000000000000000000b

DESC_AVL    equ  0_00000000000000000000b

DESC_LIMIT_CODE2 equ 1111_0000000000000000b 
DESC_LIMIT_DATA2 equ DESC_LIMIT_CODE2
DESC_LIMIT_VIDEO2 equ 0000_000000000000000b
DESC_P           equ  1_000000000000000b
DESC_DPL_0       equ  00_0000000000000b
DESC_DPL_1       equ  01_0000000000000b
DESC_DPL_2       equ  10_0000000000000b
DESC_DPL_3       equ  11_0000000000000b
DESC_S_CODE      equ  1_000000000000b
DESC_S_DATA      equ  DESC_S_CODE
DESC_S_sys       equ  0_000000000000b
DESC_TYPE_CODE   equ  1000_00000000b


DESC_TYPE_DATA   equ  0010_00000000b

DESC_CODE_HIGH4_K  equ  (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + DESC_LIMIT_CODE2 + \
DESC_P + DESC_DPL_0 + DESC_S_CODE + DESC_TYPE_CODE + 0x00

DESC_CODE_HIGH4_U  equ  (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + DESC_LIMIT_CODE2 + \
DESC_P + DESC_DPL_3 + DESC_S_CODE + DESC_TYPE_CODE + 0x00

DESC_DATA_HIGH4_K  equ  (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + DESC_LIMIT_DATA2 + DESC_P + \
DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x00

DESC_DATA_HIGH4_U  equ  (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + DESC_LIMIT_DATA2 + DESC_P + \
DESC_DPL_3 + DESC_S_DATA + DESC_TYPE_DATA + 0x00

DESC_VIDEO_HIGH4  equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + DESC_LIMIT_VIDEO2 + DESC_P + \
DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x0b

RPL0   equ   00b
RPL1   equ   01b
RPL2   equ   10b
RPL3   equ   11b

TI_GDT   equ   000b
TI_LDT   equ   100b

SELECTOR_CODE_K  equ  (0x0001 << 3) + TI_GDT + RPL0
SELECTOR_CODE_U  equ  (0x0002 << 3) + TI_GDT + RPL3
SELECTOR_DATA_K  equ  (0x0003 << 3) + TI_GDT + RPL0
SELECTOR_DATA_U  equ  (0x0004 << 3) + TI_GDT + RPL3
SELECTOR_VIDEO equ  (0x0005 << 3) + TI_GDT + RPL0

__PAGE_OFFSET equ (0xC0000000)


extern main
global gdt_entry

section .text
[bits 32]
gdt_entry:
; 重新定义选择子和描述符 根据操作系统真相还原来定义
    ;关闭中断
    cli
    ;关闭不可屏蔽中断
    in al, 0x70
    or al, 0x80
    out 0x70, al
    ;重新加载gdt
    lgdt [GDT_PTR]
    jmp dword SELECTOR_CODE_K:runkel 

runkel:
    mov ax, SELECTOR_DATA_K
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    xor edi, edi
    xor esi, esi
    xor ebp, ebp
    xor esp, esp
    mov esp, 0x1000

    mov edi, (pg0 - __PAGE_OFFSET)
    mov eax, 7
page_table0:  ;生成两个页表,一个页表映射4M内存 共8M物理内存被映射
    ;stosl
    mov [edi], eax
    add edi, 4
    add eax, 0x1000
    cmp edi, (empty_zero_page - __PAGE_OFFSET)
    jne page_table0

    ;填充页目录表
    mov edi, swaper_pg_dir
    
    call main

halt_step:
    halt
    jmp halt_step

section .data

section .data.pgdir
swapper_pg_dir equ 0x100000
pg0 equ 0x101000
pg1 equ 0x102000
empty_zero_page equ 0x103000

GDT_START:
;knull_dsc: dq 0
;kcode_dsc: dq 0x00cf9e000000ffff
;kdata_dsc: dq 0x00cf92000000ffff
;k16cd_dsc: dq 0x00009e000000ffff
;k16da_dsc: dq 0x000092000000ffff

GDT_BASE: dd  0x00000000
          dd  0x00000000
CODE_DESC_K: dd 0x0000FFFF
           dd DESC_CODE_HIGH4_K
CODE_DESC_U: dd 0x0000FFFF
           dd DESC_CODE_HIGH4_U
DATA_STACK_DESC_K: dd 0x0000FFFF
                 dd DESC_DATA_HIGH4_K
DATA_STACK_DESC_U: dd 0x0000FFFF
                 dd DESC_DATA_HIGH4_U
VIDEO_DESC: dd 0x80000007
            dd DESC_VIDEO_HIGH4
GDT_END:

GDT_PTR:
GDTLEN  dw GDT_END-GDT_START-1
GDTBASE dd GDT_START

