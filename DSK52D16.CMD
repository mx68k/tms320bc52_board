/****************************************************************/
/*             Linker command file for DSK52D16.ASM                */
/****************************************************************/

-e reset
dsk52d16.obj                       /* Specify object file to link  */
-o dsk52d16.out                    /* Specify output file name     */
-m dsk52d16.map                    /* Create memory map file       */
MEMORY
{
    PAGE 0:     PROG:           origin =   00000H,  length = 200h
    PAGE 1:     BLOCKB2:        origin =   060h,    length = 020h
                DATA:           origin =   0200h,   length = 3dfch
}
SECTIONS
{
        .text :  { 
                   *  (.text)
                      .=200h; } = 08b00h > PROG    PAGE 0

        .bss  :  { } > BLOCKB2 PAGE 1
        .data :  {
                   * (.data)
                     .=3dfch; } = 081h > DATA    PAGE 1
}
                         
