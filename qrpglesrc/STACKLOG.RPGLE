     H dftactgrp(*no) actgrp(*caller) option(*nodebugio : *srcstmt)
     H bnddir('BLUESTAR')
      *--------------------------------------------------------------------------------
      * Stacklog - This program will capture the current program stack and log it to
      *            table StackLog. This is used in conjunction with the LOG command.
      *            The StackLog ID is passed back to the caller.
      *
      * Sample implementation in a CLP
      *
      *   LOG(PGMA)
      *      call PGMA
      *   LOG(PGMA)
      *
      *   LOG(PGMA)
      *      call PGMB
      *   LOG(PGMA)
      *--------------------------------------------------------------------------------
      * Program Change Log
      *--------------------------------------------------------------------------------
      * Date       Programmer   Project Scan Desc
      * 2019-09-16 Keck                      Created
      *--------------------------------------------------------------------------------
     FStackLog  IF A E           K DISK    PREFIX(SL_)

      **********************************
      * External Procedure References  *
      **********************************
      * Procedure               Service Program  Description
      * ---------------------   --------------   ---------------------------------------
      * NextNum                 VALUE            Get a Next Number
     D/define PROTOTYPES
     D/include nbtygpl/qrpglesrc,VALUE
     D/undefine PROTOTYPES

      ***********************
      * Global Declarations *
      ***********************

     D ThisProgram...
     D                 pr                  extpgm('STACKLOG')
     D                                9s 0

     D
     D                 pi
     D ID                             9s 0

     D fnStackLog...
     D                 pr

      // program status data structure
     D psds          esds                  extname(psds) prefix(psds_)



      ********
      * Main *
      ********
       /free

          // Log the current program stack to table StackLog
          fnStackLog();
          exsr Exit;


      //  S U B R O U T I N E S
      //  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          begsr Exit;

             *INLR = *on;
             return;
          endsr;


      // Error handler
          begsr *PSSR;
             exsr Exit;
          endsr;

       /end-free



      ******************************************************************************
      * Log the current program stack to table StackLog                            *
      *   Skip over system program (those in library QSYS)                         *
      ******************************************************************************
     P fnStackLog...
     P                 B
     D fnStackLog...
     D                 PI

      * Define parameters for the QWVRCSTK API (Retrieve Call Stack)
     D ReceiverLen     s             10i 0
     D ReceiverFmt     s              8    inz('CSTK0100')
     D JobIDinfoFmt    s              8    inz('JIDF0100')

     D errDS           ds                  qualified inz
     D BytesProvided                 10i 0 inz(%size(errDS))
     D BytesAvailable                10i 0
     D MsgID                          7
     D Reserved                       1
     D MsgData                     3000

     D JobIDinfo       ds
     D  JobName                      10    inz('*')
     D  JobUser                      10
     D  JobNumber                     6
     D  InternalJobID                16
     D  Reserved01                    2    inz(*Loval)
     D  ThreadIndicator...
     D                               10i 0 inz( 1 )
     D  ThreadID                      8    inz (*Loval)

     D ReceiverPtr     s               *
     D Receiver        ds                  based( ReceiverPtr )
     D  BytesReturned                10i 0
     D  BytesAvail                   10i 0
     D  NotUsed01                    10i 0
     D  EntryOffset                  10i 0
     D  NbrOfEntries                 10i 0
     D  NotUsed02                     8
     D  InfoStatus                    1

     D StackEntryPtr   s               *
     D StackEntry      ds                  based( StackEntryPtr )
     D  EntryLength                  10i 0
     D  NotUsed03                    10i 0
     D  NotUsed04                    10i 0
     D  ProcNameOff                  10i 0
     D  ProcNameLen                  10i 0
     D  NotUsed05                    10i 0
     D  Program                      10
     D  Library                      10

      * the following isolates a procedure name in the call stack entry format
     D ProcNamePtr     s               *
     D  ProcName       s            276    based( ProcNamePtr )

      * Miscellaneous Local Declarations
     D i               s             10i 0
     D Seq             s             10i 0
     D Prev_Program    s             10
     D ProcedureName   s            276    varying
     D SkipTwoEntries  s             10i 0
     ‚* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /free
      * find out how much space to allocate to the receiver variable by
      * calling the API once and checking "BytesAvail".
        ReceiverLen = 8;
        ReceiverPtr = %alloc(ReceiverLen);
        exsr GetCallStack;
        if errDS.BytesAvailable <> 0;
           ID = 0;  // error occurred
           dealloc(N) ReceiverPtr;
           return;
        endif;

      * call the API to get the call stack for real this time
        ReceiverLen = BytesAvail;
        ReceiverPtr = %realloc(ReceiverPtr : BytesAvail);
        exsr GetCallStack;
        if errDS.BytesAvailable <> 0;
           ID = 0;  // error occurred
           dealloc(N) ReceiverPtr;
           return;
        endif;

        exsr LogEachCallStackEntry;
        dealloc(N) ReceiverPtr;
        return;



      * S U B R O U T I N E S
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        begsr LogEachCallStackEntry;
      * Step through user call stack entries
      * Stack entries in this list start with the last called program first
      * Procedures within programs result in the program name repeating.
      * Consecutive duplicate program names will be skipped.

        Seq = 1;
        ID = NextNumber('STACKLOG');  // from NEXTNUM file
        StackEntryPtr = ReceiverPtr + EntryOffset;
        prev_Program = *blanks;

        For i = 1 to NbrOfEntries;
           //ProcNamePtr = StackEntryPtr + ProcNameOff;

           If        Program <> 'STACKLOG' and
                     Program <> 'LOG'      and
                     Program <> prev_Program;

                     sl_ID = ID;
                     sl_SEQ = Seq;
                     sl_PROGRAM = Program;
                     sl_LIBRARY = Library;
                     sl_JOBDATE = %date(*date);
                     sl_SYSDATE = %date();
                     sl_SYSTIME = %time();
                     write StackLogR;

                     Seq=Seq+1;
                     prev_Program = sl_PROGRAM;
           endif;
                     StackEntryPtr = StackEntryPtr + EntryLength;

        EndFor;

        ProcedureName = *Blanks;

        endsr;

      /end-free
     ‚* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     C     GetCallStack  begsr
     C                   call      'QWVRCSTK'
     C                   parm                    Receiver                       O
     C                   parm                    ReceiverLen                    I
     C                   parm                    ReceiverFmt                    I
     C                   parm                    JobIDinfo                      I
     C                   parm                    JobIDinfoFmt                   I
     C                   parm                    errDS                          B

     C                   endsr
     ‚* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

     P fnStackLog...
     P                 E

