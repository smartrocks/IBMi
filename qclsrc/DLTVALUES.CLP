/**********************************************************************/
/* DltValues - Clean up after using the SETVALUES command             */
/*                                                                    */
/* Purpose: To delete the VALUES and VALUESL1 work files from         */
/*          QTEMP and delete the corresponding overrides.             */
/*                                                                    */
/* Date       Pgmr     Scan  Proj   Description                       */
/* 2006-01-17 Keck           12091  Created                           */
/**********************************************************************/
pgm

monmsg CPF0000

             DLTF       FILE(QTEMP/VALUESL1)
             DLTF       FILE(QTEMP/VALUES)

             DLTOVR     FILE(VALUES)   LVL(*JOB)
             DLTOVR     FILE(VALUESL1) LVL(*JOB)

endpgm
