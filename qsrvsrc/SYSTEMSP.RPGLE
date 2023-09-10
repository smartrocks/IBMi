      /If not Defined (PROTOTYPE)
      /include QGPL/QSRVSRC,QILEHeader
     H Bnddir('QC2LE':'RXSBND':'TOOLBIND':'STRINGSP')

     T* System value/network attribute procedures.
      *
      * SYNOPSIS: This module contains the rtvsysval() procedure, which can
      *           be used to retrieve a system value (equivalent to the
      *           RTVSYSVAL command) or a network attribute (equivalent to
      *           the RTVNETA command). If the system value/network
      *           attribute starts with the letter 'Q', it is assumed to
      *           be a system value and the QWCRSVAL API is called,
      *           otherwise the QWCRNETA API is called. The rtvsysval()
      *           procedure can include an optional QUSEC error parameter.
      *
      *=====================================================================
      *
     D qwcrneta        PR                  Extpgm('QWCRNETA')
     D   RcvVar                   32767A         Options(*Varsize)
     D   RcvVarLen                   10I 0 Const
     D   NbrVarToRtn                 10I 0 Const
     D   NetAtrVarArr                10A   Const Dim(100)
     D   ApiError                                Like(QUSEC)
     D                                           Options(*Varsize)
      *
     D qwcrsval        PR                  Extpgm('QWCRSVAL')
     D   RcvVar                   32767A         Options(*Varsize)
     D   RcvVarLen                   10I 0 Const
     D   NbrVarToRtn                 10I 0 Const
     D   SysValVarArr                10A   Const Dim(100)
     D   ApiError                                Like(QUSEC)
     D                                           Options(*Varsize)
      *
     D SysValVarArr    S             10A   Dim(100)
      *
     D qwcr_struct     DS
     D   NbrVarRtn                   10I 0
     D   SysValInfOS                 10I 0 Dim(100)
     D   SysValInfTbl             32363A
      *
     D SysValInfDS@    S               *
     D SysValInfDS     DS                  Based(SysValInfDS@)
     D   SysVal                      10A
     D   SysValDtaTyp                 1A
     D   SysValInfSts                 1A
     D   SysValDtaLen                10I 0
     D   SysValDta                32751A

      //*-----------------------------------------------------------------------
      /EndIf

      //*=======================================================================
      //* Begin of Components to be copied via /Include by other PGMs / SRVPGMs
      //*=======================================================================

     D rtvsysval       PR          2080A   Extproc('rtvsysval')
     D   SysVal                      10A   Const
     D   ApiError                                Like(QUSEC)
     D                                           Options(*Nopass:*Varsize)

     D QUSEC           DS
     D  ErrBytesProv                 10I 0 Inz(%size(QUSEC))
     D  ErrBytesAvail                10I 0 Inz
     D  ErrMsgID                      7A
     D                                1
     D  ErrMsgDta                   512A

      //*=======================================================================
      //* End of Components to be copied via /Include by other PGMs / SRVPGMs
      //*=======================================================================

      //*-----------------------------------------------------------------------
      /If Defined(PROTOTYPE)
      /EOF
      /EndIf

      *
      *=====================================================================
      * rtvsysval() - Retrieve a single system value/network attribute.
      *=====================================================================
     P rtvsysval       B                   Export
     D                 PI          2080A
     D   SysVal                      10A   Const
     D   P_QUSEC                                 Like(QUSEC)
     D                                           Options(*Nopass:*Varsize)
      *---------------------------------------------------------------------
      /free

        if %parms > 1;
          reset QUSEC;
        else;
          clear QUSEC;
        endif;


        // Determine which API to call

        select;
          when %subst( SysVal : 1 : 1 ) = 'Q';
            qwcrsval( qwcr_struct : %len( qwcr_struct ) : 1 : SysVal : QUSEC );
          other;
            qwcrneta( qwcr_struct : %len( qwcr_struct ) : 1 : SysVal : QUSEC );
        endsl;

        if ErrBytesAvail > 0 or NbrVarRtn < 1;
          exsr *pssr;
        endif;

        SysValInfDS@ = %addr( qwcr_struct ) + SysValInfOS( 1 );

        return %subst( SysValDta : 1 : SysValDtaLen );

        begsr *pssr;
          if %parms > 1 and ErrBytesAvail > 0;
            P_QUSEC = QUSEC;
          endif;
          return *blanks;
        endsr;

      /end-free
     P                 E
