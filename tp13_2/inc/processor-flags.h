;/*
; * Basic CPU control in CR0
;*/

%define X86_CR0_PE      0x00000001; /* Protected mode Enable */
%define X86_CR0_MP      0x00000002; /* Monitor coProcessor */
%define X86_CR0_EM      0x00000004; /* EMulation */
%define X86_CR0_TS      0x00000008; /* Task Switched */
%define X86_CR0_ET      0x00000010; /* Extension Type */
%define X86_CR0_NE      0x00000020; /* Numeric Error */
%define X86_CR0_WP      0x00010000; /* Write Protect */
%define X86_CR0_AM      0x00040000; /* Alignment Mask */
%define X86_CR0_NW      0x20000000; /* Not Write-through */
%define X86_CR0_CD      0x40000000; /* Cache Disable */
%define X86_CR0_PG      0x80000000; /* PaGine */

%define PAG_P_YES      0x00000001;
%define PAG_RW_W       0x00000001;
%define PAG_RW_R       0x00000000;
%define PAG_US_SUP     0x00000000;
%define PAG_US_USR     0x00000001;
%define PAG_PWT_NO     0x00000000;
%define PAG_PCD_NO     0x00000000;
%define PAG_A          0x00000000;
%define PAG_PS_4K      0x00000000;

%define IDLE           0x00000000;
%define WAITTING       0x00000001;
%define RUNNING        0x00000002;

; Revisar que va en cada caso..
%define PAG_RW_R_US_SUP 0x00000001;
%define PAG_RW_R_US_USR 0x00000101;
%define PAG_RW_W_US_SUP 0x00000011;
%define PAG_RW_W_US_USR 0x00000111;