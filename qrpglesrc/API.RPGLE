      /if not defined (PROTOTYPES)
     H nomain  option(*nodebugio : *srcstmt)
     H bnddir('BLUESTAR')
      *--------------------------------------------------------------------------------
      * API - Service Program for Simplified API Interfaces
      *
      * NOTE: To access the functions in this service program do the following...
      *       1. Add   BNDDIR('BLUESTAR') to your H-spec.
      *       2. Copy the following compiler directives to the
      *          D-spec section of your program.
      */define PROTOTYPES
      */copy nbtygpl/qrpglesrc,API
      */undefine PROTOTYPES
      *
      *--------------------------------------------------------------------------------
      * NOTE: To compile this again as a service program do the following ...
      *       1. Compile this member as a *Module (ie. opt 15 from SEU or cmd CRTBNDRPG)
      *          and specify binding directory BLUESTAR.
      *       2. Issue command UPDSRVPGM, and specify the name of this module.
      *
      * Program Change Log
      *--------------------------------------------------------------------------------
dk01  * Date       Programmer   Project Scan Desc
dk01  * 2009-03-29 Keck         389382  dk01 Add fnGetCallingProgramName
      * 08/29/2005 Keck                      Add fnRtvDtaAra (Retrieve Data Area)
dk01  * 07/21/2005 Keck         11264            Standardize all Bluestar Service Programs
      * 11/29/2004 Keck                      added function SystemName
      * 03/25/2004 Keck                      added prototype Command for QCMDEXC
      * 03/17/2004 Keck                      recreated using binder language
      * 12/30/2003 Keck                      Created
      *--------------------------------------------------------------------------------

      /endif

      *************************************************
      * Message Service Program Prototypes (Exported) *
      *************************************************
     D RunningInteractively...
     D                 PR              n

     D RunningInBatch  PR              n
     D Command         PR
     D   CmdStr                    4096A   value varying

     D SystemName      PR             8

     D RtvDtaAra       PR          2000    Varying
     D   DataAreaName                10    const
     D   Library                     10    const options(*nopass)
     D   StartPos                    10i 0 const options(*nopass)
     D   Length                      10i 0 const options(*nopass)

dk01 D fnGetCallingProgramName...
dk01 D                 PR           276    varying


      /if defined (PROTOTYPES)
      /eof
      /endif


      ****************************************
      * Supporting Prototypes (Not Exported) *
      ****************************************
      /define PROTOTYPES
      /copy NBTYGPL/QRPGLESRC,string
      /undefine PROTOTYPES

     D RtvJobInf       PR
     D  JobType                       1
     D QCMDEXC         PR                  EXTPGM('QCMDEXC')
     D   CmdStr                    4096A   const options(*varsize)
     D   CmdStrLen                   15P 5 const

dk01
dk01  ***********************
dk01  * Global Declarations *
dk01  ***********************
dk01 D psds          esds                  extname(psds) prefix(psds_)


      *######################
      * EXPORTED PROCEDURES *
      *######################




      ***************************************************************************
      * Running Interactively                                                   *
      *                                                                         *
      * Note: Returns whether the current job is running interactively.         *
      *                                                                         *
      * Example ...                                                             *
      *    If RunningInteractively;                                             *
      *      DisplayStuff;                                                      *
      *    Endif;                                                               *
      *                                                                         *
      *--------------------------------------------------------------------------
     P RunningInteractively...
     P                 B                   export
     D RunningInteractively...
     D                 PI              n

     D JobType         s              1

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      * Get the job type via the Retrieve Job Information API
     C                   callp     RtvJobInf( JobType )
     C                   If        JobType = 'I'
     C                   return    *on
     C                   else
     C                   return    *off
     C                   endif

     P RunningInteractively...
     P                 E
      *--------------------------------------------------------------------------




      ***************************************************************************
      * Running In Batch                                                        *
      *                                                                         *
      * Note: Returns whether the current job is running in batch mode.         *
      *                                                                         *
      * Example ...                                                             *
      *    If RunningInBatch;                                                   *
      *      Do_Something_Wonderful;                                            *
      *    Endif;                                                               *
      *                                                                         *
      *--------------------------------------------------------------------------
     P RunningInBatch  B                   export
     D RunningInBatch  PI              n

     D JobType         s              1

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      * Get the job type via the Retrieve Job Information API
     C                   callp     RtvJobInf( JobType )
     C                   If        JobType = 'B'
     C                   return    *on
     C                   else
     C                   return    *off
     C                   endif

     P RunningInBatch  E
      *--------------------------------------------------------------------------




      ***************************************************************************
      * Command                                                                 *
      *                                                                         *
      * Execute a command using the QCMDEXC API                                 *
      *                                                                         *
      * Example ...                                                             *
      *    Command('DSPLIBL');                                                  *
      *                                                                         *
      *                                                                         *
      *--------------------------------------------------------------------------
     P Command         B                   export
     D Command         PI
     D  CmdStr                     4096A   value varying

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      * some error trapping should be implemented here at some point
      * like a return code, job log message, errorlog file msg, etc.
     C                   callp(e)  QCMDEXC( CmdStr  : %Len(CmdStr))
     C                   return

     P Command         E
      *--------------------------------------------------------------------------




      ***************************************************************************
      * SystemName                                                              *
      *                                                                         *
      * Retrieve System Name                                                    *
      *                                                                         *
      * Example ...                                                             *
      *    some_Variable = SystemName();                                        *
      *                                                                         *
      *                                                                         *
      *--------------------------------------------------------------------------
     P SystemName      B                   Export
     D SystemName      PI             8

     D QWCRNETA        PR                  ExtPgm('QWCRNETA')
     D   RcvVar                   32766A   OPTIONS(*VARSIZE)
     D   RcvVarLen                   10I 0 const
     D   NbrNetAtr                   10I 0 const
     D   AttrNames                   10A   const
     D   ErrorCode                  256A

     D SysName         s              8

      * Error code structure
     D EC              DS
      *                                    Bytes Provided (size of struct)
     D  EC_BytesP              1      4B 0 INZ(256)
      *                                    Bytes Available (returned by API)
     D  EC_BytesA              5      8B 0 INZ(0)
      *                                    Msg ID of Error Msg Returned
     D  EC_MsgID               9     15
      *                                    Reserved
     D  EC_Reserve            16     16
      *                                    Msg Data of Error Msg Returned
     D  EC_MsgDta             17    256

      * Receiver variable for QWCRNETA with only one attribute
     D RV              ds
      *                                    Number of Attrs returned
     D   RV_Attrs                    10I 0
      *                                    Offset to first attribute
     D   RV_Offset                   10I 0
      *                                    Add'l data returned.
     D   RV_Data                      1A   DIM(1000)

      * Network attribute structure
     D p_NA            S               *
     D NA              ds                  based(p_NA)
      *                                    Attribute Name
     D   NA_Attr                     10A
      *                                    Type of Data.  C=Char, B=Binary
     D   NA_Type                      1A
      *                                    Status. L=Locked, Blank=Normal
     D   NA_Status                    1A
      *                                    Length of Data
     D   NA_Length                   10I 0
      *                                    Actual Data (in character)
     D   NA_DataChr                1000A
      *                                    Actual Data (in binary)
     D   NA_DataInt                  10I 0 overlay(NA_DataChr:1)

      * Call API to get system name
      *   -1 = API returned an error
     C                   callp     QWCRNETA(RV: %size(RV): 1: 'SYSNAME': EC)
     c                   if        EC_BytesA > 0
     c                   return    *blanks
     c                   endif

      *   -2 = RcvVar contained data that we
      *        dont understand :(
     c                   if        RV_Attrs <> 1
     c                               or RV_Offset < 8
     c                               or RV_Offset > 1000
     c                   return    *blanks
     c                   endif

      *   Attach NetAttr structure
     c                   eval      RV_Offset = RV_Offset - 7
     c                   eval      p_NA = %addr(RV_Data(RV_Offset))

      *   -3 = NetAttr structure had data
      *        that we don't understand :(
     c                   if        NA_Attr <> 'SYSNAME'
     c                               or NA_Length < 1
     c                               or NA_Length > 8
     c                   return    *blanks
     c                   endif

      *   -4 = Network attributes are locked
     c                   if        NA_Status = 'L'
     c                   return    *blanks
     c                   endif

      *   Ahhh... we got it!
     c                   eval      SysName = %subst(NA_DataChr:1:NA_Length)
     c                   return    SysName
     P SystemName      E
      *--------------------------------------------------------------------------




      ***************************************************************************
      * RtvDtaAra                                                               *
      *                                                                         *
      * Retrieve Data Area                                                      *
      *                                                                         *
      * Example 1. Get Data Area named ABC from *LIBL                           *
      *    MyField = RtvDtaAra('ABC');                                          *
      *                                                                         *
      * Example 2. Get Data Area named ABC from *LIBL, start in pos 5 for len 3 *
      *    MyField = RtvDtaAra('ABC' : 'MYLIB' : 5 : 3);                        *
      *                                                                         *
      *--------------------------------------------------------------------------
     P RtvDtaAra       B                   Export
     D RtvDtaAra       PI          2000    Varying
     D   DataAreaName                10    const
     D   Library                     10    const options(*nopass)
     D   StartPos                    10i 0 const options(*nopass)
     D   Length                      10i 0 const options(*nopass)

      * Retrieve Data Area - API Prototype
     D RtvDtaAraAPI    PR                  ExtPgm('QWCRDTAA')
     D   prReceiver               32766A   OPTIONS(*VARSIZE)
     D   prReceiverLen...
     D                               10I 0 const
     D   prQualFile                  20    const
     D   prStartPos                  10i 0 const
     D   prDataLen                   10i 0 const
     D   prErrorDS                  256

     D ReceiverPtr     S               *
     D Receiver        DS                  based(ReceiverPtr) qualified
     D  BytesAvail                   10i 0
     D  BytesReturned                10i 0
     D  Type                         10
     D  Lib                          10
     D  Length                       10i 0
     D  Decimal                      10i 0
     D  Value                      2000

     D QualObj         ds            20
     D  wObj                   1     10
     D  wLibrary              11     20

     D Error           ds                  qualified
     D  BytesProv                    10i 0 inz(256)
     D  BytesAvail                   10i 0
     D  ExcID                         7
     D  Reserved                      1
     D  ExcDta                      240

      * Miscellaneous Declarations
     D BytesToAllocate...
     D                 s             10i 0
     D DataAreaLength...
     D                 s             10i 0
     D ReceiverLen     s             10i 0
     D wStartPos       s             10i 0
     D wDataLen        s             10i 0
     D Value           s           2000    Varying

      /free
         //----------------------------------------------
         // Translate inbound parms into work fields
         //----------------------------------------------
         wObj = upper(DataAreaName);

         if %parms >= 2;
            wLibrary = upper(Library);
         else;
            wLibrary = '*LIBL';
         endif;

         if %parms >= 3;
            wStartPos = StartPos;
         else;
            wStartPos = -1;    // causes entire data area to be retrieved
         endif;

         if %parms >= 4;       // wDataLen is ignored by API when wStartPos = -1
            wDataLen = Length;
         else;
            wDataLen = 2000;
         endif;

         //----------------------------------------------
         // Determine how much memory should be allocated
         //----------------------------------------------
         ReceiverPtr = %alloc(36);
         ReceiverLen = 36;

         RtvDtaAraAPI(Receiver    :
                      ReceiverLen :
                      QualObj     :
                      -1          :
                      1           :
                      Error);

         If Error.BytesAvail > *zero;
            dealloc(n) ReceiverPtr;
            return *blanks;    // error occurred
         endif;

         //------------------------
         // Allocate the Memory
         //------------------------
         BytesToAllocate = Receiver.BytesAvail;
         DataAreaLength  = Receiver.Length;   // total length of the data area
         ReceiverPtr = %realloc(ReceiverPtr : BytesToAllocate);
         ReceiverLen = BytesToAllocate;

         //---------------------------------------------------------------------
         // Set the length of the part of the data area which we are to retrieve
         //---------------------------------------------------------------------
         Select;
            when wStartPos = -1;  // forces receipt of entire data area
               wDataLen = DataAreaLength;

            when (wStartPos + wDataLen - 1) > DataAreaLength;
               // requested length is too long.  just give what's available.
               wDataLen = DataAreaLength - wStartPos + 1;

            other;
            // leave wDataLen set as is
         EndSl;

         //------------------------
         // Now get the Data Area
         //------------------------
         RtvDtaAraAPI(Receiver    :
                      ReceiverLen :
                      QualObj     :
                      wStartPos   :
                      wDataLen    :
                      Error);

         If Error.BytesAvail = *zero;
            Value = %subst(Receiver.Value: 1 : wDataLen);
            dealloc(n) ReceiverPtr;
            //----------------------------------------
            // Return the value found in the data area
            //----------------------------------------
            return Value;
         else;
            dealloc(n) ReceiverPtr;
            return *blanks;   // error occurred
         endif;

      /end-free
     P RtvDtaAra       E




dk01  ******************************************************************************
dk01  * Retrieve Prior User Procedure Name from the call stack for the current job *
dk01  *   skips over system procedure names (all those starting with letter "Q"    *
dk01  ******************************************************************************
dk01 P fnGetCallingProgramName...
dk01 P                 B                   export
dk01 D fnGetCallingProgramName...
dk01 D                 PI           276    varying

dk01  * Define parameters for the QWVRCSTK API (Retrieve Call Stack)
dk01 D ReceiverLen     s             10i 0
dk01 D ReceiverFmt     s              8    inz('CSTK0100')
dk01 D JobIDinfoFmt    s              8    inz('JIDF0100')
dk01 D err             s             10i 0

dk01 D JobIDinfo       ds
dk01 D  JobName                      10    inz('*')
dk01 D  JobUser                      10
dk01 D  JobNumber                     6
dk01 D  InternalJobID                16
dk01 D  Reserved01                    2    inz(*Loval)
dk01 D  ThreadIndicator...
dk01 D                               10i 0 inz( 1 )
dk01 D  ThreadID                      8    inz (*Loval)

dk01 D ReceiverPtr     s               *
dk01 D Receiver        ds                  based( ReceiverPtr )
dk01 D  BytesReturned                10i 0
dk01 D  BytesAvail                   10i 0
dk01 D  NotUsed01                    10i 0
dk01 D  EntryOffset                  10i 0
dk01 D  NbrOfEntries                 10i 0
dk01 D  NotUsed02                     8
dk01 D  InfoStatus                    1

dk01 D StackEntryPtr   s               *
dk01 D StackEntry      ds                  based( StackEntryPtr )
dk01 D  EntryLength                  10i 0
dk01 D  NotUsed03                    10i 0
dk01 D  NotUsed04                    10i 0
dk01 D  ProcNameOff                  10i 0
dk01 D  ProcNameLen                  10i 0

dk01  * the following isolates a procedure name in the call stack entry format
dk01 D ProcNamePtr     s               *
dk01 D  ProcName       s            276    based( ProcNamePtr )

dk01  * Miscellaneous Declarations
dk01 D ProcedureName   s            276    varying
dk01 D SkipTwoEntries  s             10i 0
dk01 ‚* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

dk01  * find out how much space to allocate to the receiver variable by
dk01  * calling the API once and checking "BytesAvail".
dk01 C                   eval      ReceiverLen = 8
dk01 C                   alloc     ReceiverLen   ReceiverPtr
dk01 C                   exsr      #GetCallStack

dk01  * call the API to get the call stack for real this time
dk01 C                   eval      ReceiverLen = BytesAvail
dk01 C                   realloc   BytesAvail    ReceiverPtr
dk01 C                   exsr      #GetCallStack

dk01  * Get previous user call stack entry (skip IBM procedures)
dk01 C                   exsr      #GetPrvUsrEnt

dk01 C                   exsr      #exit


dk01  * S U B R O U T I N E S
dk01  * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
dk01 C     #GetPrvUsrEnt begsr
dk01  * Get previous user call stack entry (skip IBM procedures)
dk01  * Stack entries in this list start with the last called procedure
dk01  * SkipTwoEntries: skips this procedure (PriorUserProc) and the immediate
dk01  * calling procedure which for now is only SndSflMsg.

dk01 C                   eval      StackEntryPtr = ReceiverPtr + EntryOffset
dk01 C                   Do        NbrOfEntries
dk01 C                   eval      ProcNamePtr = StackEntryPtr + ProcNameOff

dk01 C                   If        %subst(ProcName : 1 : 1) = 'Q'  or
dk01 C                             %subst(ProcName : 1 : 1) = '_'  or
dk01 C                             SkipTwoEntries < 2
dk01 C                   eval      StackEntryPtr = StackEntryPtr + EntryLength
dk01 C                   eval      SkipTwoEntries = SkipTwoEntries + 1
dk01 C                   Else
dk01 C                   eval      ProcedureName =
dk01 C                                  %subst(ProcName : 1 : ProcNameLen)
dk01 C                   leaveSR
dk01 C                   Endif

dk01 C                   Enddo

dk01 C                   eval      ProcedureName = *Blanks
dk01 C                   exsr      #exit

dk01 C                   endsr
dk01 ‚* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
dk01 C     #GetCallStack begsr
dk01 C                   call      'QWVRCSTK'
dk01 C                   parm                    Receiver                       O
dk01 C                   parm                    ReceiverLen                    I
dk01 C                   parm                    ReceiverFmt                    I
dk01 C                   parm                    JobIDinfo                      I
dk01 C                   parm                    JobIDinfoFmt                   I
dk01 C                   parm                    err                            B

dk01 C                   If        ( ReceiverLen > 8  ) and
dk01 C                             ( InfoStatus = 'N' )
dk01 C                   eval      ProcedureName = *Blanks
dk01 C                   exsr      #exit
dk01 C                   Endif

dk01 C                   endsr
dk01 ‚* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

dk01 C     #Exit         begsr
dk01 C                   dealloc(N)              ReceiverPtr
dk01 C                   return    ProcedureName
dk01 C                   endsr

dk01 P fnGetCallingProgramName...
dk01 P                 E




      *##########################     *##########################    *##########################
      * NON-EXPORTED PROCEDURES *     * NON-EXPORTED PROCEDURES *    * NON-EXPORTED PROCEDURES *
      *##########################     *##########################    *##########################



      ***************************************************************************
      * Retrieve Job Information (QUSRJOBI API)                                 *
      *                                                                         *
      * Note: Returns selected info from the RtvJobInf API for the current job. *
      *                                                                         *
      *--------------------------------------------------------------------------
     P RtvJobInf       B
     D RtvJobInf       PI
     D  JobType                       1

     D receiver        ds            86
     D  bytesReturned                10u 0
     D  bytesAvail                   10u 0
     D  rtvJobName                   10
     D  rtvJobUser                   10
     D  rtvJobNumber                  6
     D  rtvIntJobID                  16
     D  rtvJobStatus                 10
     D  rtvJobType                    1

     D receiverLen     s             10u 0
     D format          s              8
     D qualJob         s             26
     D internalJobID   s             16
      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     C                   call      'QUSRJOBI'
     C                   parm                    receiver
     C                   parm      86            receiverLen
     C                   parm      'JOBI0100'    format
     C                   parm      '*'           qualJob
     C                   parm      *blanks       internalJobID

     C                   eval      JobType = rtvJobType

     C                   return

     P RtvJobInf       E
      *--------------------------------------------------------------------------

