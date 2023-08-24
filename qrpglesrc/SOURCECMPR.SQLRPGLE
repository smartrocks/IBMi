      *--------------------------------------------------------------------
      * SOURCECMPR - ISeries Source Compare Utility
      *
      * Date       Programmmer  Project Scan Desc
      * 2010-05-06 Keck                      Created
      *--------------------------------------------------------------------
     h option(*nodebugio : *srcstmt) dftactgrp(*no) actgrp('QILE')
     h bnddir('BLUESTAR')
      *--------------------------------------------------------------------
     F*lkloc31  IF   E           K DISK    usropn
      *--------------------------------------------------------------------
     D msg             s            256
     d function        s             10
     d srcFil          s             10
     d srcLib          s             10
     d srcMbr          s             10
     d srcTyp          s             10
     d User            s             10
     d IgnoreCmts      s              1
      *--------------------------------------------------------------------
      /define PROTOTYPES
      /include nbtygpl/qrpglesrc,API
      /include nbtygpl/qrpglesrc,ERROR
      /undefine PROTOTYPES

     c     *entry        plist
     c                   parm                    srcFil
     c                   parm                    srcLib
     c                   parm                    srcMbr
     c                   parm                    srcTyp
     c                   parm                    User
     c                   parm                    IgnoreCmts

      /free

         // log the source compare request
         msg = 'File: ' + srcFil + '   Library: ' +  srcLib +
               '   Member: ' + srcMbr + '   User: ' + User  +
               '   IgnoreComments: ' + IgnoreCmts;
         function = 'SOURCECMP';

         logError(function: msg);

         // Base PF    Field Name Field Description         Key Tp  Pos  Len Dec
         // QRPGLESRC  SRCSEQ                                   S     1     6  2
         //            SRCDAT                                   S     7     6  0
         //            SRCDTA                                   A    13   100


         exec sql  set option commit = *none;

         // get all source but drop date and seq #'s

         exec sql  create table qtemp/sourceOut
                 (SRCLINE CHAR (100 ) NOT NULL WITH DEFAULT);

         exec sql  insert into SourceOut
                      select srcdta
                         from SourceIn;

         *inLR = *on;
         return;
      /end-free
