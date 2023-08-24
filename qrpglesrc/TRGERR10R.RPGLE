     h dftactgrp(*no) actgrp('QILE')
     h option(*srcstmt:*nodebugio)
     HBnddir('QC2LE':'TOOLBIND')
     H alwnull(*USRCTL)

     Ftrgemsgpf if   e           k Disk    Usropn

      *// Execute Command (system)†Subprocedure Variables
     D System          PR            10I 0 ExtProc('system')
     D  CmdText                        *   Value Options(*String)
     D

     D ErrorCPF        S              7A   Import('_EXCP_MSGID')
     D ErrorFlag       S             10I 0 Inz(0)
     D
     D SystemString    S           2048a   Inz
     D dstdText        c                   Const('Trigger Program DSTDText')
     D mfgGroup        c                   Const('LyndonTrahan@nbty.com')
     D subjectText     s             80a   Inz('Trigger Error')
     D longMessage     s           1948a
     D
     d emsg            s             78    dim(9) ctdata perrcd(1)
     d htmlhead        s             80    dim(10) ctdata perrcd(1)
     d
     D trgMsgId        s              5s 0 Inz(300)
     D
     d TriggerPgm      pr                  extpgm('TRGERR10R')
     d  File                         10
     d  Library                      10
     d  Member                       10
     d  Event                         1
     d  Time                          1
     d  CommitLockLev                 1
     d  TrgCallingPgm                10a
     d  TrgUserId                    10a
     d  TrgErrorId                    5a
     d  TrgErrorMsg                 255a
     d  trgSysName                   10a
     d  trgDrvrName                  10a
     d  trgpgmName                   21a
     d  trgfileid                     7s 0
     d  trgemailgrp1                 10a
     d  trgemailgrp2                 10a

     d TriggerPgm      pi
     d  File                         10
     d  Library                      10
     d  Member                       10
     d  Event                         1
     d  Time                          1
     d  CommitLockLev                 1
     d  TrgCallingPgm                10a
     d  TrgUserId                    10a
     d  TrgErrorId                    5a
     d  TrgErrorMsg                 255a
     d  trgSysName                   10a
     d  trgDrvrName                  10a
     d  trgpgmName                   21a
     d  trgfileid                     7s 0
     d  trgemailgrp1                 10a
     d  trgemailgrp2                 10a

      * Trigger Event
     d EventDS         ds
     d EventData                     24a   inz('InsertDeleteUpdateRead')
     d EventArray                     6a   dim(4) Overlay(EventDS)
     d

      * Trigger Time
     d TimeDS          ds
     d TimeData                      24a   inz('After Before')
     d TimeArray                      6a   dim(2) Overlay(TimeDS)

      *// -------------------------------------------------

      /free

        Longmessage = %trim(htmlhead(1)) + x'15' + x'15';
        longMessage = %trim(longMessage) + %trim(eMsg(1)) +
        %trim(trgDrvrName) + %trim(eMsg(2)) + ' ' +
        %trim(Library) + '/' +
        %trim(File) + %trim(eMsg(3)) +
        ' ' + %trim(eMsg(4)) + ' ' +
        %trim(trgPgmName) + %trim(eMsg(5)) + x'15';

        longMessage = %trim(longMessage) + %trim(TrgErrorMsg);

        longMessage = %trim(longMessage)  + x'15' + x'15' + x'15'+
        'Error Id Number: ' + %editc(trgfileid:'Z') + x'15' +
        'User ID        : ' + %trim(TrgUserId) + x'15' +
        'System Name . .: ' + %trim(trgsysname) + x'15'  +
        'Calling Program: ' + trgCallingPgm + x'15' +
        'Triggered File : ' + File + x'15' +
        'Library . . . .: ' + Library + x'15' +
        'Member Name . .: ' + Member  + x'15' +
        'Event Code  . .: ' +
        EventArray(%int(Event))  + x'15' +
        'Trgger Time . .: ' +
        TimeArray(%int(Time))  + x'15' +
        'Commit Level  .: ' + CommitLockLev +
        x'15' + x'15'  + %trim(emsg(6)) + x'15' + x'15';

        subjectText = %trim(subjectText) + ' - ' + %trim(library) +
        ' / ' + %trim(file) + ' - ' + 'ID # ' + %editc(trgfileid:'Z');

        if (trgemailgrp1 <> ' ' or trgemailgrp2 <> ' ');
          open(E) trgemsgpf;
          if (not %error);
            if (trgemailgrp1 <> ' ');
              setll(e) (trgemailgrp1) trgemsgr;
              if (%equal and not %error);
                reade(e) (trgemailgrp1) trgemsgr;
                dow (%found and not %eof and not %error);
                  systemString = 'SNDDST TYPE(*LMSG) TOINTNET((' +
                  %trim(temail) + '))'  + ' DSTD(''' + %trim(trgDrvrName) +
                  ''') LONGMSG(''' + %trim(longMessage) + ''')' +
                  ' SUBJECT(''' + %trim(subjectText) + ''')' +
                  ' IMPORTANCE(*HIGH)' ;
                  errorFlag = system(systemString);
                  reade(e) (trgemailgrp1) trgemsgr;
                enddo;
              endif;
            endif;
            if (trgemailgrp2 <> ' ');
              setll(e) (trgemailgrp2) trgemsgr;
              if (%equal and not %error);
                reade(e) (trgemailgrp2) trgemsgr;
                dow (%found and not %eof and not %error);
                  systemString = 'SNDDST TYPE(*LMSG) TOINTNET((' +
                  %trim(temail) + '))'  + ' DSTD(''' + %trim(trgDrvrName) +
                  ''') LONGMSG(''' + %trim(longMessage) + ''')' +
                  ' SUBJECT(''' + %trim(subjectText) + ''')' +
                  ' IMPORTANCE(*HIGH)' ;
                  errorFlag = system(systemString);
                  reade(e) (trgemailgrp2) trgemsgr;
                enddo;
              endif;
            endif;
          endif;
        endif;


        *inlr = *on;
        return;

      /end-free
**
This trigger driver program (
) is attached to
.  This program was attempting to forward the trigger
 information to program
, but, the attempt failed because of the following.
href=www.google.com
Error calling program or procedure (return code 00211).
Called program or procedure failed (return code 00202).
The program ended with an undetermined error (return code
**
AS/400 Trigger Error
