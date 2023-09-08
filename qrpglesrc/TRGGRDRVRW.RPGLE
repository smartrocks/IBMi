     h dftactgrp(*no) actgrp('QILE')
     h option(*srcstmt:*nodebugio)
     HBnddir('QC2LE':'TOOLBIND')

     Ftrgemsgpf if   e           k Disk    Usropn
     Ftrgdrvl01 if   e           k Disk
     Ftrgdrvxl01if   e           k Disk

      * // Execute Command (system) Subprocedure Variables 
     D System          PR            10I 0 ExtProc('system')
     D  CmdText                        *   Value Options(*String)
     D
     D CallerID        PR            10
     D
     D RtvSysName      PR            10I 0
     D   SystemName                   8A
     D
     D #RtvSrlNbr      PR             8a

     D ErrorCPF        S              7A   Import('_EXCP_MSGID')
     D ErrorFlag       S             10I 0 Inz(0)
     D
     D SystemString    S           2048a   Inz
     D dstdText        c                   Const('Trigger Program DSTDText')
     D mfgGroup        c                   Const('LyndonTrahan@nbty.com')
     D subjectText     c                   Const('Trigger Program Error')
     D longMessage     s           1948a
     D
     d emsg            s             78    dim(9) ctdata perrcd(1)
     d
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

      * // -------------------------------------------------

     d TriggerPgm      pr                  extpgm('TRGGRDRVRW')
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


      /free
        callingProgram = callerID();
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
          if RtvSysName(systemName) < 0;
            clear systemName;
          endif;
          serialNumber = #RtvSrlNbr();

          longMessage = %trim(eMsg(1)) +
          %trim(thisProgram) + %trim(eMsg(2)) + ' ' +
          %trim(trgBuffer.Library) + '/' +
          %trim(trgBuffer.File) + %trim(eMsg(3)) +
          ' ' + %trim(eMsg(4)) + ' ' +
          %trim(trgPgmName) + %trim(eMsg(5)) + x'15';
          select;
          when (status = '00211');
            longMessage = %trim(longMessage) + %trim(eMsg(7));
          when (status = '00202');
            longMessage = %trim(longMessage) + %trim(eMsg(8));
          other;
            longMessage = %trim(longMessage) +
            %trim(errorMsg) + '(' +
            ' ' + status + ').';
          endsl;
          // longMessage = %trim(longMessage) + x'15' +
          // %trim(errorMsg);

          longMessage = %trim(longMessage)  + x'15' + x'15' + x'15'+
          'System Name . .: ' + %trim(systemName) + x'15'  +
          'Serial Number .: ' + %trim(serialNumber) + x'15' + x'15' +
          'Calling Program: ' + callingProgram + x'15' +
          'Triggered File : ' + TrgBuffer.File + x'15' +
          'Library . . . .: ' + TrgBuffer.Library + x'15' +
          'Member Name . .: ' + TrgBuffer.Member  + x'15' +
          'Event Code  . .: ' +
          EventArray(%int(TrgBuffer.Event))  + x'15' +
          'Trgger Time . .: ' +
          TimeArray(%int(TrgBuffer.Time))  + x'15' +
          'Commit Level  .: ' + TrgBuffer.CommitLockLev +
          x'15' + x'15'  + %trim(emsg(6)) + x'15' + x'15';

          if (emsggrp1 <> ' ' or emsggrp2 <> ' ');
            open(E) trgemsgpf;
            if (not %error);
              if (emsggrp1 <> ' ');
                setll(e) (emsggrp1) trgemsgr;
                if (%equal and not %error);
                  reade(e) (emsggrp1) trgemsgr;
                  dow (%found and not %eof and not %error);
                    systemString = 'SNDDST TYPE(*LMSG) TOINTNET((' +
                    %trim(temail) + '))'  + ' DSTD(''' + %trim(thisProgram) +
                    ''') LONGMSG(''' + %trim(longMessage) + ''')' +
                    ' SUBJECT(''' + %trim(subjectText) + ''')' +
                    ' IMPORTANCE(*HIGH)' ;
                    errorFlag = system(systemString);
                    reade(e) (emsggrp1) trgemsgr;
                  enddo;
                endif;
              endif;
              if (emsggrp2 <> ' ');
                setll(e) (emsggrp2) trgemsgr;
                if (%equal and not %error);
                  reade(e) (emsggrp2) trgemsgr;
                  dow (%found and not %eof and not %error);
                    systemString = 'SNDDST TYPE(*LMSG) TOINTNET((' +
                    %trim(temail) + '))'  + ' DSTD(''' + %trim(thisProgram) +
                    ''') LONGMSG(''' + %trim(longMessage) + ''')' +
                    ' SUBJECT(''' + %trim(subjectText) + ''')' +
                    ' IMPORTANCE(*HIGH)' ;
                    errorFlag = system(systemString);
                    reade(e) (emsggrp2) trgemsgr;
                  enddo;
                endif;
              endif;
            endif;
          endif;


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
