/*-------------------------------------------------------------------*/
/* IFSlistCL - List contents of an IFS folder to file QTEMP/IFSLIST  */
/*                                                                   */
/* Date       Pgmr   Proj  Task Scan Desc                            */
/* 2005-07-11 Keck   11264           Created                         */
/*-------------------------------------------------------------------*/
pgm &folder
dcl &folder *char 256


             dltf qtemp/IFSLIST
             monmsg CPF0000

             OVRDBF     FILE(IFSLIST) TOFILE(QTEMP/IFSLIST) +
                          OVRSCOPE(*CALLLVL)

             CRTPF      FILE(QTEMP/IFSLIST) SRCFILE(NBTYGPL/QDDSSRC) +
                          OPTION(*NOSRC *NOLIST)

             call ifsList &folder

endpgm
