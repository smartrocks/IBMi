/*-----------------------------------------------------------------*/
/* IFSLIST - Create list of files in an IFS Folder                 */
/*                                                                 */
/* CPP: IFSLISTCL                                                  */
/*                                                                 */
/* Purpose: Prompt for IFS Folder.                                 */
/*          Create file QTEMP/IFSLIST.                             */
/*          Load IFSLIST file with files and directories.          */
/*                                                                 */
/* Date       Programmer  Project Scan Desc                        */
/* 2008-02-29 Keck        H279872      Re-Promoted to synch source */
/*-----------------------------------------------------------------*/
             CMD        PROMPT('IFS List')

             PARM       KWD(STRING) TYPE(*CHAR) LEN(256) MIN(1) +
                          CHOICE('Value') PROMPT('IFS Folder')
