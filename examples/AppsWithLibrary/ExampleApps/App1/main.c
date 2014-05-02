/*  ----------------------------------------------------------------------------
    Copyright (c) 2013, MindTribe Product Engineering, Inc.
    All Rights Reserved.

    Author(s):  Ian Macartney <ian@mindtribe.com>

    Target(s):  ISO/IEC 9899:1999 (C99)
    ------------------------------------------------------------------------- */

#include <stdint.h>
#include <stdbool.h>

#include "Library/Library.h"
#include "hardware.h"

int main(void)
{
    hardware_init();
    Library_Init();
    return 0;
}


#ifdef DEBUG
void __error__(char *pcFilename, unsigned long ulLine)
{
    (void)pcFilename;
    (void)ulLine;

    for(;;)
        ;
}
#endif
