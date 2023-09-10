      /if not defined (PROTOTYPES)
     H nomain  option(*nodebugio : *srcstmt)
     H bnddir('BLUESTAR')
      *----------------------------------------------------------
      * Message - Service Program for message functions
      *
      * NOTE: To access the functions in this service program do the following...
      *       1. Add   BNDDIR('BLUESTAR') to your H-spec.
      *       2. Copy the following compiler directives to the
      *          D-spec section of your program.
      */define PROTOTYPES
      */include qsrvsrc, MESSAGE
      */undefine PROTOTYPES
      *
      *----------------------------------------------------------
      * NOTE: To compile this again as a service program do the following ...
      *       1. Compile this member as a *Module (ie. opt 15 from SEU or cmd CRTBNDRPG)
      *          and specify binding directory BLUESTAR.
      *       2. Issue command UPDSRVPGM, and specify the name of this module.
      *
      *   OR  1. Using Implementer, check out BNDSRC, RPGMOD, SRVPGM all named MESSAGE
      *       2. See the BLUESTAR Service Program documentation for details.
      *----------------------------------------------------------
     Fmessage   cf   e             workstn usropn
     F                                     prefix(d_)

     FMsgLog    uf a e             disk    prefix(MsgLog_) usropn
      * Generic Message Log
      *--------------------------------------------------------------------------------
      * Program Change Log
      *--------------------------------------------------------------------------------
      * Date       Pgmr     Proj        Scan Desc
      * 2023-09-09 Keck                      Changed variable names which started with @
      *                                      to now start with an x. Program wouldn't
      *                                      otherwise compile. Apparrently naming rules
      *                                      changed over the years.
      * 2009-04-05 Keck     P346902     dk02 added SndPgmMsg procedure
      * 04/14/2006 Keck     12142            Change reference from Center to CenterString
      * 07/25/2005 Keck     11264            added DisplayRecordLockMsg procedure
      * 07/21/2005 Keck     11264            Standardize all Bluestar Service Programs
      * 01/05/2004 Keck                      Close display file after calls to "Confirmed"
      * 03/16/2004 Keck                      Compile using binder language.
      * 08/29/2003 Keck                      Created
      *--------------------------------------------------------------------------------

      /endif

      *************************************************
      * Message Service Program Prototypes (Exported) *
      *************************************************
     D MessageCleanup  PR

     D Confirmed       PR              N
     D  Title                        15    const

     D SndSflMsg       PR
     D  Msg                         256    varying value

     D ClrMsgSfl       PR

     D WinMsg          PR                  extpgm('WINMSG')
     D  Msg1                         50    const
     D  Msg2                         50    const options(*nopass)
     D  Msg3                         50    const options(*nopass)
     D  Request                      10    const options(*nopass)

     D DisplayRecordLockMsg...
     D                 PR
     D  psdsExceptionData...
     D                               80    const

     D SndPgmMsg       PR
     D Msg                          512    varying value
     D MsgTyp                        10    const options(*nopass)
     D MsgQueue                     276    const options(*nopass)

      * Log a message to the generic Message Log
     D LogMsg          PR
     D  xProcess                     10    Value
     D  xMsg                        256    Value Varying


      /if defined (PROTOTYPES)
      /eof
      /endif


      ****************************************
      * Supporting Prototypes (Not Exported) *
      ****************************************
      /define PROTOTYPES
      /include QsrvSRC,string
      /undefine PROTOTYPES

     D PriorUserProc   PR           276    varying


      ***********************
      * Global Declarations *
      ***********************
     D psds          esds                  extname(psds) prefix(psds_)



      *######################
      * EXPORTED PROCEDURES *
      *######################




      ***************************************************************************
      * Message Cleanup                                                         *
      *                                                                         *
      * Close files opened by this service program.                             *
      *                                                                         *
      ***************************************************************************
     P MessageCleanup  B                   export
     D MessageCleanup  PI

  1b C                   If        %open(message)
     C                   close     message
  1e C                   Endif

     C                   return

     P MessageCleanup  E




      ***************************************************************************
      * Confirm Prompt                                                          *
      *                                                                         *
      * This function will display a confirm prompt in a window, with a user    *
      * defined title.  User must respond with Y or N.  Prompt will default     *
      * to 'N'.  If the user presses 'Y' the function will return *ON, else     *
      * it will return *OFF.                                                    *
      * The title is centered.  The cursor is restricted to the confirm window. *
      *                                                                         *
      * Example                                                                 *
      * If Confirmed('Void Receipt')    // where 'Void Receipt' is title        *
      *    exsr VoidReceipt;                                                    *
      * EndIf;                                                                  *
      ***************************************************************************
     P Confirmed       B                   export
     D Confirmed       PI              N
     D  Title                        15    const

     D Response        s               n

  1b C                   If        not %open(message)
     C                   open      message
  1e C                   Endif

     C                   eval      d_Title = CenterString(Title)
     C                   eval      d_ConfirmYN = 'N'
     C                   exfmt     confirm

  1b C                   If        d_ConfirmYN = 'Y'
     C                   eval      response = *on
  1x C                   Else
     C                   eval      response = *off
  1e C                   Endif

     C                   close     message

     C                   return    response

     P Confirmed       E




      ***************************************************************************
      * Send Subfile Message                                                    *
      *                                                                         *
      * Example ...                                                             *
      *    SndSflMsg('Subfile Message Here !!');                                *
      *    write msgctl;                                                        *
      *    exfmt testr;                                                         *
      *    ClrMsgSfl();                                                         *
      *                                                                         *
      * Remember to include the DDS message subfile and subfile control         *
      * as follows.  set MSGKEY = *blanks, PROC = procedure name from PSDS.     *
      *------------------------------------------------------------------
      *         R MSGSFL                    SFL
      *                                     SFLMSGRCD(24)
      *           MSGKEY                    SFLMSGKEY
      *           PROC                      SFLPGMQ
      *------------------------------------------------------------------
      *         R MSGCTL                    SFLCTL(MSGSFL)
      *                                     SFLSIZ(2)
      *                                     SFLPAG(1)
      *                                     SFLDSP
      *                                     SFLDSPCTL
      *                                     SFLINZ
      * 90                                  SFLEND
      *           PROC                      SFLPGMQ
      ******************************************************************
     P SndSflMsg       B                   export
     D SndSflMsg       PI
     D  Msg                         256    varying value

     D MsgID           s              7    inz('CPF9897')
     D QualMsgFil      s             20    inz('QCPFMSG   *LIBL     ')
     D MsgDta          s            256
     D MsgDtaLen       s             10I 0 inz(%len(Msg))
     D MsgTyp          s             10    inz('*DIAG')
     D MsgQueue        s            276
     D CallStackOff    s             10I 0
     D MsgKey          s              4
     D Err             s             10I 0

      * Call the Send Program Message API, which has the effect of adding a
      * message to the message subfile for the given program / procedure.
     C                   eval      MsgQueue = PriorUserProc
      *
     C                   call      'QMHSNDPM'
     C                   parm                    MsgId
     C                   parm                    QualMsgFil
     C                   parm      Msg           MsgDta
     C                   parm                    MsgDtaLen
     C                   parm                    MsgTyp
     C                   parm                    MsgQueue
     C                   parm                    CallStackOff
     C                   parm                    MsgKey
     C                   parm                    Err

     P SndSflMsg       E




      *************************
      * Clear Message Subfile *
      *************************
     P ClrMsgSfl       B                   export

     D ClrMsgSfl       PI

     D MsgQueue        s            276
     D CallStackOff    s             10I 0
     D MsgKey          s              4
     D Rmv             s             10    inz('*ALL')
     D Err             s             10I 0

      * Call the Remove Program Messages API, which has the effect of clearing
      * the message subfile for the given program / procedure.
     C                   eval      MsgQueue = PriorUserProc

     C                   call      'QMHRMVPM'
     C                   parm                    MsgQueue
     C                   parm                    CallStackOff
     C                   parm                    MsgKey
     C                   parm                    Rmv
     C                   parm                    Err
     PClrMsgSfl        E




      ***************************************************************************
      * Display Record Lock Message                                             *
      *                                                                         *
      * BE ADVISED!!  You can only trap locks when the file is configured       *
      *               to permit it. The WAITRCD parameter on the CRTPF command  *
      *               must be set to something other that *NOMAX.  Otherwise    *
      *               a lock will cause                                         *
      *               your application to simply hang until someone realizes    *
      *               there is a problem, and determines how to handle it.      *
      *                                                                         *
      * Example ...                                                             *
      *    Chain(e) key MyFile;   // note: you must specify the (e)             *
      *    if %error;                                                           *
      *       DisplayRecordLockMsg(psds);                                       *
      *    endif;                                                               *
      *                                                                         *
      * A message like the following will be displayed in a small window.       *
      *                                                                         *
      *            ----------------------------                                 *
      *            | Record 1 in use by job   |                                 *
      *            | 955737/USERID/JOBNAME.   |                                 *
      *            |                          |                                 *
      *            | Press ENTER to continue. |                                 *
      *            ----------------------------                                 *
      *                                                                         *
      * The input parameter is the Exception Data from the Program Status Data  *
      * Structure from the calling program (pos 91-170, 80 bytes)               *
      * You can get it by including the following D-spec in your                *
      * program and referencing field ExcDta.                                   *
      * The file "PSDS" is available on all systems.                            *
      *                                                                         *
      * D psds          esds                  extname(psds)                     *
      *                                                                         *
      ***************************************************************************
     P DisplayRecordLockMsg...
     P                 B                   export

     D DisplayRecordLockMsg...
     D                 PI
     D  psdsExceptionData...
     D                               80    const

     D Msg1            s             50
     D Msg2            s             50
     D Pos             s              5i 0

      /free

         pos = %scan('job ' : psdsExceptionData);

         if pos = *zero;
            // display generic record lock message
            Msg1 = 'The record you want to work with is not available';
            Msg2 = 'at this time.  Please try again later.';
         else;
            // display record lock message
            Msg1 = %subst(psdsExceptionData : 1 : pos + 2);
            Msg2 = %subst(psdsExceptionData : pos + 4);
         endif;

         WinMsg(Msg1 : Msg2);
         Return;

      /end-free


     P DisplayRecordLockMsg...
     P                 E




      ***************************************************************************
      * Send Program Message                                                    *
      *                                                                         *
      * Examples ...                                                            *
      *    // send a *INFO message to the job log                               *
      *    SndPgmMsg('My Message');                                             *
      *                                                                         *
      *     // sends *DIAG message to the job log                               *
      *    SndPgmMsg('My Message', '*DIAG');                                    *
      *                                                                         *
      *     // sends *ESCAPE message to calling program                         *
      *    SndPgmMsg('My Message', '*ESCAPE', *PRV)                             *
      *                                                                         *
      *    Support *INQ and *NOTIFY messages (where a return variable is        *
      *    involved) may be added in the future.                                *
      *                                                                         *
      ***************************************************************************
     P SndPgmMsg       B                   export

     D SndPgmMsg       PI
     D Msg                          512    varying value
     D MsgTypIn                      10    const options(*nopass)
     D MsgQueueIn                   276    const options(*nopass)

     D MsgTyp          s             10
     D MsgQueue        s            276
     D MsgID           s              7    inz('CPF9897')
     D QualMsgFil      s             20    inz('QCPFMSG   *LIBL     ')
     D MsgDta          s            512
     D MsgDtaLen       s             10I 0 inz(%len(Msg))
     D CallStackOff    s             10I 0
     D MsgKey          s              4
     D Err             s             10I 0

      /free

         if %parms < 2;
            MsgTyp = '*INFO'; // informational message
         else;
            MsgTyp = MsgTypIn;
         endif;

         if %parms < 3;
            MsgQueue = '*EXT';  // post message to job log
         else;
            MsgQueue = MsgQueueIn;
         endif;

      /end-free

     C                   monitor
     C                   call      'QMHSNDPM'
     C                   parm                    MsgId
     C                   parm                    QualMsgFil
     C                   parm      Msg           MsgDta
     C                   parm                    MsgDtaLen
     C                   parm                    MsgTyp
     C                   parm                    MsgQueue
     C                   parm                    CallStackOff
     C                   parm                    MsgKey
     C                   parm                    Err

     C                   on-error
     C                   endmon

     C                   return

     P SndPgmMsg       E




      ***************************************************************************
      * LogMsg - Write a record to the generic message Log file (LOGMSG)        *
      *                                                                         *
      * Example ...                                                             *
      *    If SomethingHappened;                                                *
      *      LogMsg('MYJOB' : 'Job failed because ...';                         *
      *    Endif;                                                               *
      *                                                                         *
      *--------------------------------------------------------------------------
     P LogMsg          B                   Export
     D LogMsg          PI
     D  xProcess                     10    Value
     D  xMsg                        256    Value Varying

     D xTimeStamp      s               z

     C                   eval      MsgLog_Process = xProcess
     C                   Time                    MsgLog_Date
     C                   Time                    MsgLog_Time
     C                   eval      MsgLog_JobName = psds_Job
     C                   eval      MsgLog_JobUser = psds_User
     C                   move      psds_JobNum   MsgLog_JobNum
     C                   eval      MsgLog_Msg = xMsg

     C                   open      MsgLog
     C                   write     MsgLogR
     C                   close     MsgLog

     P LogMsg          E




      *##########################      *##########################    *##########################
      * NON-EXPORTED PROCEDURES *      * NON-EXPORTED PROCEDURES *    * NON-EXPORTED PROCEDURES *
      *##########################      *##########################    *##########################









      ******************************************************************************
      * Retrieve Prior User Procedure Name from the call stack for the current job *
      *   skips over system procedure names (all those starting with letter "Q"    *
      ******************************************************************************
     P PriorUserProc   B
     D PriorUserProc   PI           276    varying

      * Define parameters for the QWVRCSTK API (Retrieve Call Stack)
     D ReceiverLen     s             10i 0
     D ReceiverFmt     s              8    inz('CSTK0100')
     D JobIDinfoFmt    s              8    inz('JIDF0100')
     D err             s             10i 0

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

      * the following isolates a procedure name in the call stack entry format
     D ProcNamePtr     s               *
     D  ProcName       s            276    based( ProcNamePtr )

      * Miscellaneous Declarations
     D ProcedureName   s            276    varying
     D SkipTwoEntries  s             10i 0
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      * find out how much space to allocate to the receiver variable by
      * calling the API once and checking "BytesAvail".
     C                   eval      ReceiverLen = 8
     C                   alloc     ReceiverLen   ReceiverPtr
     C                   exsr      #GetCallStack

      * call the API to get the call stack for real this time
     C                   eval      ReceiverLen = BytesAvail
     C                   realloc   BytesAvail    ReceiverPtr
     C                   exsr      #GetCallStack

      * Get previous user call stack entry (skip IBM procedures)
     C                   exsr      #GetPrvUsrEnt

     C                   exsr      #exit


      * S U B R O U T I N E S
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     C     #GetPrvUsrEnt begsr
      * Get previous user call stack entry (skip IBM procedures)
      * Stack entries in this list start with the last called procedure
      * SkipTwoEntries: skips this procedure (PriorUserProc) and the immediate
      * calling procedure which for now is only SndSflMsg.

     C                   eval      StackEntryPtr = ReceiverPtr + EntryOffset
  1b C                   Do        NbrOfEntries
     C                   eval      ProcNamePtr = StackEntryPtr + ProcNameOff

  2b C                   If        %subst(ProcName : 1 : 1) = 'Q'  or
     C                             SkipTwoEntries < 2
     C                   eval      StackEntryPtr = StackEntryPtr + EntryLength
     C                   eval      SkipTwoEntries = SkipTwoEntries + 1
  2x C                   Else
     C                   eval      ProcedureName =
     C                                  %subst(ProcName : 1 : ProcNameLen)
  LV C                   leaveSR
  2e C                   Endif

  1e C                   Enddo

     C                   eval      ProcedureName = *Blanks
     C                   exsr      #exit

     C                   endsr
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     C     #GetCallStack begsr
     C                   call      'QWVRCSTK'
     C                   parm                    Receiver                       O
     C                   parm                    ReceiverLen                    I
     C                   parm                    ReceiverFmt                    I
     C                   parm                    JobIDinfo                      I
     C                   parm                    JobIDinfoFmt                   I
     C                   parm                    err                            B

  1b C                   If        ( ReceiverLen > 8  ) and
  1b C                             ( InfoStatus = 'N' )
     C                   eval      ProcedureName = *Blanks
     C                   exsr      #exit
  1e C                   Endif

     C                   endsr
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

     C     #Exit         begsr
     C                   dealloc(N)              ReceiverPtr
     C                   return    ProcedureName
     C                   endsr

     P PriorUserProc   E
