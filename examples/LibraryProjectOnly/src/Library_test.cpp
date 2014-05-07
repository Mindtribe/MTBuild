/*  ----------------------------------------------------------------------------
    Copyright (c) 2014, MindTribe Product Engineering, Inc.
    All Rights Reserved.

    Author(s):  Jerry Ryle <jerry@mindtribe.com>

    Target(s):  ISO/IEC 14882:2003 (C++03)
    ------------------------------------------------------------------------- */

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

extern "C" {
  #include "Library/Library.h"
}

int main(void)
{
    Library_Init();
    printf("Success!\n");
    return 0;
}
