/* boot.S - bootstrap the kernel */
/* Copyright (C) 1999, 2001, 2010 Free Software Foundation, Inc.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#define ASM_FILE 1
#include "multiboot2.h"

/* C symbol format. HAVE ASM USCORE is defined by configure. */
#ifdef HAVE_ASM_USCORE
# define EXT_C(sym) _ ## sym
#else
# define EXT_C(sym) sym
#endif

/* The size of our stack (16KB). */
#define STACK_SIZE 0x4000

/* The flags for the Multiboot header. */
#ifdef __ELF__
# define AOUT_KLUDGE 0
#else
# define AOUT_KLUDGE MULTIBOOT_AOUT_KLUDGE
#endif

#define GRUB_MULTIBOOT_ARCHITECTURE_I386 MULTIBOOT_ARCHITECTURE_I386

    .extern gdt_entry

	.text
	.globl start, _start, multiboot_header
start:
_start:
	jmp multiboot_entry

	/* Align 64 bits boundary. */
	.align 8

	/* Multiboot header. */
multiboot_header:
	/* magic */
	.long MULTIBOOT2_HEADER_MAGIC
	/* ISA: i386 */
	.long GRUB_MULTIBOOT_ARCHITECTURE_I386
	/* Header length. */
	.long multiboot_header_end - multiboot_header
	/* checksum */
	.long -(MULTIBOOT2_HEADER_MAGIC + GRUB_MULTIBOOT_ARCHITECTURE_I386 + (multiboot_header_end - multiboot_header))
#ifndef __ELF__

	.align 8
address_tag_start:
	.short MULTIBOOT_HEADER_TAG_ADDRESS
	.short MULTIBOOT_HEADER_TAG_OPTIONAL
	.long address_tag_end - address_tag_start
	/* header_addr */
	.long multiboot_header
	/* load_addr */
	.long _start  ;程序的起始地址 即代码段的起始地址
	/* load_end_addr */
	.long _edata      //数据段的结束地址。（知道了代码段的起始地址和数据段的结束地址就知道要装载的程序有多大了）
	/* bss end addr */
	.long _end       //bss段的结束地址
address_tag_end:

	.align 8
entry_address_tag_start:
	.short MULTIBOOT_HEADER_TAG_ENTRY_ADDRESS
	.short MULTIBOOT_HEADER_TAG_OPTIONAL
	.long entry_address_tag_end - entry_address_tag_start
	/* entry addr */
	.long multiboot_entry
entry_address_tag_end:
#endif /* ELF */

	.align 8
	.short MULTIBOOT_HEADER_TAG_END
	.short 0
	.long 8
multiboot_header_end:
multiboot_entry:
    jmp gdt_entry

halt_message:
	.asciz "Halted."

	/* Our stack area. */
	.comm stack, STACK_SIZE
