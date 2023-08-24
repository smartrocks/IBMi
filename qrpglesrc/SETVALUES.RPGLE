     H option(*nodebugio : *srcstmt) dftactgrp(*no) actgrp(*CALLER) indent('| ')
      *------------------------------------------------------------------------------------------
      * SetValues - For given Function Code, set values in file VALUES
      *
      * Note: File VALUES is intended to be used out of QTEMP only (see pgm SetValuesC CLP)
      *------------------------------------------------------------------------------------------
      * Program Change Log
      *------------------------------------------------------------------------------------------
      * Date       Pgmr    Scan   Proj    Description
      * 2005-06-10 Keck           11594   Created
      *------------------------------------------------------------------------------------------
     FValuesL1  UF A E           K DISK    Prefix(v_)
      * Generic Values File by Function ID (for use out of QTEMP ONLY)
      *------------------------------------------------------------------------------------------
     D P001            s                   like( Function )
     D P002            s                   like( sDateN   )
     D P003            s                   like( eDateN   )
     D P004            s                   like( sDateISOchar )
     D P005            s                   like( eDateISOchar )
     D P006            s                   like( String   )
     D P007            s                   like( Number   )

     D Function        s                   like( v_Function )
     D sDateN          s                   like( v_sDateN   )
     D eDateN          s                   like( v_eDateN   )
     D sDateISOchar    s             10
     D eDateISOchar    s             10
     D String          s                   like( v_String   )
     D Number          s                   like( v_Number   )

     D sDateISO        s               d
     D eDateISO        s               d
      *------------------------------------------------------------------------------------------

      *******************************
      * Validate the ISO Start Date *
      *******************************
     C     *ISO          test(de)                sDateISOchar
     C                   if        %error
     C                   eval      sDateISO = d'0001-01-01'
     C                   else
     C                   eval      sDateISO = %date(sDateISOchar : *ISO)
     C                   endif


      *******************************
      * Validate the ISO End Date   *
      *******************************
     C     *ISO          test(de)                eDateISOchar
     C                   if        %error
     C                   eval      eDateISO = d'0001-01-01'
     C                   else
     C                   eval      eDateISO = %date(eDateISOchar : *ISO)
     C                   endif


      /free


         // **********************************************************
         // * Add/Update the VALUES file for the given FUNCTION CODE *
         // **********************************************************
         CHAIN Function ValuesR;
         v_Function = Function;
         v_sDateN   = sDateN;
         v_eDateN   = eDateN;
         v_sDateISO = sDateISO;
         v_eDateISO = eDateISO;
         v_String   = String;
         v_Number   = Number;
         v_Join_A   = *loval;  // alpha join criteria for WRKQRY (join LE)
         v_Join_N   = *loval;  // numberic join criteria for WRKQRY (join LE)

         if %Found;
            UPDATE ValuesR;
         else;
            WRITE ValuesR;
         endif;

         exsr ExitPgm;

      /end-free


      *  S U B R O U T I N E S
      *------------------------------------------------------------------------------------------
     C     *inzsr        begsr

     C     *entry        plist
     C     Function      parm                    P001
     C     sDateN        parm                    P002
     C     eDateN        parm                    P003
     C     sDateISOchar  parm                    P004
     C     eDateISOchar  parm                    P005
     C     String        parm                    P006
     C     Number        parm                    P007

     C                   endsr
      *------------------------------------------------------------------------------------------
      /free

         begsr ExitPgm;

            *inLR = *on;
            return;

         endsr;

      /end-free
