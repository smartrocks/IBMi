/**********************************************************************/
/* SetValuesC - Set Temporary Work Values in file QTEMP/VALUES        */
/*                                                                    */
/* Purpose: To enable queries created via WRKQRY to run with          */
/*          variable date periods and other variable data.            */
/*                                                                    */
/* Usage: 1. Create a Query using WRKQRY which has selection          */
/*           criteria such as period start and end dates.             */
/*        2. Modify the query to refer to file *LIBL/VALUES           */
/*        3. Modify the query to JOIN to VALUES based on a            */
/*           "FUNCTION CODE" of your choosing.                        */
/*        4. Modify the query's selection criteria to use             */
/*           values from the VALUES file instead of                   */
/*           hard coded values.                                       */
/*        5. Create a CLP which calls this program (SetValuesC) which */
/*           will create the work file VALUES in QTEMP and add/update */
/*           your values to the record identified by your             */
/*           FUNCTION CODE.                                           */
/*        7. In your CLP, after the call to SetValuesC (this program) */
/*           then run your query via the RUNQRY command.              */
/*        8. Congratulations, you have automated your query.          */
/*                                                                    */
/* Date       Pgmr     Scan  Proj   Description                       */
/* 2005-06-10 Keck           11594  Created                           */
/**********************************************************************/
pgm (&Function &sDateN &eDateN &sDateISO &eDateISO &String &Number)
dcl &Function *char 15
dcl &sDateN   *dec (9 0)  /* Start Date - Should only be digits */
dcl &eDateN   *dec (9 0)  /* End   Date - Should only be digits */
dcl &sDateISO *char 10    /* Start Date *ISO CCYY-MM-DD         */
dcl &eDateISO *char 10    /* End   Date *ISO CCYY-MM-DD         */
dcl &String   *char 30
dcl &Number   *dec (15 5) /* Should only contain digits         */

/*************************/
/* QTEMP to top of *LIBL */
/*************************/
rmvlible qtemp
monmsg CPF0000
addlible qtemp
monmsg CPF0000

/************************************/
/* Create VALUES work file in QTEMP */
/************************************/
CHKOBJ     OBJ(QTEMP/VALUES) OBJTYPE(*FILE)
MONMSG     MSGID(CPF0000) exec(do)
             CRTPF      FILE(QTEMP/VALUES) SRCFILE(NBTYGPL/QDDSSRC) +
                          OPTION(*NOSRC *NOLIST)
enddo

CHKOBJ     OBJ(QTEMP/VALUESL1) OBJTYPE(*FILE)
MONMSG     MSGID(CPF0000) exec(do)
             CRTLF      FILE(QTEMP/VALUESL1) +
                          SRCFILE(NBTYGPL/QDDSSRC) OPTION(*NOSRC +
                          *NOLIST)
enddo

/*********************************************************/
/* Add/Edit the work file values for given Function Code */
/*********************************************************/
             OVRDBF     FILE(VALUES) TOFILE(QTEMP/VALUES) +
                          OVRSCOPE(*JOB)
             OVRDBF     FILE(VALUESL1) TOFILE(QTEMP/VALUESL1) +
                          OVRSCOPE(*JOB)

call SetValues (&Function +
                &sDateN   +
                &eDateN   +
                &sDateISO +
                &eDateISO +
                &String   +
                &Number)

endpgm
