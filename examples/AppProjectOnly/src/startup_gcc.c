#include <stdint.h>
#include <stdbool.h>

void ResetISR(void);
static void DefaultISR(void);
extern int main(void);

static unsigned long pulStack[64] = {0};

__attribute__ ((section(".isr_vector")))
void (* const g_pfnVectors[])(void) =
{
    (void (*)(void))((unsigned long)pulStack + sizeof(pulStack)),
    ResetISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    0,
    0,
    0,
    0,
    DefaultISR,
    DefaultISR,
    0,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    0,
    0,
    0,
    0,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    0,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR,
    DefaultISR
};

extern unsigned long _etext;
extern unsigned long _data;
extern unsigned long _edata;
extern unsigned long _bss;
extern unsigned long _ebss;

void ResetISR(void)
{
    unsigned long *pulSrc, *pulDest;

    // Copy the data segment initializers from flash to SRAM.
    pulSrc = &_etext;
    for(pulDest = &_data; pulDest < &_edata; ) {
        *pulDest++ = *pulSrc++;
    }

    // Zero the bss segment.
    __asm("    ldr     r0, =_bss\n"
          "    ldr     r1, =_ebss\n"
          "    mov     r2, #0\n"
          "    .thumb_func\n"
          "zero_loop:\n"
          "        cmp     r0, r1\n"
          "        it      lt\n"
          "        strlt   r2, [r0], #4\n"
          "        blt     zero_loop");

    (void) _bss;
    (void) _ebss;

    main();
}

static void DefaultISR(void)
{
    for(;;)
        ;
}
