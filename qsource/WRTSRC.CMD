    CMD PROMPT('WRTSRC - Write a Source Stmt')

    PARM KWD(FILE) TYPE(Q1) PROMPT('File')

Q1: QUAL TYPE(*NAME) LEN(10)               

    QUAL TYPE(*NAME) LEN(10) DFT(*LIBL) +
     SPCVAL((*LIBL)) PROMPT('Library')

    PARM KWD(MBR) TYPE(*CHAR) LEN(10) PROMPT('Member')

    PARM KWD(STMT) TYPE(*CHAR) LEN(80) PROMPT('Statement')
