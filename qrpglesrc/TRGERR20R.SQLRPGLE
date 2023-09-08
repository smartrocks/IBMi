      /copy QGPL/QSRVSRC,QILEHeader
     HBndDir('MFGBIND')
     HBndDir('TOOLBIND')
     HBnddir('QC2LE')
     F

      * - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- *
      *                                                                       *
      *    Thanks to Lloyd Bailey of Direct Response @ NBTY, Inc.             *
      *    for his help and inspiration designing this interface.             *
      *                                                                       *
      * - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- *

     Ftrgerr20d CF   E             Workstn Sfile(PrmptSfl:Sfindx)
     F                                     Infds(Dspfbk)
     Ftrgerrhl1 if   e           K Disk    InfDS(dstrgerrhl1)
     Ftrgerrhpf if   e             Disk    Rename(trgerrhr:trgerrhv)
     Fqddssrc   uf   e             Disk    Rename(qddssrc:ddsformat) UsrOpn
     F                                     ExtFile('QTEMP/QDDSSRC')
     F                                     ExtMbr(ddsMbr)
     Fqadspobj  if   e           K Disk    ExtFile(objFile) UsrOpn
      // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
     D
      // Execute Command (system) Subprocedure Variables 
     D System          PR            10I 0 ExtProc('system')
     D  CmdText                        *   Value Options(*String)
     D
     D ErrorCPF        S              7A   Import('_EXCP_MSGID')
     D ErrorFlag       S             10I 0 Inz(0)
     D
     D systemString    s            255a

      // Prototype Definitions 
      /Copy prdsrc/protype,fnAutUsrP
      /Define PROTOTYPE
      /Include nbtygpl/qsrvsrc,fnString
      /undefine PROTOTYPE

      // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
     D
     DPgmds           SDS
     D PgmName                 1     10a
     D UserId                254    263
     D JobNbr                264    269s 0
     D
     D dstrgerrhl1     DS
     D  dspfRRNd             397    400I 0
     D
     D svdspfrrn       s                   Like(dspfrrn)
     D
     D Dspfbk          DS
     D  cfkey                369    369
     D  Curspos              370    371B 0
     D  Min_Rrn              378    379I 0
     D  Num_Rcds             380    381I 0
     D
     D
     D objFile         s             21a   inz('QTEMP/QADSPOBJ')
     D ddsFile         s             21a
     D ddsMbr          s             10a
     D tmpMbr          s             10a
     D uniqueFound     s              5u 0 inz(0)
     D svFile          s             10a   inz
     D svlib           s             10a   inz
     D svmbr           s             10a   inz
     D
     D* Trigger Event
     D EventDS         ds
     D
     D pIndicators     S               *   Inz(%Addr(*In))
     D Indicators      DS                  Based(pIndicators)
     D  cmdPrompt...
     D                                 n   Overlay(Indicators:02)
     D  cmdExit...
     D                                 n   Overlay(Indicators:03)
     D  cmdSearch...
     D                                 n   Overlay(Indicators:04)
     D  cmdRefresh...
     D                                 n   Overlay(Indicators:05)
     D  cmdDBU...
     D                                 n   Overlay(Indicators:06)
     D  toggleInfo...
     D                                 n   Overlay(Indicators:10)
     D  toggleView...
     D                                 n   Overlay(Indicators:11)
     D  cmdCancel...
     D                                 n   Overlay(Indicators:12)
     D  EndOfSFL...
     D                                 n   Overlay(Indicators:26)
     D  PageDown...
     D                                 n   Overlay(Indicators:27)
     D  MsgSflEnd...
     D                                 n   Overlay(Indicators:90)
     D  viewToggle...
     D                                 n   Overlay(Indicators:30)
     D
     D Enter           c                   const(X'F1')
     D Help            c                   const(X'F3')
     D RollDwn         c                   const(X'F4')
     D RollUp          c                   const(X'F5')
     D Print           c                   const(X'F6')
     D
     D Edit            c                   const('2')
     D Delete          c                   const('4')
     D Copy            c                   const('3')
     D Display         c                   const('5')
     D WorkWith        c                   const('12')
     D
     D ReBuild         s              1n   Inz(*off)
     D Error           s              1n   Inz(*off)
     D AddMode         s              1n   Inz(*off)
     D ChgMode         s              1n   Inz(*off)
     D CopyMode        s              1n   Inz(*off)
     D
     D Svsfindx        s                   Like(sfindx)
     D lastSfIndx      s                   Like(sfindx)
     D pagesize        s                   Like(sfindx) Inz(16)
     D LoadCounter     s                   Like(sfindx)
     D
     D AlphaDate       s               d   DatFmt(*MDY)
     D strlen          s              4s 0
     D
     D TurnOff         s             20a   Inz('00000000000000000000')
     D
     D Green           c                   x'20'
     D Green_UL        c                   x'24'
     D Green_UL_RI     c                   x'25'
     D PR_Green        c                   x'A0'
     D White           c                   x'22'
     D White_UL        c                   x'26'
     D PR_White        c                   x'A2'
     D Blue            c                   x'3A'
     D Blue_RI         c                   x'3B'
     D Blue_UL         c                   x'3E'
     D
     D PR_Blue         c                   x'BA'
     D NonDisplay      c                   x'AF'
     D PR_Red          c                   X'A8'

     D errmsgds        ds
     D  dsemsg1                      51a   overlay(errmsgds)
     D  dsemsg2                      51a   overlay(errmsgds:*next)
     D  dsemsg3                      51a   overlay(errmsgds:*next)
     D  dsemsg4                      51a   overlay(errmsgds:*next)
     D  dsemsg5                      51a   overlay(errmsgds:*next)
     D

      //  Message Subfile 
     D clrpgmmsg       pr                  extpgm('QMHRMVPM')
     D   callstkent                  10a   const
     D   callstkcntr                 10i 0 const
     D   messagekey                   4a
     D   messageRmv                  10a
     D   errorcode                     *   const
     D
     D sndpgmmsg       pr                  extpgm('QMHSNDPM')
     D   messageid                    7a   const
     D   qualmsgf                    20a   const
     D   msgdata                    256a   const
     D   msgdtalen                   10i 0 const
     D   msgtype                     10a   const
     D   callstkent                  10a   const
     D   callstkcntr                 10i 0 const
     D   messagekey                   4a
     D   errorcode                     *   const
     D
     D   messageid     s              7a
     D   qualmsgf      s             20a
     D   msgdata       s            256a
     D   msgdtalen     s             10i 0
     D   msgtype       s             10a
     D   callstkent    s             10a
     D   callstkcntr   s             10i 0
     D   messagekey    s              4a
     D   messageRmv    s             10a
     D
      //  Error Messages for Error Subfile 
     D
     D validationError...
     D                 s               n   Inz(*off)
     D
     D sysString       s            255a
     D cancelled...
     D                 s               n   inz(*off)
     D modified...
     D                 s               n   inz(*off)
      //  Cursor Positioning for Errors    
     D
     D CursorPosition...
     D                 ds
     D  Crow                          3s 0 Inz(0)
     D  Ccol                          3s 0 Inz(0)
     D
     D pcdsStatus...
     D                 ds
     D openStatus      s              4s 0
     D counter         s              4s 0
     D sqlTable        s             21a
     D sqlStatement    s            256a

      // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
     C
      /FREE
        Exsr ProScreen;

        *inlr = *on;
        Return;

        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        // Process Screen
        // - - - - - - - - - - - - - - - - - - - - - - -

        Begsr Proscreen;

          Dow Not cmdExit;

            Dou not Error;
              Error = *off;
              cancelled = *off;

              If not cmdExit;

                // clear Indicators;
                Write CmdKey;
                Exfmt PrmptCtl;

                If (cmdExit);
                  leave;
                endif;

                If PageDown;
                  Exsr LoadSfl;
                  Iter;
                Endif;

                if (dccrrn > 0 and not cmdExit and not cmdCancel
                    and not toggleInfo and not cmdRefresh);

                  chain(e) dccrrn PrmptSfl;
                  if (%found and not %error);
                    exsr displayDetails;
                    sfindx = dccrrn;
                  endif;
                endif;

              Endif;
            Enddo;

          Enddo;

        Endsr;

        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        // Clear Prompt Subfile
        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -

        Begsr ClearSfl;

          *IN25  = *on;
          Write PrmptCtl;
          *IN25  = *off;
          *IN24  = *off;
          *IN26  = *off;
          Sfindx = 0;

          Setgt(e) *hival trgerrhr;

          //If not %equal;
          //  EndOfSFL = *on;
          //Endif;

          MsgSflEnd = *On;

        Endsr;


        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        // Load Prompt Subfile
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        Begsr LoadSfl;


          SfIndx = lastSfIndx;
          LoadCounter = 0;

          Read(E) trgerrhr;
          Dow not %eof(trgerrhl1) and not %error
            and loadCounter < pageSize;
            sfindx = sfindx + 1;
            LoadCounter = LoadCounter + 1;
            for counter = 1 to 60;
              if (%subst(errmsg:counter:1) < x'40');
                %subst(fld001:counter:1) = ' ';
              else;
                %subst(fld001:counter:1) = %subst(errmsg:counter:1);
              endif;
            endfor;
            dspfrrn = dspfrrnd;
            Write PrmptSfl;
            *in24 = *on;

            Read(E) trgerrhr;
          Enddo;

          ReBuild = *off;
          lastSfIndx = sfIndx;

          //if (Min_Rrn > 0);
          //  sfindx = Min_Rrn;
          //else;
          //  sfindx = 1;
          //endif;

          If %eof(trgerrhl1);
            EndOfSFL = *on;
          Endif;

        Endsr;
        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        //  Display Error Details Routine
        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -

        Begsr displayDetails;

          chain(e) dspfrrn trgerrhv;
          for counter = 1 to %len(%trim(errmsg));
            if (%subst(errmsg:counter:1) < x'40');
              %subst(errmsg:counter:1) = ' ';
            endif;
          endfor;
          errmsgds = errmsg;
          dow (not cmdExit and not cmdCancel and not cmdPrompt);
            exfmt details;

            if (cmdDBU);
              exsr createTable;

              //exsr crtDupObject;

            endif;

          enddo;

          clear cmdPrompt;

        Endsr;

        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        //  Add Routine
        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -

        Begsr AddRtn;

        Endsr;

        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        //  Edit Routine
        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -

        Begsr EditRtn;

        Endsr;

        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        //  Create Table
        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -

        Begsr CreateTable;
          if (svfile <> filename or svlib <> filelib or svmbr <> member);
            svfile = filename;
            svlib = filelib;
            svmbr = member;

            systemString = 'DLTF FILE(QTEMP/TRGTEMPPF)';
            errorFlag = system(%trim(systemString));

            sqlStatement = 'CREATE TABLE QTEMP/TRGTEMPPF LIKE ' +
            %trim(filelib) + '/' + %trim(filename);

      /End-Free
     C
     C/EXEC SQL
     C+ prepare stmnt from :sqlStatement
     C/end-exec
     C
     C/EXEC SQL
     C+ execute stmnt
     C/end-exec
     C
      /Free

          endif;

          systemString =
          'CPYF FROMFILE(TRGERRDPF) TOFILE(QTEMP/TRGTEMPPF)'  +
          ' MBROPT(*REPLACE) FROMRCD(' + %editc(errdrrn:'X') +
          ') TORCD(' + %editc(errdrrn + 1 :'X') + ') FMTOPT(*NOCHK)';
          errorFlag = system(%trim(systemString));

          if errorFlag = 0;
            systemString = '';
            systemString = 'DBU QTEMP/TRGTEMPPF DFTFMT(*MLT) DFTMOD(*DSP)'+
            ' CHGNAM(*NO) RVKADD(*YES) RVKCHG(*YES) RVKDLT(*YES)';
            errorFlag = system(%trim(systemString));
          endif;

        Endsr;

        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        //    Create Duplicate Object
        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -

        Begsr crtDupObject;

          // If we have a new lib/file.mbr, rebuild everything

          if (svfile <> filename or svlib <> filelib or svmbr <> member);
            svfile = filename;
            svlib = filelib;
            svmbr = member;

            // Delete the qtemp trigger data work file if it exists
            // If it doesn't exist, we don't care.
            systemString = '';
            systemString = 'DLTF FILE(QTEMP/TRGTEMPPF)';
            errorFlag = system(%trim(systemString));


            // retrieve the object description of the file in error.
            systemString = '';
            systemString = 'DSPOBJD OBJ(' +
            %trim(filelib) + '/' + %trim(filename) + ') OBJTYPE(*FILE) ' +
            'OUTPUT(*OUTFILE) OUTFILE(QTEMP/QADSPOBJ)';
            errorFlag = system(%trim(systemString));

            // Read the file to get the object source file
            open(e) qadspobj;
            read qlidobjd;
            ddsFile = %trim(odsrcl) + '/' + %trim(odsrcf);
            ddsMbr = %trim(odsrcm);
            close(e) qadspobj;

            // Copy the reords from the original source to our file.
            systemString = '';
            systemString = 'CPYF FROMFILE(' +
            %trim(ddsFile) + ') TOFILE(QTEMP/QDDSSRC)'  +
            ' FROMMBR(' + %trim(ddsMbr) + ') TOMBR( ' +
            %trim(ddsMbr) + ') MBROPT(*REPLACE) CRTFILE(*YES)';
            errorFlag = system(%trim(systemString));


            open(e) qddssrc;
            read ddsformat;
            dow (not %eof(qddssrc) and not %error);
              uniqueFound = %scan('UNIQUE':srcdta);
              if (uniqueFound > 0);
                delete ddsformat;
                // leave;
              endif;

              if (%subst(srcdta:17:1) = 'K');
                dow (not %eof(qddssrc) and not %error);
                  delete ddsformat;
                  read ddsformat;
                enddo;
              endif;
              read ddsformat;
            enddo;
            close(e) qddssrc;

            systemString = '';
            systemString =
            'CRTPF FILE(QTEMP/TRGTEMPPF) SRCFILE(QTEMP/QDDSSRC) SRCMBR(' +
            %trim(ddsMbr) + ')';
            errorFlag = system(%trim(systemString));

          endif;

          if errorFlag = 0;
            systemString = '';
            systemString =
            'CPYF FROMFILE(TRGERRDPF) TOFILE(QTEMP/TRGTEMPPF)'  +
            ' MBROPT(*REPLACE) FROMRCD(' + %editc(errdrrn:'X') +
            ') TORCD(' + %editc(errdrrn + 1 :'X') + ') FMTOPT(*NOCHK)';
            errorFlag = system(%trim(systemString));
          endif;

          if errorFlag = 0;
            systemString = '';
            systemString = 'DBU QTEMP/TRGTEMPPF DFTFMT(*MLT) DFTMOD(*DSP)'+
            ' CHGNAM(*NO) RVKADD(*YES) RVKCHG(*YES) RVKDLT(*YES)';
            errorFlag = system(%trim(systemString));
          endif;

        Endsr;

        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        // Edit all entry data
        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -

        Begsr ValidateData;


          MsgSflEnd = *On;

        Endsr;

        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        Begsr *Inzsr;

          viewToggle = *off;
          Exsr ClrMsgSfl;
          Exsr ClearSfl;
          Exsr LoadSfl;

        Endsr;


        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        //****************************************************************
        // Write Message Subfile Entry
        //****************************************************************

        Begsr WrtMsgSfl;

          // send message to program message queue

          messageid   = 'CPF9898';
          qualmsgf    = 'QCPFMSG   *LIBL     ';
          msgdtalen   = %len(%trim(msgdata));
          msgtype     = '*DIAG';
          callstkent  = '*';
          callstkcntr = 0;
          messagekey  = ' ';
          msgkey      = ' ';

          sndpgmmsg( messageid: qualmsgf:msgdata : msgdtalen: msgtype:
          callstkent: callstkcntr: messagekey:*null );


        Endsr;
        //*****************************************************************
        //  Clear Message Subfile
        //*****************************************************************
        Begsr ClrMsgSfl;

          mspgmq = '*';

          // clear program message queue

          callstkent  = '*';
          callstkcntr = 0;
          messagekey  = ' ';
          msgkey      = ' ';
          messageRmv  = '*ALL';
          clrpgmmsg(callstkent: callstkcntr: messagekey:
          messageRmv : *null );

          MsgSflEnd = *On;

        Endsr;

      /End-Free

