MBT_HDR_FLAGS   EQU 0x00010003
MBT_HDR_MAGIC   EQU 0x1BADB002 ;多引导协议头魔数
MBT_HDR2_MAGIC  EQU 0xe85250d6 

GRUB2_HEAD_MAGIC EQU 0xe85250d6  ;多引导程序 grub2的魔数
GRUB2_HEAD_ARCHITECTURE_I386  equ 0  ;指定cpu指令集体系结构 0代表i386 32位 4代表32位MIPS
GRUB2_TAG_HEADER_TYPE equ 2
GRUB2_TAG_HEADER_FLAG equ 1

GRUB2_ENTRY_TAG_TYPE equ 3
GRUB2_ENTRY_TAG_FLAG equ 1

GRUB2_END_TAG_TYPE equ 0
GRUB2_END_TAG_FLAG equ 0

extern main
extern _edata
extern _end
global _start

[bits 32]
[section .text]
_start:
    jmp _entry

;grub1的头
;ALIGN 8
;mbt_hdr:
;dd MBT_HDR_MAGIC
;dd MBT_HDR_FLAGS
;dd -(MBT_HDR_MAGIC+MBT_HDR_FLAGS)
;dd mbt_hdr
;dd _start
;dd 0
;dd 0
;dd _entry

;grub2的头
ALIGN 8
grub2_header_start:
dd GRUB2_HEAD_MAGIC
dd GRUB2_HEAD_ARCHITECTURE_I386
dd grub2_header_end - grub2_header_start ;grub2头部的长度

; checksum ,一个32位的值， 使得 magic architecture header_length checksum四个字段的值和位0
dd -(GRUB2_HEAD_MAGIC + GRUB2_HEAD_ARCHITECTURE_I386 + (grub2_header_end - grub2_header_start))  


ALIGN 8
; grub2的tag
header_start:
dw GRUB2_TAG_HEADER_TYPE
dw GRUB2_TAG_HEADER_FLAG
dd header_end - header_start
dd grub2_header_start  ;内核被加载到操作系统的那个位置  看来标签代表的都是绝对地址，而不是偏移地址
dd _start ; 加载内核的起始地址
dd _edata
dd _end
header_end:
ALIGN 8
entry_tag_start:
dw GRUB2_ENTRY_TAG_TYPE
dw GRUB2_ENTRY_TAG_FLAG
dd entry_tag_end - entry_tag_start
dd _entry
dd 0
entry_tag_end:
end_tag_start:
dw GRUB2_END_TAG_TYPE
dw GRUB2_END_TAG_FLAG
dd end_tag_end - end_tag_start
end_tag_end:
grub2_header_end:

ALIGN 8
_entry:
; 重新定义选择子和描述符 根据操作系统真相还原来定义
    ;关闭中断
    cli
    ;关闭不可屏蔽中断
    in al, 0x70
    or al, 0x80
    out 0x70, al
    ;重新加载gdt
    lgdt [GDT_PTR]
    jmp dword 0x8:runkel 

runkel:
    mov ax, 0x10
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
    mov esp, 0x9000
    call main

halt_step:
#    halt
#    jmp halt_step

GDT_START:
knull_dsc: dq 0
kcode_dsc: dq 0x00cf9e000000ffff
kdata_dsc: dq 0x00cf92000000ffff
k16cd_dsc: dq 0x00009e000000ffff
k16da_dsc: dq 0x000092000000ffff
GDT_END:

GDT_PTR:
GDTLEN  dw GDT_END-GDT_START-1
GDTBASE dd GDT_START





