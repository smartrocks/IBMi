     h option(*srcstmt:*nodebugio)
     HBnddir('QC2LE':'TOOLBIND')
     Hdftactgrp(*no) actgrp('QILE')

      **************************************************************************
      * Description: This program is a clone of NBTYGPL/TRGGRDRVR. This version
      *              handles the ability to retrieve the calling program
      *              correctly when it is a RPGIII program
      *
      * Programmer:  Lloyd Bailey
      * Date:        March 28, 2008
      **************************************************************************
      **************************************************************************
      * MODIFICATIONS:
      * -------------
      * Date      Pgmr       MOD   Reasons
      * --------  ---------  ----  ---------------------------------------------
      *
      **************************************************************************

     Ftrgerrhpf if a e             Disk    Usropn
     Ftrgerrdpf if a e             Disk    Usropn infds(detfds)
     Ftrgdrvl01 if   e           k Disk
     Ftrgdrvxl01if   e           k Disk

      *‚// Execute Command (system)†Subprocedure Variables‚
     D System          PR            10I 0 ExtProc('system')
     D  CmdText                        *   Value Options(*String)
     D
     D RtvSysName      PR            10I 0
     D   SystemName                   8A
     D
     D getPPgmCL       pr                  extpgm('GETPPGMCL')
     D  called                       10
     D  caller                       10

     Ddetfds           ds
     D dbrrn                 397    400i 0
     D
     D #RtvSrlNbr      PR             8a
     D string          s            512a
     D ErrorCPF        S              7A   Import('_EXCP_MSGID')
     D ErrorFlag       S             10I 0 Inz(0)
     D
     D SystemString    S           2048a   Inz
     D trgMsgId        s              5s 0 Inz(300)

      * Trigger Event
     d EventDS         ds
     d EventData                     24a   inz('InsertDeleteUpdateRead')
     d EventArray                     6a   dim(4) Overlay(EventDS)
     d

      * Trigger Time
     d TimeDS          ds
     d TimeData                      24a   inz('After Before')
     d TimeArray                      6a   dim(2) Overlay(TimeDS)
      * System API error code

      /Copy QSysInc/QRPGLESRC,Qusec
      /Include prdsrc/protype,fnrtvppgm

      * Type definition for the RCVM0200 format

     D RCVM0200        DS           120
     D  Program              111    120

      * Program message parameters

     D Pm_MsgId        S              7    Inz(*BLANKS)
     D Pm_MsgF         S             20    Inz(*BLANKS)
     D Pm_MsgDta       S             12    Inz('Who are you?')
     D Pm_Length       S              9B 0
     D Pm_MType        S             10    Inz('*INFO')
     D Pm_MKey         S              4    Inz(*BLANKS)
     D Pm_CSEntry      S             10    Inz('*')
     D Pm_Counter      S              9B 0 Inz(5)

     D Pm_Format       S              8    Inz('RCVM0200')
     D Pm_Wait         S              9B 0 Inz(0)
     D Pm_Action       S             10    Inz('*REMOVE')

      *‚// -------------------------------------------------

     d TriggerPgm      pr                  extpgm('TRGGRDRVR')
     d  TrgBuffer                          likeds(TrgInfo)
     d  TrgBufferLen                 10i 0

     d TriggerPgm      pi
     d  TrgBuffer                          likeds(TrgInfo)
     d  TrgBufferLen                 10i 0

     d ProcessPgm      pr                  extpgm(trgPgmName)
     d  TrgBuffer                          likeds(TrgInfo)
     d  TrgBufferLen                 10i 0
     d  trgCallingPgm                10a
     d  trgUserId                    10a
     d  trgErrorId                    5a
     d  trgErrorMsg                 255a
     d
     d EmailPgm        pr                  extpgm('TRGERR10R')
     d  TrgBuffer                          likeds(TrgInfo)
     d  TrgBufferLen                 10i 0
     d  TrgCallingPgm                10a
     d  TrgUserId                    10a
     d  TrgErrorId                    5a
     d  TrgErrorMsg                 255a
     d  trgSysName                   10a
     d  trgDrvrName                  10a
     d  trgpgmName                   21a
     d  trgerrorid                    7s 0
     d  trgemailgrp1                 10a
     d  trgemailgrp2                 10a

      * Trigger Buffer
     d TrgInfo         ds                  qualified
     d  File                         10
     d  Library                      10
     d  Member                       10
     d  Event                         1
     d  Time                          1
     d  CommitLockLev                 1
     d                                3
     d  CCSID                        10i 0
     d  RRN                          10i 0
     d                                4
     d  BefRecOffset                 10i 0
     d  BefRecLen                    10i 0
     d  BefNullOffset                10i 0
     d  BefNullLen                   10i 0
     d  AftRecOffset                 10i 0
     d  AftRecLen                    10i 0
     d  AftNullOffset                10i 0
     d  AftNullLen                   10i 0
     d
     D trgPgmName...
     D                 s             21a   Inz
     D
     D exceptionFound  s               n
     D position        s              4s 0
     D
     D exceptionProgram...
     D                 s             10a   Inz
     D
     D                 ds
     D callingProgram                10a   Inz
     D   cpPrefix                     2a   Overlay(callingProgram)
     D thisProgram     s             10a   Inz
     D systemName      s             10a   Inz
     D serialNumber    s              8a   Inz
     D status          s              5a   Inz
     D errorMsg        s            255a   Inz
     D
     DPgmds           SDS
     D PgmName                 1     10a
     D UserId                254    263
     D JobNbr                264    269s 0
     D
     D trgerrorID      s              7s 0    DTAARA('TRGERRID')
     D
     D beforeptr       s               *
     D beforeds        ds          8192       based(beforeptr)
     D
     D afterptr        s               *
     D afterds         ds          8192       based(afterptr)
     D
     d emsg            s             78    dim(9) ctdata perrcd(1)
     d thisPgmName     s                   like(pgmName)


      /free
        // callingProgram = fnRtvPPgm(1);
        thisPgmName = pgmName;
        getPPgmCL(thisPgmName: callingProgram);
        exsr getTriggerProgram;
        if (trgPgmName <> ' ');
          monitor;
            ProcessPgm(TrgBuffer:TrgBufferLen:callingProgram:userID:status:
            errorMsg);
            if (status <> '     ');
              exsr sendEmail;
            endif;
          on-error;
            if (status = '     ');
              status = %editc(%status:'X');
            endif;
            exsr sendEmail;
          endmon;
        endif;

        *inlr = *on;
        return;

        //-------------------------------------------------------
        // Determine if the data should be forwarded
        //-------------------------------------------------------

        Begsr getTriggerProgram;

          clear trgPgmName;
          clear exceptionProgram;

          exceptionFound = *off;
          exsr checkExceptionFile;
          if (not exceptionFound);
            exsr checkProcessFile;
          endif;

        Endsr;

        //-------------------------------------------------------
        // Retrieve the trigger program to call
        // Read file from most to least specific key lists
        //-------------------------------------------------------

        Begsr checkProcessFile;

          // Try Key = File:Library:Event Code

          setll(e) (TrgBuffer.File:TrgBuffer.Library:TrgBuffer.Event)
          trgdrvr;
          if (%equal and not %error);
            reade(e) (TrgBuffer.File:TrgBuffer.Library:TrgBuffer.Event)
            trgdrvr;
            trgPgmName = %trim(pgmlib) + '/' + %trim(pgmnam);
          else;

            // Try Key = File:*LIBL:Event Code

            setll(e) (TrgBuffer.File:'*LIBL':TrgBuffer.Event) trgdrvr;
            if (%equal and not %error);
              reade(e) (TrgBuffer.File:'*LIBL':TrgBuffer.Event)
              trgdrvr;
              trgPgmName = %trim(pgmnam);
            else;

              // Try Key = File:Library:*ANY

              setll(e) (TrgBuffer.File:TrgBuffer.Library:'5') trgdrvr;
              if (%equal and not %error);
                reade(e) (TrgBuffer.File:TrgBuffer.Library:'5')
                trgdrvr;
                trgPgmName = %trim(pgmlib) + '/' + %trim(pgmnam);
              else;

                // Try Key = File:*LIBL:*ANY

                setll(e) (TrgBuffer.File:'*LIBL':'5') trgdrvr;
                if (%equal and not %error);
                  reade(e) (TrgBuffer.File:'*LIBL':'5')
                  trgdrvr;
                  trgPgmName = %trim(pgmlib) + '/' + %trim(pgmnam);
                endif;
              endif;
            endif;
          endif;

        Endsr;

        //-------------------------------------------------------
        // See if calling program is in Exception file
        //-------------------------------------------------------

        Begsr checkExceptionFile;

          // Try Key = File:Library

          setll(e) (TrgBuffer.File:TrgBuffer.Library) trgdrvxr;
          if (%equal and not %error);
            reade(e) (TrgBuffer.File:TrgBuffer.Library) trgdrvxr;
            dow (not %eof and not exceptionFound);
              exsr checkExceptionName;
              reade(e) (TrgBuffer.File:TrgBuffer.Library) trgdrvxr;
            enddo;
          endif;

          // Try Key = File:*LIBL

          if (not exceptionFound);
            setll(e) (TrgBuffer.File:'*LIBL') trgdrvxr;
            if (%equal and not %error);
              reade(e) (TrgBuffer.File:'*LIBL') trgdrvxr;
              dow (not %eof and not exceptionFound);
                exsr checkExceptionName;
                reade(e) (TrgBuffer.File:'*LIBL') trgdrvxr;
              enddo;
            endif;
          endif;

        Endsr;

        //-------------------------------------------------------
        // check if calling program fits exception rule
        //-------------------------------------------------------

        Begsr checkExceptionName;

          if (callingProgram = xpgmnam);
            exceptionFound = *on;
            leavesr;
          endif;

          position = %scan('*':xpgmnam);
          if (position > 0);
            if ((%subst(callingProgram:1:position -1)) =
              (%subst(xpgmnam:1:position -1)));
              exceptionFound = *on;
            endif;
          endif;

        Endsr;

        //-------------------------------------------------------
        // Send e-mail if trigger program is not found or error
        //-------------------------------------------------------

        Begsr SendEmail;

          thisProgram = fnrtvppgm(0);
          if (rtvsysname(systemname) < 0);
            clear systemname;
          endif;

          beforeptr = %ADDR(TrgBuffer) + TrgBuffer.BefRecOffset;
          afterptr = %ADDR(TrgBuffer) + TrgBuffer.AftRecOffset;

          in *lock trgerrorID;
            trgerrorID = trgerrorID + 1;
          out trgerrorID;
          errorid = trgerrorid;

          open(e) trgerrhpf;
          if (not %error);
            clear trgerrhr;
            errorid = trgerrorid;
            filename = TrgBuffer.File;
            filelib  =  TrgBuffer.Library;
            member   = TrgBuffer.Member;
            event    = TrgBuffer.Event;
            eventtim = TrgBuffer.Time;
            cmtlvl   = TrgBuffer.CommitLockLev;
            callpgm  = callingProgram;
            calluser = userID;
            errsts   = status;
            sysname  = systemname;
            drvrname = thisProgram;
            errpgm   = trgpgmname;
          select;
          when (errsts = '00211');
            errmsg = %trim(errmsg) + %trim(eMsg(7));
          when (errsts = '00202');
            errmsg = %trim(errmsg) + %trim(eMsg(8));
          other;
            errmsg = %trim(errmsg) +
            %trim(errorMsg) + '(' +
            ' ' + errsts + ').';
          endsl;
            open(e) trgerrdpf;
            imgdata = %subst(beforeds:1:TrgBuffer.BefRecLen);
            write(e) trgerrdr;
            errdrrn = dbrrn;
            write(e) trgerrhr;
            imgdata = %subst(afterds:1:TrgBuffer.AftRecLen);
            write(e) trgerrdr;
            close(e) trgerrhpf;
            close(e) trgerrdpf;
          endif;


          // Submit the job that sends the emails
          string = 'SBMJOB CMD(CALL TRGERR10R (''' +
          TrgBuffer.File    + ''' ''' +
          TrgBuffer.Library + ''' ''' +
          TrgBuffer.Member  + ''' ''' +
          TrgBuffer.Event   + ''' ''' +
          TrgBuffer.Time    + ''' ''' +
          TrgBuffer.CommitLockLev + ''' ''' +
          callingProgram    + ''' ''' +
          userID            + ''' ''' +
          status            + ''' ''' +
          errMsg            + ''' ''' +
          systemname        + ''' ''' +
          thisProgram       + ''' ''' +
          trgpgmname        + ''' ''' +
          %editc(errorid:'X') + ''' ''' +
          emsggrp1          + ''' ''' +
          emsggrp2  + ''')) JOB(TRGERROR) USER(SYSADMMFG) MSGQ(*NONE)';

          errorFlag = system(%trim(string));

        Endsr;

      /end-free
**
This trigger driver program (
) is attached to
.  This program was attempting to forward the trigger
 information to program
, but, the attempt failed because of the following.
This is an automated message. Please do not reply to this e-mail.
Error calling program or procedure (return code 00211).
Called program or procedure failed (return code 00202).
The program ended with an undetermined error (return code
