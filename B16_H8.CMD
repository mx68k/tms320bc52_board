/***************************************************************************/
/* DSPHEX command file used to convert the communications kernal to        */
/* an EPROM programmer file in Intel format.                               */
/***************************************************************************/


dsk52d16.out                    /* Specify COFF file to convert.           */
-i                              /* Intel format.                           */
-memwidth 8                     /* Set memwidth and romwidth = 8 to create */
-romwidth 8                     /* an 8-bit wide eprom programmer file.    */
-bootorg 08000h                 /* Define address where boot table will    */
                                /* be located.                             */
SECTIONS { .text: BOOT          /* Create boot table header information    */
           .data: BOOT }        /* for each section.                       */

