/*----------------------------------------------------------------*/
/* CVTDSPF - Convert DSPF38 --> DSPF Utility                      */
/*                                                                */
/* Date       Pgmr    Project  Task Scan Description              */
/* 2005-12-29 Keck      12050  1.00      Created                  */
/*----------------------------------------------------------------*/
CMD PROMPT('Convert DSPF38 --> DSPF')
PARM KWD(FROMFILE) TYPE(QUAL1) MIN(1) PROMPT('From File')
PARM KWD(TOFILE)   TYPE(QUAL2) MIN(1) PROMPT('To File')

PARM KWD(FROMMBR) TYPE(*CHAR) LEN(10) MIN(1) PROMPT('From Member')
PARM KWD(TO)      TYPE(*CHAR) LEN(10) MIN(1) PROMPT('To Member')

QUAL1: QUAL TYPE(*NAME) LEN(10) DFT(QDDSSRC)
       QUAL TYPE(*NAME) LEN(10) DFT(*LIBL) SPCVAL(*LIBL)

QUAL2: QUAL TYPE(*NAME) LEN(10) DFT(QDDSSRC)
       QUAL TYPE(*NAME) LEN(10) DFT(*LIBL) SPCVAL(*LIBL)
