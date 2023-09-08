      /if not defined (PROTOTYPES)
     H nomain  option(*nodebugio : *srcstmt)
     H bnddir('BLUESTAR')
      *----------------------------------------------------------
      * Service Program for String Functions
      *
      * NOTE: To access the programs in this service program do the following...
      *       1. Add   BNDDIR('STRING')   to your H-spec.
      *       2. Copy the following compiler directives to the
      *          D-spec section of your program.
      */define PROTOTYPES
      */include QSRVSRC,string
      */undefine PROTOTYPES
      *
      *----------------------------------------------------------
      * NOTE: To compile this again as a service program do the following ...
      *       1. Compile this member as a *Module (ie. opt 15 from SEU or cmd CRTBNDRPG)
      *       2. Issue command CRTSRVPGM, and specify the name of this module.
      *
      * Program Change Log
      *--------------------------------------------------------------------------------
      * Date       Pgmr     Proj        Scan Desc
      * 2009-09-25 Keck     H52869           Added DoubleSquote and Quote procedures
      * 04/14/2006 Keck     12142            Rename Center to CenterString due to collision
      * 07/21/2005 Keck     11264            Standardize all Bluestar Service Programs
      * 03/16/2004 Keck                      Added procedures UPPER, LOWER
      * 11/24/2003 Keck                      Created
      *--------------------------------------------------------------------------------

      /endif


      *************************************************
      * Message Service Program Prototypes (Exported) *
      *************************************************


      * Center (leftadjusted) string
     D CenterString    PR           256a   Varying
     D  CntStr                      256a   Varying Value

      * Convert String to Lower Case
     D Lower           PR           256
     D  InString                    256    Varying Value

      * Convert String to Upper Case
     D Upper           PR           256
     D  InString                    256    Varying Value

      * Convert all squotes (') to double squotes ('')
      * (This is useful when preparing strings for SQL)
     D DoubleSquote    PR           256
     D  InString                    256    Value


      * Place quotes aroud a string to facilitate constructing SQL statements
     D Quote           PR           512    varying
     D  string                      512    value

      /if defined (PROTOTYPES)
      /eof
      /endif



      ****************************************
      * Supporting Prototypes (Not Exported) *
      ****************************************
     **-- Check Reverse:  ----------------------------------------------------**
     D CheckR          Pr             5u 0
     D  CrArg                         1a   Const
     D  CrString                    256a   Const






      *######################
      * EXPORTED PROCEDURES *
      *######################


     **-- Center string:  ----------------------------------------------------**
     P CenterString    B                   Export
     D                 Pi           256a   Varying
     D  CntStr                      256a   Varying Value
     **
     D Blanks          s            128a
     **
     C                   Return    %SubSt( Blanks
     C                                   : 1
     C                                   : %Int(( %Len( CntStr ) -
     C                                     CheckR( ' ': CntStr )) / 2 )
     C                                   ) + CntStr
     **
     P CenterString    E





     **-- Convert string to Lower Case ---------------------------------------**
     P Lower           B                   Export
     D                 pi           256
     D  InString                    256    Varying Value
     **
     D  wString        s            256
     **
     D UP              C                   const('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
     D LO              C                   const('abcdefghijklmnopqrstuvwxyz')
     **-----------------------------------------------------------------------**
     **
     C     UP:LO         xlate     InString      wString
     C                   Return    wString
     **
     P Lower           E





     **-- Convert string to Upper Case ---------------------------------------**
     P Upper           B                   Export
     D                 pi           256
     D  InString                    256    Varying Value
     **
     D  wString        s            256
     **
     D UP              C                   const('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
     D LO              C                   const('abcdefghijklmnopqrstuvwxyz')
     **-----------------------------------------------------------------------**
     **
     C     LO:UP         xlate     InString      wString
     C                   Return    wString
     P Upper           E





      * Convert all squotes (') to double squotes ('')
      * DEFN: A squote is a "single quote".
      * NOTE: This is useful when preparing strings for SQL
     P DoubleSquote    B                   Export
     D                 pi           256
     D  wString                     256    Value

     D i               s              5i 0
     D length          s              5i 0
     D o               s              5i 0
     D SQUOTE          c                   const('''')

     D inString        ds           256
     D arrI                           1    dim(256)

     D outString       ds           256
     D arrO                           1    dim(256)

      /free
         inString = wString;
         length = %len(%trimr(inString));

         for i = 1 to length;
               o += 1;
               arrO(o) = arrI(i);

            if arrI(i) = SQUOTE;
               o += 1;
               arrO(o) = arrI(i);
            endif;
         endfor;

         return outString;

      /end-free
     P DoubleSquote    E





      * Place quotes aroud a string to facilitate constructing SQL statements
     P Quote           B                   Export
     D Quote           PI           512    varying
     D  string                      512    value

     D q               c                   const('''')

      /free

         return q + %trim(string) + q;

      /end-free

     P Quote           E





      *##########################
      * NON-EXPORTED PROCEDURES *
      *##########################
     **-- Check Reverse:  ----------------------------------------------------**
     P CheckR          B
     D                 Pi             5u 0
     D  CrArg                         1a   Const
     D  CrString                    256a   Const
     **
     D Pos             S              5u 0
     **-- Check Reverse:  ----------------------------------------------------**
     **
     C     CrArg         CheckR    CrString      Pos
     C                   If        Pos        =  *Zero
     C                   Return    1
     C                   Else
     C                   Return    Pos
     C                   EndIf
     P CheckR          E
