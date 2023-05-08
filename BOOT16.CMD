/***************************************************************************/
/* DSPHEX command file used to convert the communications kernal to        */
/* an EPROM programmer file in Intel format.                               */
/*                                                                         */
/*SECTIONS { .text: BOOT        /* Create boot table header information    */
/*           .data: BOOT }       /* for each section.                      */
/***************************************************************************/


dsk52d16.out                    /* Specify COFF file to convert.           */
-i                              /* Intel format.                           */
-o dsk52d16.lsb                 /* output file */
-o dsk52d16.msb                 /* output file */

