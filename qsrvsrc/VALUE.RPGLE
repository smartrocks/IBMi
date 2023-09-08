      /if not defined (PROTOTYPES)
     H nomain  option(*nodebugio : *srcstmt)
     H bnddir('BLUESTAR')
      * The order in which the members should be implemented is:-
      * 1/.  VALUE     (BNDSRC) binding source and/or
      * 2/.  VALUE     (SRVMOD) service module
      * 3/.  VALUE     (RPGSRV) service program

      * When implementing the service program, use
      * option 1 (Override creation attribute) with the following
      * parameters:-
      * Service program  . . . . . . . . > VALUE
      *   Library  . . . . . . . . . . . >   #PGMLIB
      * Module . . . . . . . . . . . . .   VALUE
      *   Library  . . . . . . . . . . .     *LIBL
      * Export . . . . . . . . . . . . . > *srcfile
      * Export source file . . . . . . .   QBNDSRC
      *   Library  . . . . . . . . . . .     NBTYGPL
      * Export source member . . . . . .   VALUE
      *
      *----------------------------------------------------------
      * Value - Service Program for working with Special Values
      *
      *
      * NOTE: To access the programs in this service program do the following...
      *       1. Add   BNDDIR('BLUESTAR') to your H-spec.
      *       2. Copy the following compiler directives to the
      *          D-spec section of your program.
      */define PROTOTYPES
      */include QSRVSRC,value
      */undefine PROTOTYPES
      *
      *----------------------------------------------------------
      * NOTE: To compile this again as a service program do the following ...
      *       1. Compile this member as a *Module (ie. opt 15 from SEU or cmd CRTBNDRPG)
      *          and specify binding directory BLUESTAR.
      *       2. Issue command UPDSRVPGM, and specify the name of this module.
      *
      * Program Change Log
      *--------------------------------------------------------------------------------
      * Date       Pgmr     Proj   Task Scan Desc
      * 07/21/2005 Keck     11264  2.00      Standardize all Bluestar Service Programs
      *                                      Added IsValid12DigitLUHN and support functions
      * 03/17/2004 Keck                      Recreated using binder language
      * 01/08/2004 Keck                      Enabled commitment control support for Next Numbers
      * 12/29/2003 Keck                      Created
      *--------------------------------------------------------------------------------
     FnextNum1  uf   e           k disk    Prefix(NN_)
     F                                     UsrOpn
     F                                     Rename(NextNumR : NNcommit)
     F                                     Commit
      * open under Commitment Control

     FnextNum2  uf   e           k disk    Prefix(NN_)
     F                                     UsrOpn
     F                                     Rename(NextNumR : NN)
      * open WITHOUT Commitment Control
      *----------------------------------------------------------

      /endif

      *************************************************
      * Message Service Program Prototypes (Exported) *
      *************************************************
     D NextNumber      PR            12p 0
     D  Function                     50    value
     D  UseCommitmentControl...
     D                                 n   const options(*nopass)

     D NextNumberCleanUp...
     D                 PR

     D NextNumberReset...
     D                 PR
     D  Function                     50    value
     D  UseCommitmentControl...
     D                                 n   const options(*nopass)

     D IsValid12DigitLUHN...
     D                 PR              n
     D  Number                       12s 0 const


     D NextNumberSQL   PR            12p 0
     D  Function                     50    const
dk02 D                                     Varying
     D  UseCommitmentControl...
     D                                 n   const options(*nopass)

      /if defined (PROTOTYPES)
      /eof
      /endif


      ****************************************
      * Supporting Prototypes (Not Exported) *
      ****************************************
      /define PROTOTYPES
      /include QSRVSRC,message
      /undefine PROTOTYPES

     D Luhn12Increment...
     D                 pr             5p 0
     D  Number                       12s 0 const

     D Luhn12NextNumber...
     D                 pr            12s 0
     D  Number                       12s 0 const


      ***********************
      * Global Declarations *
      ***********************
     D False           s               n   inz(*off)
     D True            s               n   inz(*on)



      *######################
      * EXPORTED PROCEDURES *
      *######################




      ***************************************************************************
      * Get Next Number                                                         *
      *                                                                         *
      * Note: For example, you could use this function to retrieve the next     *
      *       receipt number or purchase order number, and it will automatically*
      *       increment the value in the file and update the audit log values.  *
      *       Also, if the auto recycle flag is set for the given function ID,  *
      *       and the maximum number is exceeded, the value will be reset to    *
      *       the starting value again.                                         *
      *       If no value can be retrieved for the function code then ...       *
      *         1. A message will be logged to the error log file               *
      *         2. If the job is interactive, a window message to the user will *
      *            describe the problem.                                        *
      *         3. A dump is produced.                                          *
      *         4. The program will return Next Number = zero                   *
      *                                                                         *
      * Example ...                                                             *
      *    PO = NextNumber('PurchaseOrder');                                    *
      *                                                                         *
      *--------------------------------------------------------------------------
     P NextNumber      B                   export
     D NextNumber      PI            12p 0
     D  Function                     50    value
     D  UseCommitmentControl...
     D                                 n   const options(*nopass)

     D CommitmentControlIsActive...
     D                 s               n
     D ErrorOccurred   s               n
     D Msg             s            256
     D Msg1            s             50
     D Msg2            s             50
     D Msg3            s             50
     D NextNumber      s                   like(nn_NextNum)
     D wInc            s              5i 0
     D wNextNum        s                   like(nn_NextNum)
      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      * Open the appropriate next numbers file, as needed

     C                   Select
     C                   When      %parms = 1
 1e  C                   eval      CommitmentControlIsActive = *off

     C                   Other
 1e  C                   eval      CommitmentControlIsActive =
     C                                                      UseCommitmentControl
 1e  C                   EndSL

     C                   if        not %open(nextNum1)       and
     C                             CommitmentControlIsActive                    using commit
     C                   open      nextNum1
     C                   endif

     C                   if        not %open(nextNum2)       and
     C                             NOT CommitmentControlIsActive                not using commit
     C                   open      nextNum2
     C                   endif

     C                   if        CommitmentControlIsActive
     C     Function      chain     NNcommit
 1e  C                   else
     C     Function      chain     NN
 1e  C                   endif

     C                   exsr      increment

     C                   return    NextNumber


      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      * Increment the Next Number
     C     increment     begsr

 1b  C                   Select
      * function code not defined.
 1x  C                   When      CommitmentControlIsActive and
 1x  C                             not %found(NextNum1)
     C                   eval      Msg1 = 'Next Number Function Code not ' +
     C                                    'found for:'
     C                   exsr      error
     C                   LeaveSR

      * function code not defined.
 1x  C                   When      NOT CommitmentControlIsActive and
 1x  C                             not %found(NextNum2)
     C                   eval      Msg1 = 'Next Number Function Code not ' +
     C                                    'found for:'
     C                   exsr      error
     C                   LeaveSR
     C                   Endsl

      /free

         if nn_Algorithm = 'LUHN12';
            wNextNum = Luhn12NextNumber(nn_NextNum);
 1x         wInc     = Luhn12Increment(wNextNum);
         else;
            wNextNum = nn_NextNum;
 1x         wInc     = nn_Inc;
         endif;

      /end-free

 1b  C                   Select
      * simple increment is all that's needed.
 1x  C                   When      %dec((wNextNum +  wInc) : 13 : 0) <= nn_Max
     C                   eval      NextNumber = wNextNum
     C                   eval      nn_NextNum = wNextNum + wInc
     C                   exsr      UpdNxtNum

      * maximum value exceeded.  reset next number to the minimum value
      * Note: LUHN numbers may reset to any number.  When NextNumber is called
      *       the value will automatically be corrected.
 1x  C                   When      nn_CycleYN = 'Y'
     C                   eval      NextNumber = wNextNum
     C                   eval      nn_NextNum = nn_Min
     C                   exsr      UpdNxtNum

      * maximum value exceeded.  unable to automatically reset.
 1x  C                   Other
     C                   eval      Msg1 = 'Maximum Next Number not reset for ' +
     C                                    'Function Code: '
     C                   exsr      error

     C                   If        CommitmentControlIsActive
     C                   unlock    NextNum1
 1e  C                   Else
     C                   unlock    NextNum2
 1e  C                   EndIf

 1e  C                   EndSL

     C                   EndSR
      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      * Update Next Number
     C     UpdNxtNum     begsr

     C                   time                    nn_Date
     C                   time                    nn_Time

     C                   If        CommitmentControlIsActive
     C                   update    NNcommit
 1e  C                   Else
     C                   update    NN
 1e  C                   EndIf

     C                   endsr
      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      * Handle Error retrieving Next Number
     C     error         begsr

     C                   eval      Msg2 = Function
     C                   eval      Msg3 = 'Please call the Help Desk.'
     C                   callp     WinMsg(Msg1 : Msg2 : Msg3)
     C                   callp     Logmsg('NEXTNUMBER' : Msg1 + Msg2)
     C                   dump(a)
     C                   eval      NextNumber = *zero
     C                   eval      ErrorOccurred = True

     C                   endsr
      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     P NextNumber      E




      ***************************************************************************
      * Close Next Number File                                                  *
      *                                                                         *
      * Note: Programs which open the Next Number file by calling the NEXTNUM   *
      *       function should call this function, as the former                 *
      *       opens the Next Number file.                                       *
      *                                                                         *
      * Example ...                                                             *
      *    CloseNextNumberFile;                                                 *
      *                                                                         *
      *--------------------------------------------------------------------------
     P NextNumberCleanUp...
     P                 B                   export
     D NextNumberCleanUp...
     D                 PI

     C                   close     nextNum1
     C                   close     nextNum2


     P NextNumberCleanUp...
     P                 E




      ***************************************************************************
      * Next Number Reset                                                       *
      *                                                                         *
      * Note: Reset the next number for a given Function ID to the Min value.   *
      *       There is no return value.                                         *
      *       If no value can be retrieved for the function code then ...       *
      *         1. A message will be logged to the error log file               *
      *         2. If the job is interactive, a window message to the user will *
      *            describe the problem.                                        *
      *         3. A dump is produced.                                          *
      *         4. The program will return Next Number = zero                   *
      *                                                                         *
      * Example ...                                                             *
      *    NextNumberReset('My_Process');                                       *
      *                                                                         *
      *--------------------------------------------------------------------------
     P NextNumberReset...
     P                 B                   export
     D NextNumberReset...
     D                 PI
     D  Function                     50    value
     D  UseCommitmentControl...
     D                                 n   const options(*nopass)

     D NextNumber      s                   like(nn_NextNum)
     D Msg             s            256
     D Msg1            s             50
     D Msg2            s             50
     D Msg3            s             50
     D CommitmentControlIsActive...
     D                 s               n
      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      * Open the appropriate next numbers file, as needed

     C                   Select
     C                   When      %parms = 1
 1e  C                   eval      CommitmentControlIsActive = *off

     C                   Other
 1e  C                   eval      CommitmentControlIsActive =
     C                                                      UseCommitmentControl
 1e  C                   EndSL

     C                   if        not %open(nextNum1)       and
     C                             CommitmentControlIsActive                    using commit
     C                   open      nextNum1
     C                   endif

     C                   if        not %open(nextNum2)       and
     C                             NOT CommitmentControlIsActive                not using commit
     C                   open      nextNum2
     C                   endif

     C                   if        CommitmentControlIsActive
     C     Function      chain     NNcommit
 1e  C                   else
     C     Function      chain     NN
 1e  C                   endif

     C                   exsr      Reset

     C                   return


      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      * Reset the Next Number to the Minimum number for the function
     C     Reset         begsr

 1b  C                   Select
      * function code not defined.
 1x  C                   When      CommitmentControlIsActive and
 1x  C                             not %found(NextNum1)
     C                   eval      Msg1 = 'Next Number Function Code not ' +
     C                                    'found for:'
     C                   exsr      error

      * function code not defined.
 1x  C                   When      NOT CommitmentControlIsActive and
 1x  C                             not %found(NextNum2)
     C                   eval      Msg1 = 'Next Number Function Code not ' +
     C                                    'found for:'
     C                   exsr      error

      * maximum value exceeded.  reset next number to the minimum value
 1x  C                   Other
     C                   eval      nn_NextNum = nn_Min
     C                   exsr      UpdNxtNum

 1e  C                   EndSL

     C                   EndSR
      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      * Update Next Number
     C     UpdNxtNum     begsr

     C                   time                    nn_Date
     C                   time                    nn_Time

     C                   If        CommitmentControlIsActive
     C                   update    NNcommit
 1e  C                   Else
     C                   update    NN
 1e  C                   EndIf

     C                   endsr
      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      * Handle Error retrieving Next Number
     C     error         begsr

     C                   eval      Msg2 = Function
     C                   eval      Msg3 = 'Please call the Help Desk.'
     C                   callp     WinMsg(Msg1 : Msg2 : Msg3)
     C                   callp     LogMsg('NEXTNUMBER' : Msg1 + Msg2)
     C                   dump(a)
     C                   eval      NextNumber = *zero

     C                   endsr
      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     P NextNumberReset...
     P                 E




      ***************************************************************************
      * IsValid12DigitLUHN                                                      *
      *                                                                         *
      * Purpose: Test if input number is a valid 12 digit LUHN number.  LUHN    *
      *       is a type of modulus 10 check digit.  A complete definition       *
      *       can be found on the net.                                          *
      *                                                                         *
      * Example ...                                                             *
      *    If IsValid12DigitLUHN( MyNumber );                                   *
      *       ...                                                               *
      *    Endif                                                                *
      *--------------------------------------------------------------------------
     P IsValid12DigitLUHN...
     P                 b                   export
     D IsValid12DigitLUHN...
     D                 pi              n
     D  Number                       12s 0 const

wj07 D luhn2           S              2  0 DIM(12)
wj07 D luhn3           S              1  0 DIM(24)
wj07 D cc              S              2  0
wj07 D chech1          S              4  0
wj07 D chech           S              1  0

     d                 ds
     d dsncard#                1     12  0
     d  dsn1                          1  0 overlay(dsncard#:1)
     d  dsn2                          1  0 overlay(dsncard#:2)
     d  dsn3                          1  0 overlay(dsncard#:3)
     d  dsn4                          1  0 overlay(dsncard#:4)
     d  dsn5                          1  0 overlay(dsncard#:5)
     d  dsn6                          1  0 overlay(dsncard#:6)
     d  dsn7                          1  0 overlay(dsncard#:7)
     d  dsn8                          1  0 overlay(dsncard#:8)
     d  dsn9                          1  0 overlay(dsncard#:9)
     d  dsn10                         1  0 overlay(dsncard#:10)
     d  dsn11                         1  0 overlay(dsncard#:11)
     d  dsn12                         1  0 overlay(dsncard#:12)

     c                   move      number        dsncard#
     c                   EXSR      $LUHN

     c                   If        chech = 0
     c                   return    True
     c                   Else
     c                   return    False
     c                   Endif


      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     c     $LUHN         BEGSR
      * determine if Number has a valid LUHN modulus 10 check digit
     c                   eval      luhn2(1) = dsn1
     c                   eval      luhn2(2) = dsn2
     c                   eval      luhn2(3) = dsn3
     c                   eval      luhn2(4) = dsn4
     c                   eval      luhn2(5) = dsn5
     c                   eval      luhn2(6) = dsn6
     c                   eval      luhn2(7) = dsn7
     c                   eval      luhn2(8) = dsn8
     c                   eval      luhn2(9) = dsn9
     c                   eval      luhn2(10) = dsn10
     c                   eval      luhn2(11) = dsn11
     c                   eval      luhn2(12) = dsn12
     c                   eval      cc = 1
     c                   Dow       cc <= 11
     c                   eval      luhn2(cc) = (luhn2(cc)) * 2
     c                   eval      cc = cc + 2
     c                   Enddo
     c                   movel     luhn2(1)      luhn3(1)
     c                   move      luhn2(1)      luhn3(2)
     c                   movel     luhn2(2)      luhn3(3)
     c                   move      luhn2(2)      luhn3(4)
     c                   movel     luhn2(3)      luhn3(5)
     c                   move      luhn2(3)      luhn3(6)
     c                   movel     luhn2(4)      luhn3(7)
     c                   move      luhn2(4)      luhn3(8)
     c                   movel     luhn2(5)      luhn3(9)
     c                   move      luhn2(5)      luhn3(10)
     c                   movel     luhn2(6)      luhn3(11)
     c                   move      luhn2(6)      luhn3(12)
     c                   movel     luhn2(7)      luhn3(13)
     c                   move      luhn2(7)      luhn3(14)
     c                   movel     luhn2(8)      luhn3(15)
     c                   move      luhn2(8)      luhn3(16)
     c                   movel     luhn2(9)      luhn3(17)
     c                   move      luhn2(9)      luhn3(18)
     c                   movel     luhn2(10)     luhn3(19)
     c                   move      luhn2(10)     luhn3(20)
     c                   movel     luhn2(11)     luhn3(21)
     c                   move      luhn2(11)     luhn3(22)
     c                   movel     luhn2(12)     luhn3(23)
     c                   move      luhn2(12)     luhn3(24)
     c                   xfoot     luhn3         chech1
     c                   move      chech1        chech
     c                   ENDSR


     P IsValid12DigitLUHN...
     P                 e



      *##########################     *##########################   *##########################
      * NON-EXPORTED PROCEDURES *     * NON-EXPORTED PROCEDURES *   * NON-EXPORTED PROCEDURES *
      *##########################     *##########################   *##########################




      ***************************************************************************
      * Luhn12Increment                                                         *
      *                                                                         *
      * Purpose: Given any 12 digit number, determine the offset to the next    *
      *          LUHN number.  Overflow is handled by passing back a large      *
      *          increment.                                                     *
      *                                                                         *
      * Example ...                                                             *
      *    LUHNinc = Luhn12Increment( MyCurrentLUHNnumber );                    *
      *       ...                                                               *
      *    Endif                                                                *
      *--------------------------------------------------------------------------
     P Luhn12Increment...
     P                 b
     D Luhn12Increment...
     D                 pi             5p 0
     D  Number                       12s 0 const

     D  increment      s              5p 0
     D  MaxVal         c                   const(999999999999)
     D  wNumber        s             20i 0

      /free

         wNumber = Number;

         DoU IsValid12DigitLUHN(wNumber);
            wNumber = wNumber + 1;
            if wNumber > MaxVal;
               Leave;
            endif;
         Enddo;

         increment = wNumber - Number;

         return (increment);


      /end-free


     P Luhn12Increment...
     P                 e




      ***************************************************************************
      * Luhn12NextNumber                                                        *
      *                                                                         *
      * Purpose: Given any 12 digit number, determine the next LUHN number.     *
      *          If the number passed in is itself valid, it will be returned   *
      *          as the result.  Otherwise, the next sequential number which    *
      *          has a LUHN check digit will be returned.                       *
      *                                                                         *
      * Example ...                                                             *
      *    LUHNnumber = Luhn12NextNUmber( MyNumber );                           *
      *       ...                                                               *
      *    Endif                                                                *
      *--------------------------------------------------------------------------
     P Luhn12NextNumber...
     P                 b
     D Luhn12NextNumber...
     D                 pi            12s 0
     D  Number                       12s 0 const

     D  MaxVal         c                   const(999999999999)
     D  wNumber        s             20i 0

      /free

         wNumber = Number;

         if IsValid12DigitLUHN(wNumber);
            return (wNumber);
         endif;

         DoU IsValid12DigitLUHN(wNumber);
            wNumber = wNumber + 1;
            if wNumber > MaxVal;
               Leave;
            endif;
         Enddo;

         return (wNumber);


      /end-free


     P Luhn12NextNumber...
     P                 e


      ***************************************************************************
      * Get Next Number SQL - to be used in creating an SQL function           *
      *                                                                         *
      * Note: For example, you could use this function to retrieve the next     *
      *       receipt number or purchase order number, and it will automatically*
      *       increment the value in the file and update the audit log values.  *
      *       Also, if the auto recycle flag is set for the given function ID,  *
      *       and the maximum number is exceeded, the value will be reset to    *
      *       the starting value again.                                         *
      *       If no value can be retrieved for the function code then ...       *
      *         1. A message will be logged to the error log file               *
      *         2. If the job is interactive, a window message to the user will *
      *            describe the problem.                                        *
      *         3. A dump is produced.                                          *
      *         4. The program will return Next Number = zero                   *
      *                                                                         *
      * Example ...                                                             *
      *    PO = NextNumber('PurchaseOrder');                                    *
      *                                                                         *
      *--------------------------------------------------------------------------
     P NextNumberSQL   B                   export
     D NextNumberSQL   PI            12p 0
     D  Function                     50    const
dk02 D                                     Varying
     D  UseCommitmentControl...
     D                                 n   const options(*nopass)

     D HldNextNumber   s                   like(nn_NextNum)
     D HldFunction     s             50
      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      * Open the appropriate next numbers file, as needed

        HldFunction = %trim(Function);
        select;
          when %parms = 1;
 1e         HldNextNumber = NextNumber(HldFunction);
          other;
 1e         HldNextNumber = NextNumber(HldFunction: UseCommitmentControl);
 1e     endsl;

        return HldNextNumber;

     P NextNumberSQL   E

