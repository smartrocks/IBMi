      /copy QGPL/QSRVSRC,QILEHeader
     HBndDir('MFGBIND')
     HBndDir('TOOLBIND')
     HBnddir('QC2LE')
     F
     Ftrgdef10d CF   E             Workstn
     F                                     Sfile(SflFmt:SfIndx)
     F                                     Infds(Dspfbk)
     Ftrgdefpf  uf a e           K Disk           Rename(trgdefr:trgdefp)
     Ftrgdefl2  if   e           K Disk    UsrOpn Rename(trgdefr:trgdef2)
     Ftrgdefl3  if   e           K Disk    UsrOpn Rename(trgdefr:trgdef3)
     Ftrgdefl4  if   e           K Disk    UsrOpn Rename(trgdefr:trgdef4)
     F
      // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
     D
      // Execute Command (system) Subprocedure Variables 
     D System          PR            10I 0 ExtProc('system')
     D  CmdText                        *   Value Options(*String)
     D
     D ErrorCPF        S              7A   Import('_EXCP_MSGID')
     D ErrorFlag       S             10I 0 Inz(0)
     D
     D systemString    S            256A

      // Prototype Definitions 
      /Copy prdsrc/protype,fnAutUsrP
      /Define PROTOTYPE
      /Include nbtygpl/qsrvsrc,fnString
      /undefine PROTOTYPE

     D addPFTrigger    pr                  extpgm('CHGTRG10R')
     D  passOper                      3a   Const
     D  passFile                     10a
     D  passFlib                     10a
     D  passTime                      7a
     D  passEvent                     7a
     D  passPgm                      10a   Options(*nopass)
     D  passPlib                     10a   Options(*nopass)
     D
     D rmvPFTrigger    pr                  extpgm('CHGTRG10R')
     D  passOper                      3a   Const
     D  passFile                     10a
     D  passFlib                     10a
     D  passTime                      7a
     D  passEvent                     7a

     D*--------------------------------------------------
     D* Procedure name: fnScan
     D* Purpose:        Use %scan as a procedure to return boolean
     D* Returns:
     D* Parameter:      paSearchArg => Search Argument
     D* Parameter:      paSourceString => Source String
     D*--------------------------------------------------
     D fnScan          PR              N
     D  paSearchArg                 255A   VALUE
     D paSourceString               255A   VALUE

     D
      // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
     D
     DPgmds           SDS
     D PgmName                 1     10a
     D UserId                254    263
     D JobNbr                264    269s 0
     D
     D Dspfbk          DS
     D  cfkey                369    369
     D  Curspos              370    371B 0
     D  Min_Rrn              378    379I 0
     D  Num_Rcds             380    381I 0
     D
     D lastSubFileRRN...
     D                 s                   like(Num_Rcds)
     D saveSubFileRRN...
     D                 s                   like(Min_Rrn)
     D currentSubFileRRN...
     D                 s                   like(Min_Rrn)
     D foundSearchString...
     D                 s               n   inz(*off)
     D SearchStringFound...
     D                 s               n   inz(*off)
     D leaveSearch...
     D                 s               n   inz(*off)
     D saveSearchString...
     D                 s                   like(dssrchstr)
     D
     D saveFields...
     D               e ds                  extName(trgdefpf)
     D                                     prefix(h)
     D screenFields...
     D               e ds                  extName(trgdefpf)
     D                                     prefix(ds)
     D
     D hiddenFields...
     D               e ds                  extName(trgdefpf)
     D                                     prefix(hd)
     D
     D outputFields...
     D               e ds                  extName(trgdefpf)
     D
     D screenAttributes...
     D                 ds
     D  datdstat                      1a   Inz(PR_Green)
     D  datdfile                      1a   Inz(PR_Green)
     D  datdflib                      1a   Inz(PR_Green)
     D  datdtime                      1a   Inz(PR_Green)
     D  datdevnt                      1a   Inz(PR_Green)
     D  datdpgm                       1a   Inz(PR_Green)
     D  datdplib                      1a   Inz(PR_Green)
     D  daConfirm                     1a   Inz(NonDisplay)
     D  daHeader                      8a   overlay(screenAttributes:1)
     D
     D daProtect       ds                  likeds(screenAttributes)
     D                                     inz(*likeds)
     D daUpdate        ds                  likeds(screenAttributes)
     D                                     inz(*likeds)
     D daAdd           ds                  likeds(screenAttributes)
     D                                     inz(*likeds)
     D
     D
     D
     D damsgs          ds
     D   modMode                     15a   Inz(' ')
     D   headmsg                     50a   Inz(' ')
     D   footmsg                     35a   Inz(' ')
     D
     D addMsgs         ds                  likeds(damsgs)
     D edtMsgs         ds                  likeds(damsgs)
     D cpyMsgs         ds                  likeds(damsgs)
     D dltMsgs         ds                  likeds(damsgs)
     D
     D pIndicators     S               *   Inz(%Addr(*In))
     D Indicators      DS                  Based(pIndicators)
     D  cmdExit...
     D                                 n   Overlay(Indicators:03)
     D  cmdSearch...
     D                                 n   Overlay(Indicators:04)
     D  cmdRefresh...
     D                                 n   Overlay(Indicators:05)
     D  cmdAdd...
     D                                 n   Overlay(Indicators:06)
     D  cmdSort...
     D                                 n   Overlay(Indicators:11)
     D  cmdCancel...
     D                                 n   Overlay(Indicators:12)
     D  cmdScan...
     D                                 n   Overlay(Indicators:16)
     D  showActiveStatus...
     D                                 n   Overlay(Indicators:60)
     D  MsgSflEnd...
     D                                 n   Overlay(Indicators:90)
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
     D Addtrigger      c                   const('12')
     D RmvTrigger      c                   const('14')
     D WorkLocks       c                   const('16')
     D
     D
     D ReBuild         s              1n   Inz(*off)
     D Error           s              1n   Inz(*off)
     D AddMode         s              1n   Inz(*off)
     D ChgMode         s              1n   Inz(*off)
     D CopyMode        s              1n   Inz(*off)
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
     D
     D Svsfindx        s                   Like(sfindx)
     D sortView        ds             4
     D  sortRA                        1a   Dim(4)
     D  sortData                      4a   Inz('P234') overlay(sortView)
     D
     D  sortMode       s              1s 0 Inz(1)
     D
     D showKeyFlds     ds
     D  keyfld1                      10a   Inz(' ')
     D  keyfld2                      10a   Inz(' ')
     D  keyfld3                      10a   Inz(' ')
     D  keyfld4                      10a   Inz(' ')
     D
     D showKeyList     ds                  Qualified
     D  keyfld1                      10a   Inz(' ')
     D  keyfld2                      10a   Inz(' ')
     D  keyfld3                      10a   Inz(' ')
     D  keyfld4                      10a   Inz(' ')
     D
     D KeyListRa       ds                  Likeds(showKeyList) Dim(4)
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
     D errDuplicateRecord...
     D                 c                   'Duplicate record. Record already -
     D                                     exists for process'
     D
     D errNoChangesMade...
     D                 c                   'No changes have been made. Changes -
     D                                     must be made to create a unique -
     D                                     record'
     D
     D errBlankFile...
     D                 c                   'This is a required field. Please -
     D                                     enter a file name'
     D
     D errBlankflib...
     D                 c                   'This is a required field. Please -
     D                                     enter a file library'
     D
     D errBlankTime...
     D                 c                   'This is a required field. Please -
     D                                     enter a trigger time'
     D
     D errBlankEvent...
     D                 c                   'This is a required field. Please -
     D                                     enter a trigger event'
     D
     D errBlankPgm...
     D                 c                   'This is a required field. Please -
     D                                     enter a forward to program'
     D
     D errBlankPlib...
     D                 c                   'This is a required field. Please -
     D                                     enter a forward to program library'
     D
     D errInvalidTime...
     D                 c                   'This is not a valid value for -
     D                                     trigger time'
     D
     D errInvalidEvent...
     D                 c                   'This is not a valid value for -
     D                                     trigger event'
     D
     D errInvalidStatus...
     D                 c                   'This is not a valid value for -
     D                                     status'
     D
     D errConstraint...
     D                 c                   'Constraint Error. This record -
     D                                     can not be deleted'
     D
     D errInvalidOption...
     D                 c                   ' is not valid'
     D
     D errSearchFailed...
     D                 c                   ' was not found'
     D
     D errSubfileError...
     D                 c                   'Error accessing sub-file'
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
     D pcdstdfile      ds                  likeds(CursorPosition)
     D pcdstdflib      ds                  likeds(CursorPosition)
     D pcdstdtime      ds                  likeds(CursorPosition)
     D pcdstdevnt      ds                  likeds(CursorPosition)
     D pcdstdpgm       ds                  likeds(CursorPosition)
     D pcdstdplib      ds                  likeds(CursorPosition)
     D pcdstdstat      ds                  likeds(CursorPosition)
     D
     D
     D


      // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
     C
      /FREE
        Exsr ProSfl;

        *inlr = *on;
        Return;

        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        // Process Subfile
        // - - - - - - - - - - - - - - - - - - - - - - -

        Begsr Prosfl;

          Dow Not cmdExit;
            Exsr ClrMsgSfl;

            Dou not Error;
              Error = *off;
              cancelled = *off;

              Write CmdKey;
              Write MsgCtl;
              Exfmt Sflctl;

              If not cmdExit and not cmdCancel;

                If cfkey = Enter;
                  Exsr ClrMsgSfl;

                  Readc(E) Sflfmt;
                  Dow Not %eof(trgdef10d) and not %error;

                    *in80 = *off;
                    Select;
                    When %trim(dsopt) = Edit;
                      svsfindx = sfindx;
                      hiddenFields = saveFields;
                      screenFields = hiddenFields;
                      Exsr EditRtn;

                    When %trim(dsopt) = Delete;
                      hiddenFields = saveFields;
                      screenFields = hiddenFields;
                      svsfindx = 0;
                      Exsr DeleteRtn;

                    When %trim(dsopt) = Copy;
                      CopyMode = *on;
                      svsfindx = sfindx;
                      hiddenFields = saveFields;
                      screenFields = hiddenFields;
                      daMsgs = cpyMsgs;
                      fnCenter(modMode);
                      fnCenter(footMsg);
                      Exsr AddRtn;

                    When %trim(dsopt) = WorkLocks;
                      systemstring = 'WRKOBJLCK OBJ(' + %trim(tdflib) +
                      '/' + %trim(tdfile) + ') OBJTYPE(*FILE)';
                      errorflag = System(systemstring);

                    When %trim(dsopt) = addTrigger;
                      addPFTrigger('ADD':tdFile:tdFlib:tdTime:tdEvnt:
                      tdPgm:tdplib);
                      Rebuild = *on;

                    When %trim(dsopt) = rmvTrigger;
                      rmvPFTrigger('RMV':tdFile:tdFlib:tdTime:tdEvnt);
                      Rebuild = *on;

                    When %trim(dsopt) = '?';
                      exsr checkAttachedTriggers;
                      daactive = PR_Green;
                      Update sflfmt;

                    Other;
                      if dsopt > ' ';
                        msgData = 'Option ' + %trim(dsopt) + errInvalidOption;
                        Exsr WrtMsgSfl;
                        *in80 = *on;
                        error = *on;
                      endif;

                    Endsl;

                    cmdCancel = *off;

                    Chain SfIndx SflFmt;
                    if not *in80;
                      dsopt =  ' ';
                    endif;
                    Update sflfmt;

                    Readc(E) Sflfmt;
                  Enddo;

                Endif;

                If cmdAdd;
                  svsfindx = 0;
                  Clear screenFields;
                  Clear hiddenFields;
                  daMsgs = addMsgs;
                  fnCenter(modMode);
                  fnCenter(footMsg);
                  AddMode = *on;
                  Exsr AddRtn;
                Endif;

                If cmdRefresh;
                  showActiveStatus = not showActiveStatus;
                  Rebuild = *on;
                Endif;

                If cmdSort;
                  sortMode = sortmode + 1;
                  if (sortmode > %elem(sortRa));
                    sortmode = 1;
                  endif;
                  showKeyFlds = KeyListRa(sortMode);
                  Rebuild = *on;
                Endif;

                If (cmdScan and dssrchstr <> ' ');
                  exsr checkSearchString;
                  svsfindx = sfindx;
                Endif;

                If Rebuild = *on;
                  Exsr LoadSfl;
                Endif;

              Endif;
            Enddo;

          Enddo;

        Endsr;

        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        //  Add Routine
        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -

        Begsr AddRtn;

          Reset screenAttributes;
          Exsr ClrMsgSfl;
          cancelled = *off;
          daHeader = daAdd;

          dow (AddMode = *on or CopyMode = *on);

            Write MsgCtl;
            exfmt rcdFormat;

            if cmdExit or cmdCancel;
              AddMode = *off;
              CopyMode = *off;
              cancelled = *on;
              Leave;
            Endif;

            Exsr ValidateData;
            If not validationError;
              daHeader = daProtect;
              daConfirm = White;
              Write MsgCtl;
              Exfmt rcdFormat;
              If not cmdCancel and not cmdExit;
                Exsr ValidateData;
                If not validationError;
                  outputFields = screenFields;
                  tdcrtu = userid;
                  tdcrtd = %date();
                  tdcrtt = %time();
                  Write trgdefp;

                  // Write Audit Record;

                  Rebuild = *on;

                  AddMode = *off;
                  CopyMode = *off;

                endif;
              endif;
              daConfirm = nonDisplay;
              daHeader = daAdd;
            endif;

          enddo;

          crow = 0;
          ccol = 0;

        Endsr;


        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        //  Edit Routine
        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -

        Begsr EditRtn;

          Reset screenAttributes;
          daHeader = daUpdate;
          Exsr ClrMsgSfl;
          ChgMode = *on;
          daMsgs = edtMsgs;
          fnCenter(modMode);
          fnCenter(footMsg);
          daConfirm = nonDisplay;

          dow (ChgMode = *on and not cmdCancel and not cmdExit);

            Write MsgCtl;
            Exfmt rcdFormat;
            If not cmdCancel and not cmdExit;
              Exsr ValidateData;
              If not validationError;
                If (screenFields = hiddenFields);
                  ChgMode = *off;
                  Leave;
                Endif;
                daHeader = daProtect;
                daConfirm = white;
                Write MsgCtl;
                Exfmt rcdFormat;
                If not cmdCancel and not cmdExit;
                  Exsr ValidateData;
                  If not validationError;
                    Chain(E) (tdfile:tdflib:tdtime:tdevnt) trgdefp;
                    If %found(trgdefpf);
                      outputFields = screenFields;
                      tdcrtu = userid;
                      tdcrtd = %date();
                      tdcrtt = %time();

                      Update trgdefp;

                      // Write Audit Record;
                      Rebuild = *on;
                      ChgMode = *off;
                    endif;
                  endif;
                else;
                  daConfirm = nonDisplay;
                  daHeader = daUpdate;
                  cmdCancel = *off;
                endif;
              endif;
            else;
              daConfirm = nonDisplay;
              daHeader = daUpdate;
              ChgMode = *off;
            endif;
          enddo;

          crow = 0;
          ccol = 0;


        Endsr;

        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        //    Delete Routine
        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -

        Begsr DeleteRtn;

          reset screenAttributes;
          daHeader = daProtect;
          daMsgs = dltMsgs;
          fnCenter(modMode);
          fnCenter(footMsg);
          daConfirm = White;
          Exfmt rcdFormat;

          If cmdExit or cmdCancel;
            cancelled = *on;
            LeaveSr;
          Endif;


          Chain(E) (tdfile:tdflib:tdtime:tdevnt) trgdefp;
          If %found(trgdefpf) and not %error;
            // Write Audit Record;
            Delete trgdefp;
          Endif;

          Rebuild = *on;

        Endsr;

        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        // Edit all entry data
        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -

        Begsr ValidateData;

          validationError = *off;
          Exsr ClrMsgSfl;
          crow = 0;
          ccol = 0;
          Reset screenAttributes;
          reset cursorPosition;

          //  Validate File Name
          Select;
          When dstdfile =  ' ';
            datdfile = Green_UL_RI;
            validationError = *on;
            msgData = errBlankFile;
            Exsr WrtMsgSfl;
            If crow = 0;
              CursorPosition = pcdstdfile;
            Endif;
          Endsl;

          //  Validate File Library
          Select;
          When dstdflib =  ' ';
            datdflib = Green_UL_RI;
            validationError = *on;
            msgData = errBlankFlib;
            Exsr WrtMsgSfl;
            If crow = 0;
              CursorPosition = pcdstdflib;
            Endif;
          Endsl;

          //  Validate Program Name
          Select;
          When dstdpgm =  ' ';
            datdpgm = Green_UL_RI;
            validationError = *on;
            msgData = errBlankPgm;
            Exsr WrtMsgSfl;
            If crow = 0;
              CursorPosition = pcdstdpgm;
            Endif;
          Endsl;

          //  Validate Program Library
          Select;
          When dstdplib =  ' ';
            datdplib = Green_UL_RI;
            validationError = *on;
            msgData = errBlankplib;
            Exsr WrtMsgSfl;
            If crow = 0;
              CursorPosition = pcdstdplib;
            Endif;
          Endsl;

          //  Validate Trigger Time
          Select;
          When (dstdtime <> '*BEFORE' and dstdtime <> '*AFTER');
            datdtime = Green_UL_RI;
            validationError = *on;
            msgData = errInvalidTime;
            Exsr WrtMsgSfl;
            If crow = 0;
              CursorPosition = pcdstdtime;
            Endif;
          Endsl;

          //  Validate Trigger Event
          Select;
          When (dstdevnt <> '*UPDATE' and dstdevnt <> '*INSERT'
            and dstdevnt <> '*DELETE');
            datdevnt = Green_UL_RI;
            validationError = *on;
            msgData = errInvalidEvent;
            Exsr WrtMsgSfl;
            If crow = 0;
              CursorPosition = pcdstdevnt;
            Endif;
          Endsl;

          //  Validate Status
          Select;
          When (dstdstat <> 'I' and dstdstat <> 'P');
            datdstat = Green_UL_RI;
            validationError = *on;
            msgData = errInvalidStatus;
            Exsr WrtMsgSfl;
            If crow = 0;
              CursorPosition = pcdstdstat;
            Endif;
          Endsl;

          //  Determine if changes were made

          If (CopyMode and not validationError);
            If (hiddenFields = screenFields);
              daHeader = daAdd;
              validationError = *on;
              msgData = errNoChangesMade;
              Exsr WrtMsgSfl;
              If (crow = 0);
                CursorPosition = pcdstdfile;
              Endif;
            Endif;
          Endif;

          //  Check for duplicates

          If (AddMode or CopyMode and not validationError);
            Setll(E) (dstdfile:dstdflib:dstdtime:dstdevnt) trgdefp;
            If (%equal and not %error);
              datdfile = Green_UL_RI;
              datdflib = Green_UL_RI;
              datdtime = Green_UL_RI;
              datdevnt = Green_UL_RI;
              msgData = errDuplicateRecord;
              Exsr WrtMsgSfl;
              validationError = *on;
              If (crow = 0);
                CursorPosition = pcdstdfile;
              Endif;
            Endif;
          Endif;

          MsgSflEnd = *On;

        Endsr;

        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        // Clear Subfile
        // - - - - - - - - - - - - - - - - - - - - - - -

        Begsr Clrsfl;

          *IN24  = *on;
          *IN25  = *on;
          *IN26  = *off;
          Write Sflctl;
          *IN25  = *off;
          Sfindx = 0;

        Endsr;

        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        // Load Sfl
        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -

        Begsr LoadSfl;

          Exsr Clrsfl;

          select;
          when (sortRa(sortMode) = 'P');
            Setll *Loval trgdefp;
            If %found(trgdefpf);
              Read(E) trgdefp;
              Dow not %eof(trgdefpf) and not %error;
                exsr loadSflFields;
                Read(E) trgdefp;
              Enddo;
            Endif;
          when (sortRa(sortMode) = '2');
            open(e) trgdefl2;
            Setll *Loval trgdef2;
            If %found(trgdefl2);
              Read(E) trgdef2;
              Dow not %eof(trgdefl2) and not %error;
                exsr loadSflFields;
                Read(E) trgdef2;
              Enddo;
            Endif;
          when (sortRa(sortMode) = '3');
            open(e) trgdefl3;
            Setll *Loval trgdef3;
            If %found(trgdefl3);
              Read(E) trgdef3;
              Dow not %eof(trgdefl3) and not %error;
                exsr loadSflFields;
                Read(E) trgdef3;
              Enddo;
            Endif;
          when (sortRa(sortMode) = '4');
            open(e) trgdefl4;
            Setll *Loval trgdef4;
            If %found(trgdefl4);
              Read(E) trgdef4;
              Dow not %eof(trgdefl4) and not %error;
                exsr loadSflFields;
                Read(E) trgdef4;
              Enddo;
            Endif;
          endsl;

          *in26 = *on;
          ReBuild = *off;
          lastSubFileRRN = sfindx;
          If svsfindx > 0;
            sfindx = svsfindx;
          Else;
            Sfindx = 1;
          Endif;


        Endsr;

        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        // Load subFileFields
        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -

        Begsr LoadSflFields;

          screenFields = outputFields;
          hiddenFields = outputFields;
          saveFields   = outputFields;

          if (showActiveStatus);
            exsr checkAttachedTriggers;
            daactive = PR_Green;
          else;
            daactive = nonDisplay;
          endif;

          sfindx = sfindx + 1;
          Write SflFmt;

          *in24 = *off;

        Endsr;

        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        // Check for Search String
        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -

        Begsr checkSearchString;

          clear leaveSearch;

          if (saveSearchString <> dssrchstr);
            savesubfileRRN = sfindx;
            currentSubFileRRN = sfindx;
            SearchStringFound = *off;
            saveSearchString = dssrchstr;
          endif;

          dow (not leaveSearch);

            currentSubFileRRN += 1;
            if (currentSubFileRRN > lastSubFileRRN);
              currentSubFileRRN = 1;
            //  msgData = 'Wrapped';
            //  Exsr WrtMsgSfl;
            endif;

            if (currentSubFileRRN = savesubfileRRN) and
              not SearchStringFound;
            //  msgData = '"' + %trim(dsSrchStr) + '"'
            //  + errSearchFailed;
            //  Exsr WrtMsgSfl;
              sfIndx = savesubfileRRN;
              leaveSearch = *on;
              iter;
            endif;

            Chain currentSubFileRRN SflFmt;
            if (%error);
            //  msgData = '"' + %trim(dsSrchStr) + '"'
            //  + errSearchFailed;
            //  Exsr WrtMsgSfl;
              leaveSearch = *on;
            endif;

            if (fnScan(dsSrchStr:tdfile));
              sfIndx = currentSubFileRRN;
              SearchStringFound = *on;
              leaveSearch = *on;
              iter;
            endif;

            if (fnScan(dsSrchStr:tdflib));
              sfIndx = currentSubFileRRN;
              SearchStringFound = *on;
              leaveSearch = *on;
              iter;
            endif;

            if (fnScan(dsSrchStr:tdtime));
              sfIndx = currentSubFileRRN;
              SearchStringFound = *on;
              leaveSearch = *on;
              iter;
            endif;

            if (fnScan(dsSrchStr:tdevnt));
              sfIndx = currentSubFileRRN;
              SearchStringFound = *on;
              leaveSearch = *on;
              iter;
            endif;

            if (fnScan(dsSrchStr:tdpgm));
              sfIndx = currentSubFileRRN;
              SearchStringFound = *on;
              leaveSearch = *on;
              iter;
            endif;

            if (fnScan(dsSrchStr:tdplib));
              sfIndx = currentSubFileRRN;
              SearchStringFound = *on;
              leaveSearch = *on;
              iter;
            endif;
          enddo;

        Endsr;

        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        // Check for attached triggers
        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        Begsr CheckAttachedTriggers;

          systemstring = 'ALCOBJ OBJ((' + %trim(tdflib) + '/' + %trim(tdfile) +
          ' *FILE *EXCL)) WAIT(0)';
          errorFlag = system(systemstring);
          select;
          when (errorflag = 1);
            active = '?';
            systemstring = 'CHKOBJ OBJ(' +
            %trim(tdflib) + '/' + %trim(tdfile) + ') OBJTYPE(*FILE)';
            errorFlag = system(systemstring);
            if (errorflag = 1);
              active = '*';
            endif;
          other;
            systemstring = 'DLCOBJ OBJ((' + %trim(tdflib) + '/' +
            %trim(tdfile) +' *FILE *EXCL))';
            errorFlag = system(systemstring);

            systemstring = 'CHGPFTRG FILE(' + %trim(tdflib) + '/' +
            %trim(tdfile) + ') TRG(' + %trim(tdfile) + '_' +
            %trim(%subst(tdtime:2)) + '_' + %trim(%subst(tdevnt:2)) +
            ') TRGLIB(' + %trim(tdflib) + ')';
            errorFlag = system(systemstring);
            if (errorflag > 0);
              active = 'N';
            else;
              active = 'Y';
            endif;
          endsl;

        Endsr;


        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        // Initialization Routine
        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        Begsr *Inzsr;

          If not
            fnAutUsr('Tigger Definition File Maint');
            *inlr = *on;
            Return;
          Endif;

          // Protected Mode Fields
          daProtect.datdstat = PR_Green;
          daProtect.datdfile = PR_Green;
          daProtect.datdflib = PR_Green;
          daProtect.datdtime = PR_Green;
          daProtect.datdevnt = PR_Green;
          daProtect.datdpgm  = PR_Green;
          daProtect.datdplib = PR_Green;

          // Update Mode Fields
          daUpdate.datdstat = Green_UL;
          daUpdate.datdfile = PR_Green;
          daUpdate.datdflib = PR_Green;
          daUpdate.datdtime = PR_Green;
          daUpdate.datdevnt = PR_Green;
          daUpdate.datdpgm  = Green_UL;
          daUpdate.datdplib = Green_UL;
          edtMsgs.modMode = 'Change a Record';
          edtMsgs.headmsg = 'Type over to modify existing data, ' +
          'press Enter.';
          edtMsgs.footmsg = 'Press Enter again to update record.';

          // Insert Mode Fields
          daAdd.datdstat = Green_UL;
          daAdd.datdfile = Green_UL;
          daAdd.datdflib = Green_UL;
          daAdd.datdtime = Green_UL;
          daAdd.datdevnt = Green_UL;
          daAdd.datdpgm  = Green_UL;
          daAdd.datdplib = Green_UL;
          addMsgs.modMode = 'Add a Record';
          addMsgs.headmsg = 'Key in new trigger definition, press Enter.';
          addMsgs.footmsg = 'Press Enter again to add record.';

          // Copy Mode Fields
          cpyMsgs.modMode = 'Copy a Record';
          cpyMsgs.headmsg = 'Type over to modify existing ' +
          'data, press Enter.';
          cpyMsgs.footmsg = 'Press Enter again to add record.';

          // Delete Mode Fields
          dltMsgs.modMode = 'Delete a Record';
          dltMsgs.headmsg = 'Confirm deletion of existing ' +
          'data, press Enter.';
          dltMsgs.footmsg = 'Press Enter to delete record.';

          //Other Fields
          pcdstdfile.crow = 09;
          pcdstdfile.ccol = 21;

          pcdstdflib.crow = 10;
          pcdstdflib.ccol = 23;

          pcdstdtime.crow = 12;
          pcdstdtime.ccol = 21;

          pcdstdevnt.crow = 13;
          pcdstdevnt.ccol = 21;

          pcdstdpgm.crow  = 15;
          pcdstdpgm.ccol  = 21;

          pcdstdplib.crow = 16;
          pcdstdplib.ccol = 23;

          pcdstdstat.crow = 07;
          pcdstdstat.ccol = 21;

          Exsr ClrMsgSfl;
          showActiveStatus = *off;
          KeyListRa(1).keyfld1 = 'File Name';
          KeyListRa(1).keyfld2 = 'File Lib ';
          KeyListRa(1).keyfld3 = 'Time     ';
          KeyListRa(1).keyfld4 = 'Event    ';

          KeyListRa(2).keyfld1 = 'File Lib ';
          KeyListRa(2).keyfld2 = 'File Name';
          KeyListRa(2).keyfld3 = 'Event    ';
          KeyListRa(2).keyfld4 = 'Time     ';

          KeyListRa(3).keyfld1 = 'Event    ';
          KeyListRa(3).keyfld2 = 'Time     ';
          KeyListRa(3).keyfld3 = 'File Name';
          KeyListRa(3).keyfld4 = 'File Lib ';

          KeyListRa(4).keyfld1 = 'Event    ';
          KeyListRa(4).keyfld2 = 'Time     ';
          KeyListRa(4).keyfld3 = 'File Lib ';
          KeyListRa(4).keyfld4 = 'File Name';

          showKeyFlds = KeyListRa(sortMode);

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


     P*--------------------------------------------------
     P* Procedure name: fnScan
     P* Purpose:        Use %scan as a procedure to return boolean
     P* Returns:
     P* Parameter:      paSearchArg => Search Argument
     P* Parameter:      paSourceString => Source String
     P*--------------------------------------------------
     P fnScan          B
     D fnScan          PI              N
     D  paSearchArg                 255A   VALUE
     D paSourceString               255A   VALUE


     D* Local fields
     D retField        S               N
     D pos             s              5u 0

      /FREE

        pos = %scan(%trim(paSearchArg):%trim(paSourceString));
        retField = pos > 0;

        RETURN retField;

      /END-FREE
     P fnScan          E

