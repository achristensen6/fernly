.text

.global _start
_start:
disable_interrupts:
	mrs	r0, cpsr
	mov	r1, #0xc0
	orr	r0, r0, r1
	msr	cpsr_cxsf, r0

relocate_stack:
  ldr     r0, =0x70009ffc // stack_start
	mov     sp, r0


//.equ DUMP_START, 0x0
.equ DUMP_START, 0xfff00000
.equ DUMP_LEN, 0x10000

.equ PULSE_LENGTH, 0x40000


dump:
        ldr     r8, =DUMP_START
        add     r9, r8, #DUMP_LEN
next:
        ldr     r5, [r8]
        mov     r6, #1
nextmask:
        and     r7, r5, r6
        cmp     r7, r6
        beq     motor_one
        bne     motor_zero

shiftmask:
        mov     r6, r6, LSL #1
        cmp     r6, #0
        bne     nextmask

        add     r8, r8, #4

        ldr     r0, =MOTOR_CTRL
        ldr     r1, =MOTOR_CTRL_OFF
	      str     r1, [r0]
	      bl delay
	      bl delay
	      bl delay

        cmp     r8, r9
        blt     next

        bl      reboot

demo:
        mov     r0, #0x08
        bl      motor_pulse
        bl      reboot
error:                          // if we didn't reboot, leave motor on
        bl      motor_on
        b       error

.equ MOTOR_CTRL, 0xa07001b0
.equ MOTOR_CTRL_OFF, 0x0422
.equ MOTOR_CTRL_LOW, 0x8000
.equ MOTOR_CTRL_MED, 0x8010
.equ MOTOR_CTRL_HIGH, 0x8020

motor_one:
        ldr     r0, =MOTOR_CTRL
        ldr     r1, =MOTOR_CTRL_HIGH
	      str     r1, [r0]

	      bl delay
	      bl delay

        ldr     r0, =MOTOR_CTRL
        ldr     r1, =MOTOR_CTRL_OFF
	      str     r1, [r0]

	      bl delay

        bl      shiftmask

motor_zero:
        ldr     r0, =MOTOR_CTRL
        ldr     r1, =MOTOR_CTRL_HIGH
	      str     r1, [r0]

	      bl delay

        ldr     r0, =MOTOR_CTRL
        ldr     r1, =MOTOR_CTRL_OFF
	      str     r1, [r0]

	      bl delay

        bl      shiftmask



motor_on:
        ldr     r0, =MOTOR_CTRL
        ldr     r1, =MOTOR_CTRL_HIGH
	str     r1, [r0]
        bx      lr

motor_off:
        ldr     r0, =MOTOR_CTRL
        ldr     r1, =MOTOR_CTRL_OFF
	str     r1, [r0]
        bx      lr

        // pulse motor r0 times
motor_pulse:
        push    {lr}
        mov     r4, r0
1:
        bl      motor_on
        bl      delay
        bl      motor_off
        bl      delay
        subs    r4, r4, #1
        bne     1b
        pop     {lr}
        bx      lr

        // trigger WDT reboot
reboot:
        ldr     r0, =0xa003001c
        ldr     r1, =0x1209
        str     r1, [r0]
        bx      lr              // shouldn't get here

delay:
        mov     r0, #PULSE_LENGTH
1:
        subs    r0, r0, #1
        bne     1b
        bx      lr
