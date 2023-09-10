/*----------------------------------------------------------------*/
/* CVTDSPF - Convert DSPF38 --> DSPF Utility                      */
/*                                                                */
/* Date       Pgmr    Project  Task Scan Description              */
/* 2005-12-28 Keck      12050  1.00      Created                  */
/*----------------------------------------------------------------*/
pgm  (&QFromFile &QToFile &FromMbr &ToMbr)
             dcl        &QFromFile *char 20
             dcl        &QToFile   *char 20
             dcl        &FromMbr   *char 10
             dcl        &ToMbr     *char 10

dcl &Count     *dec  (10 0)
dcl &FromFile  *char 10
dcl &FromLib   *char 10
dcl &msg1      *char 50
dcl &msg2      *char 50
dcl &msg3      *char 50
dcl &return    *char 10
dcl &text      *char 50
dcl &ToFile    *char 10
dcl &ToLib     *char 10

addlible NBTYGPL
monmsg CPF0000

chgvar &FromFile %SubString(&QFromFile  1 10)
chgvar &FromLib  %SubString(&QFromFile 11 10)

chgvar &ToFile %SubString(&QToFile  1 10)
chgvar &ToLib  %SubString(&QToFile 11 10)


/************************/
/* Start of Validations */
/************************/


if ((&FromFile = &ToFile) *and (&FromLib = &toLib) *and (&FromMbr = &ToMbr)) +
   then(do)
   chgvar &msg1 'The From and To members can not be the same.'
   chgvar &msg2 'Please specify a different target member.'
   chgvar &msg3 ' '
   call winmsg (&msg1 &msg2 &msg3)
   return
enddo


CHKOBJ OBJ(&FROMLIB/&FROMFILE) OBJTYPE(*FILE) MBR(&FROMMBR)
monmsg CPF0000 exec(do)
   chgvar &msg1 ('Member:' *bcat &FromLib *tcat '/' *tcat &FromFile +
                          *bcat &FromMbr)
   chgvar &msg2 'could not be found.  Please check.'
   chgvar &msg3 ' '
   call winmsg (&msg1 &msg2 &msg3)
   return
enddo


CHKOBJ OBJ(&TOLIB/&TOFILE) OBJTYPE(*FILE) MBR(*NONE)
monmsg CPF0000 exec(do)
   chgvar &msg1 ('Target source file:' *bcat &ToLib *tcat '/' *tcat &ToFile)
   chgvar &msg2 'could not be found.  Please check.'
   chgvar &msg3 ' '
   call winmsg (&msg1 &msg2 &msg3)
   return
enddo


CHKOBJ OBJ(qtemp/SRCIN) OBJTYPE(*FILE) MBR(*NONE)
monmsg CPF0000 exec(goto TagA)

   chgvar &msg1 'Work files SRCIN and or SRCOUT found in QTEMP.'
   chgvar &msg2 'Please delete these files and try again.'
   chgvar &msg3 ' '
   call winmsg (&msg1 &msg2 &msg3)
   return

TagA:


CHKOBJ OBJ(qtemp/SRCOUT) OBJTYPE(*FILE) MBR(*NONE)
monmsg CPF0000 exec(goto TagB)

   chgvar &msg1 'Work files SRCIN and or SRCOUT found in QTEMP.'
   chgvar &msg2 'Please delete these files and try again.'
   chgvar &msg3 ' '
   call winmsg (&msg1 &msg2 &msg3)
   return

TagB:


CHKOBJ OBJ(&TOLIB/&TOFILE) OBJTYPE(*FILE) MBR(&TOMBR)
monmsg CPF0000 exec(goto TagC)

   chgvar &msg1 ('To Member:' *bcat &ToMbr *bcat 'already exists.')
   chgvar &msg2 'Member Not Copied.'
   chgvar &msg3 ' '
   call winmsg (&msg1 &msg2 &msg3)
   return

tagC:

RTVMBRD FILE(&FROMLIB/&FROMFILE) MBR(&FROMMBR) TEXT(&text) +
             NBRCURRCD(&COUNT)
if (&count = 0) then(do)
   chgvar &msg1 ('Member:' *bcat &FromMbr *bcat 'is empty.')
   chgvar &msg2 'Member Not Copied.'
   chgvar &msg3 ' '
   call winmsg (&msg1 &msg2 &msg3)
   return
enddo


/**********************/
/* End of Validations */
/**********************/


CRTSRCPF FILE(qtemp/SRCIN)  TEXT('Used by the CRTDSPF command')
CRTSRCPF FILE(qtemp/SRCOUT) TEXT('Used by the CRTDSPF command')

CPYSRCF FROMFILE(&FROMLIB/&FROMFILE) TOFILE(QTEMP/SRCIN) FROMMBR(&FROMMBR)

ADDPFM FILE(QTEMP/SRCOUT) MBR(&TOMBR) TEXT(&TEXT) SRCTYPE(DSPF)

OVRDBF FILE(SRCIN) TOFILE(QTEMP/SRCIN) MBR(&FROMMBR) +
             OVRSCOPE(*CALLLVL)

OVRDBF FILE(SRCOUT) TOFILE(QTEMP/SRCOUT) MBR(&ToMBR) +
             OVRSCOPE(*CALLLVL)

call CvtDspf1 &return

             DLTOVR     FILE(SRCIN)  LVL(*)
             DLTOVR     FILE(SRCout) LVL(*)

if (&return = ' ') then(do)
   ADDPFM FILE(&ToLib/&ToFile) MBR(&TOMBR) TEXT(&TEXT) SRCTYPE(DSPF)
   CPYSRCF FROMFILE(QTEMP/SRCOUT) TOFILE(&ToLib/&ToFile) FROMMBR(&ToMbr)
   chgvar &msg1 ('Member:' *bcat &FromMbr *bcat 'converted successfully.')
   SNDPGMMSG MSGID(CPF9897) MSGF(QCPFMSG) MSGDTA(&msg1) MSGTYPE(*COMP)
enddo
else do
   chgvar &msg1 ('Member:' *bcat &FromMbr *bcat '*** Conversion FAILED.***')
   SNDPGMMSG MSGID(CPF9897) MSGF(QCPFMSG) MSGDTA(&msg1) MSGTYPE(*COMP)
enddo

dltf qtemp/srcin
dltf qtemp/srcout

endpgm
