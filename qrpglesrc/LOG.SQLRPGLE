     H dftactgrp(*no) actgrp(*caller) option(*nodebugio : *srcstmt)
     H bnddir('BLUESTAR')
      *--------------------------------------------------------------------------------
      * Log      - This program should be called before and after any job step
      *            for which we want to capture start and end times in the RunLog table.
      *            The captured data can be used to prioritize optimization efforts.
      *
      *            Program run durations are logged to table NBTYGPL/RUNLOG.
      *            Corresponding program stacks are logged to table NBTYGPL/STACKLOG.
      *
      *            This utility can be implemented via the LOG command (NBTYGPL/LOG)
      *
      * Sample implementation in a CLP
      *   log ('PGMA')  // first instance logs program start time and program stack
      *      call PGMA
      *   log ('PGMA')  // second instance logs program end time and run duration
      *
      *   log ('PGMB')
      *      call PGMB
      *   log ('PGMB')

      *--------------------------------------------------------------------------------
      * Program Change Log
      *--------------------------------------------------------------------------------
      * Date       Programmer   Project Scan Desc
      * 2019-09-19 Keck                      Created
      *--------------------------------------------------------------------------------

     FRunLog1   UF A E           K DISK    PREFIX(r_)
      * keyed by JobName, JobNumber, ProgramName
      * select where EndDate = 0001-01-01  (start captured and needing EndDate)

      **********************************
      * External Procedure References  *
      **********************************
      * Procedure               Service Program  Description
      * ---------------------   --------------   ---------------------------------------
      * NextNum                 VALUE            Get a Next Number
      * Quote                   STRING           quote a string (for dynamic sql)
      * LogError                ERROR            log error message to table ERRORLOG

     D/define PROTOTYPES
     D/include nbtygpl/qrpglesrc,VALUE
     D/include nbtygpl/qrpglesrc,STRING
     D/include nbtygpl/qrpglesrc,ERROR
     D/undefine PROTOTYPES

      ***********************
      * Global Declarations *
      ***********************

     D ThisProgram...
     D                 pr                  extpgm('RUNLOG')
     D                               10    options(*nopass)

     D                 pi
     D ProgramName                   10

     D StackLog        pr                  extpgm('STACKLOG')
     D  StackLogID                    9s 0

     D GetPgmInfo      pr
     D  PgmType                      10
     D  PgmDesc                      50
     D  PgmLib                       10

      // program status data structure
     D psds          esds                  extname(psds) prefix(psds_)

     D EndTimeStamp    s               z
     D ErrorOccurred   s               n
     D Event           s             10
     D FALSE           s               n   inz('0')
     D PgmType         s             10
     D PgmDesc         s             50
     D PgmLib          s             10
     D RunLogID        s              9s 0
     D StackLogID      s              9s 0
     D StartTimeStamp  s               z
     D TRUE            s               n   inz('1')

      ********
      * Main *
      ********
       /free

          if %parms <> 1;
             exsr Exit; // incorrect number of parameters. Return without error.
          endif;

          chain (psds_Job: psds_User: psds_JobNum: ProgramName) RunLog1;
          if %found;
             Event = 'END';
          else;
             Event = 'START';
          endif;

          // Log the current program call to table RunLog and capture the stack
          Select;
             when Event = 'START';
                Stacklog(StackLogID); // capture stack in NBTYGPL/STACKLOG
                if StacklogID = *zero;
                   exsr Exit;  // the call to StackLog failed - exit
                else;
                   RunLogID = StacklogID;
                endif;

                getPgmInfo(PgmType: PgmDesc: PgmLib);
                r_ID         = RunLogID;
                r_JobName    = psds_Job;
                r_JobUser    = psds_User;
                r_JobNumber  = psds_JobNum;
                r_JobDate    = %date(*date);
                r_Program    = ProgramName;   // program or waypoint name
                r_Library    = PgmLib;
                r_StartDate  = %date();
                r_StartTime  = %time();
                r_EndDate    = d'0001-01-01';
                r_EndTime    = t'00.00.00';
                r_DurSeconds = *zero;
                r_PgmType = PgmType;
                r_PgmDesc = PgmDesc;
                WRITE RunLogR;

             when Event = 'END';
                // Update table RunLog with the program run duration in seconds
                r_EndDate    = %date();
                r_EndTime    = %time;

                // calculate duration between start and end times
                StartTimeStamp = r_StartDate + r_StartTime;
                EndTimeStamp = r_EndDate + r_EndTime;

                monitor;
                   r_DurSeconds = %diff(EndTimeStamp: StartTimeStamp: *Seconds);
                on-error;
                   exsr Exit;
                endmon;

                UPDATE RunLogR;
          EndSL;

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



      * S U B P R O C E D U R E S
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     P GetPgmInfo      B
     D GetPgmInfo      pi
     D  PgmType                      10
     D  PgmDesc                      50
     D  PgmLib                       10

     D ErrorCode       DS                  qualified
     D  BytesProvided                10I 0 inz(%size(ErrorCode))
     D  BytesAvail                   10I 0
     D  ExceptionID                   7
     D  RESERVED                      1
     D  MsgDta                       96

     D QualPgm         DS                  qualified
     D  Program                      10
     D  Library                      10    inz('*LIBL')

     D RtvPgmDesc      pr                  extPgm('QCLRPGMI')
     D   Receiver                   160
     D   ReceiverLen                 10i 0
     D   ReceiverFmt                  8
     D   QualPgm                     20
     D   ErrorCode                   16

      * Standard parameters for QCLRPGMI API                            API
      * (Retrieve Program Information)                                  API
      *
     d  Receiver       DS                  inz qualified
     d   program               9     18                                         PROGRAM NAME
     d   library              19     28                                         PROGRAM LIBRARY
     d   attribute            39     48                                         PROGRAM ATTRIBUTE
     d   desc                111    160                                         TEXT DESCRIPTION

     D  ReceiverLen    s             10i 0 inz(160)
     D  ReceiverFmt    s              8    inz('PGMI0100')

       /free

         QualPgm.Program = ProgramName; // global variable
         clear errorCode;

         errorOccurred = FALSE;
         monitor;
         RtvPgmDesc(Receiver: ReceiverLen: ReceiverFmt: QualPgm: ErrorCode);
         on-error;
            errorOccurred = TRUE;
         endmon;

         Select;
         when errorOccurred;
            // no record of the program was found
            pgmType = *blanks;
            pgmDesc = *blanks;
            pgmLib  = *blanks;

         when ErrorCode.BytesAvail = *zero;
            // program attributes were successfully retrieved
            pgmType = receiver.attribute;
            pgmDesc = receiver.desc;
            pgmLib  = receiver.library;

         other;
            // no record of the program was found
            pgmType = *blanks;
            pgmDesc = *blanks;
            pgmLib  = *blanks;
         EndSl;

       /end-free

     P GetPgmInfo      E

