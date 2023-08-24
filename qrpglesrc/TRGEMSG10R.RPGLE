      /copy QGPL/QSRVSRC,QILEHeader
     HBndDir('MFGBIND')
     HBndDir('TOOLBIND')
     HBnddir('QC2LE')
     F
     Ftrgemsg10dCF   E             Workstn
     F                                     Sfile(SflFmt:SfIndx)
     F                                     Infds(Dspfbk)
     Ftrgemsgpf uf a e           K Disk
     F
      // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
     D
      // Execute Command (system)†Subprocedure Variables‚
     D System          PR            10I 0 ExtProc('system')
     D  CmdText                        *   Value Options(*String)
     D
     D ErrorCPF        S              7A   Import('_EXCP_MSGID')
     D ErrorFlag       S             10I 0 Inz(0)
     D
      //‚Prototype Definitions€
      /Copy prdsrc/protype,fnAutUsrP
      /Define PROTOTYPE
      /Include nbtygpl/qsrvsrc,fnString
      /undefine PROTOTYPE


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
     D saveFields...
     D                 ds
     D  htecode                       5s 0 inz
     D  htemail
     D  htefnam
     D  htelnam
     D  htedept
     D  htegrp1
     D  htegrp2
     D
     D screenFields...
     D               e ds                  extName(trgemsgpf)
     D                                     prefix(ds)
     D
     D hiddenFields...
     D               e ds                  extName(trgemsgpf)
     D                                     prefix(hd)
     D
     D outputFields...
     D               e ds                  extName(trgemsgpf)
     D
     D
     D daProtect...
     D                 ds
     D  daprfnam                      1a   Inz(PR_Green)
     D  daprlnam                      1a   Inz(PR_Green)
     D  daprdept                      1a   Inz(PR_Green)
     D  daprmail                      1a   Inz(PR_Green)
     D  daprgrp1                      1a   Inz(PR_Green)
     D  daprgrp2                      1a   Inz(PR_Green)
     D  daprConfirm                   1a   Inz(NonDisplay)
     D
     D
     D daUpdate...
     D                 ds
     D  daupfnam                      1a   Inz(Green_UL)
     D  dauplnam                      1a   Inz(Green_UL)
     D  daupdept                      1a   Inz(Green_UL)
     D  daupmail                      1a   Inz(Green_UL)
     D  daupgrp1                      1a   Inz(Green_UL)
     D  daupgrp2                      1a   Inz(Green_UL)
     D  daupConfirm                   1a   Inz(NonDisplay)
     D
     D
     D daAdd...
     D                 ds
     D  daadfnam                      1a   Inz(Green_UL)
     D  daadlnam                      1a   Inz(Green_UL)
     D  daaddept                      1a   Inz(Green_UL)
     D  daadmail                      1a   Inz(Green_UL)
     D  daadgrp1                      1a   Inz(Green_UL)
     D  daadgrp2                      1a   Inz(Green_UL)
     D  daadConfirm                   1a   Inz(NonDisplay)
     D
     D screenAttributes...
     D                 ds
     D  datefnam                      1a   Inz(PR_Green)
     D  datelnam                      1a   Inz(PR_Green)
     D  datedept                      1a   Inz(PR_Green)
     D  datemail                      1a   Inz(PR_Green)
     D  dategrp1                      1a   Inz(PR_Green)
     D  dategrp2                      1a   Inz(PR_Green)
     D  daConfirm                     1a   Inz(NonDisplay)
     D  daHeader                      7a   overlay(screenAttributes:1)
     D
     D
     D damsgs          ds
     D   modMode                     15a   Inz(' ')
     D   headmsg                     50a   Inz(' ')
     D   footmsg                     35a   Inz(' ')
     D
     D addMsgs         ds
     D  daadmodMode                  15a   Inz('Add a Record')
     D  daadheadmsg                  50a   Inz('Key in new Trigger Handling -
     D                                     data, press Enter.')
     D  daadfootmsg                  35a   Inz('Press Enter again to add -
     D                                     record.')
     D
     D edtMsgs         ds
     D  daedmodMode                  15a   Inz('Change a Record')
     D  daedheadmsg                  50a   Inz('Type over to modify existing -
     D                                     data, press Enter.')
     D  daedfootmsg                  35a   Inz('Press Enter again to update -
     D                                     record.')
     D
     D cpyMsgs         ds
     D  dacpmodMode                  15a   Inz('Copy a Record')
     D  dacpheadmsg                  50a   Inz('Type over to modify existing -
     D                                     data, press Enter.')
     D  dacpfootmsg                  35a   Inz('Press Enter again to add -
     D                                     record.')
     D
     D dltMsgs         ds
     D  dadlmodMode                  15a   Inz('Delete a Record')
     D  dadlheadmsg                  50a   Inz('Confirm deletion of existing -
     D                                     data, press Enter.')
     D  dadlfootmsg                  35a   Inz('Press Enter to delete -
     D                                     record.')
     D
     D pIndicators     S               *   Inz(%Addr(*In))
     D Indicators      DS                  Based(pIndicators)
     D  cmdExit...
     D                                 n   Overlay(Indicators:03)
     D  cmdSearch...
     D                                 n   Overlay(Indicators:04)
     D  cmdAdd...
     D                                 n   Overlay(Indicators:06)
     D  cmdCancel...
     D                                 n   Overlay(Indicators:12)
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
     D WorkWith        c                   const('12')
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
     D
     D Svsfindx        s                   Like(sfindx)
     D
      // ‚Message Subfile€
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
      // ‚Error Messages for Error Subfile€
     D
     D errDuplicateRecord...
     D                 c                   'Duplicate record. Record already -
     D                                     exists for Library/File, Program/-
     D                                     Library'
     D
     D errNoChangesMade...
     D                 c                   'No changes have been made. Changes -
     D                                     must be made to create a unique -
     D                                     record'
     D
     D validationError...
     D                 s               n   Inz(*off)
     D
     D sysString       s            255a
     D cancelled...
     D                 s               n   inz(*off)
     D modified...
     D                 s               n   inz(*off)
      // ‚Cursor Positioning for Errors€  €
     D
     D CursorPosition...
     D                 ds
     D  Crow                          3s 0 Inz(0)
     D  Ccol                          3s 0 Inz(0)
     D
     D pcdsMail...
     D                 ds
     D  dsmailrow                     3s 0 Inz(012)
     D  dsmailcol                     3s 0 Inz(022)
     D
     D pcdsfnam...
     D                 ds
     D  dsfnamrow                     3s 0 Inz(007)
     D  dsfnamcol                     3s 0 Inz(022)
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

            Dou not Error;
              Error = *off;
              cancelled = *off;

              Write CmdKey;
              Exfmt Sflctl;

              If not cmdExit and not cmdCancel;

                If cfkey = Enter;

                  Readc(E) Sflfmt;
                  Dow Not %eof(trgemsg10d) and not %error;

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

                    Endsl;

                    cmdCancel = *off;

                    Chain SfIndx SflFmt;
                    dsopt =  ' ';
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
                  Write trgemsgr;

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
                    Chain(E) (htegrp1:htemail) trgemsgr;
                    If %found(trgemsgpf);
                      outputFields = screenFields;
                      Update trgemsgr;

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


          Chain(E) (dstegrp1:dstemail) trgemsgr;
          If %found(trgemsgpf) and not %error;
        // Write Audit Record;
            Delete trgemsgr;
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

          Select;
          When ChgMode;
            daHeader = daUpdate;
          When AddMode or CopyMode;
            daHeader = daAdd;
          Endsl;
          If cmdExit or cmdCancel;
            LeaveSR;
          Endif;

              If (CopyMode and not validationError);
                If (hiddenFields = screenFields);
                  validationError = *on;
                  msgData = errNoChangesMade;
                  Exsr WrtMsgSfl;
                  If (crow = 0);
                    CursorPosition = pcdsfnam;
                  Endif;
                Endif;
              Endif;

              If (AddMode or CopyMode and not validationError);
                Setll(E) (dstegrp1:dstemail) trgemsgr;
                If (%equal and not %error);
                  dategrp1 = Green_UL_RI;
                  datemail  = Green_UL_RI;
                  msgData = errDuplicateRecord;
                  Exsr WrtMsgSfl;
                  validationError = *on;
                  If (crow = 0);
                    CursorPosition = pcdsmail;
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

          Setll *Loval trgemsgr;
          If %found(trgemsgpf);
            Read(E) trgemsgr;
            Dow not %eof(trgemsgpf) and not %error;
              screenFields = outputFields;
              hiddenFields = outputFields;
              saveFields   = outputFields;
              dstename = %trim(telnam) + ', ' + %trim(tefnam);
              sfindx = sfindx + 1;
              Write SflFmt;

              *in24 = *off;
              Read(E) trgemsgr;
            Enddo;
          Endif;

          *in26 = *on;
          ReBuild = *off;
          If svsfindx > 0;
            sfindx = svsfindx;
          Else;
            Sfindx = 1;
          Endif;

        Endsr;

        // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
        Begsr *Inzsr;

          If not
            fnAutUsr('Trigger Handler Maintenance');
            *inlr = *on;
            Return;
          Endif;

          Exsr ClrMsgSfl;

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

