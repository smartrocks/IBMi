             CMD        PROMPT('Set Values Utility')

             PARM       KWD(FUNCTION) TYPE(*CHAR) LEN(15) MIN(1) +
                          CHOICE('Value') PROMPT('Function ID')

             PARM       KWD(SDATE) TYPE(*DEC) LEN(9) MIN(0) +
                          CHOICE('Date, *zero') PROMPT('Numeric +
                          Start Date (any form)')

             PARM       KWD(EDATE) TYPE(*DEC) LEN(9) MIN(0) +
                          CHOICE('Date, *zero') PROMPT('Numeric End +
                          Date   (any form)')

             PARM       KWD(SDATEISO) TYPE(*CHAR) LEN(10) MIN(0) +
                          CHOICE('Date, *blanks') PROMPT('ISO Start +
                          Date    (CCYY-MM-DD)')

             PARM       KWD(EDATEISO) TYPE(*CHAR) LEN(10) MIN(0) +
                          CHOICE('Date, *blanks') PROMPT('ISO End +
                          Date      (CCYY-MM-DD)')

             PARM       KWD(STRING) TYPE(*CHAR) LEN(30) MIN(0) +
                          CHOICE('Value') PROMPT('Any String')

             PARM       KWD(NUMBER) TYPE(*DEC) LEN(15 5) MIN(0) +
                          CHOICE('Number') PROMPT('Any Number')
