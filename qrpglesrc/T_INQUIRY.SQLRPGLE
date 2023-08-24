**FREE
        // T_INQUIRY - Template Inquiry Application

        // TEST: call t_inquiry (x'000F' x'000000000F' ' ')

        // Program Change Log
        //-------------------------------------------------------------------------
        // Date       Programmer Project  Scan Desc
        // 2023-08-13 Keck/Clay  Template      Created

        // External Function References
        // *------------------------------
        // Function          ServiceProgram BindingDirectory Purpose
        // ----------------  -------------- ---------------- ---------------------------------------
        // WinMsg            MESSAGE        BLUESTAR         Display 3 line message window
        // DoubleSquote      STRING         BLUESTAR         Replace all single quotes (') with
        //                                                   two single quotes ('').
        // Quote             STRING         BLUESTAR         Enclose a given string with single quot
        //------------------------------------------------------------------------------------------

       ctl-Opt option(*nodebugio : *srcstmt) dftactgrp(*no) actgrp('QILE') indent('| ');
       ctl-Opt bnddir('BLUESTAR');
        //-------------------------------------------------------------------------
       dcl-f t_Inquiry WORKSTN Prefix(s_) Sfile( Sfl : RRN ) infds( info );
       dcl-f divmst usage(*input) keyed prefix(div_);

        //-------------------------------------------------------------------------
        // Prototypes
       /define PROTOTYPES
       /include nbtygpl/qrpglesrc,MESSAGE
       /include nbtygpl/qrpglesrc,STRING
       /undefine PROTOTYPES

      //  Dcl-PR DisplayCustomerRecord  extpgm('CSTDET1');
      //    Division       Packed(2:0);
      //    CustomerID     Packed(9:0);
      //   End-PR;


        // Entry Parameters
       dcl-pi *n;
         Division     like(div_dmnum);         // define like DIVMST column
         Customer     like(CustomerDS.cmnum);  // define like CSTMST data structure column
         ShowSelectYN char(1);
       end-pi;

        // Indicator Data Structure
       Dcl-S IndPtr       Pointer    inz(%addr(*in));
       Dcl-DS *n  based( IndPtr );
         ExitRequested             Ind  pos(3);
         ClearPositionersRequested Ind  pos(10);
         ShowSelect                Ind  pos(56);
         SflDsp                    Ind  pos(71);
         SflDspCtl                 Ind  pos(72);
         SflClr                    Ind  pos(73);
         SflEnd                    Ind  pos(74);
         RollUpRequested           Ind  pos(75);
         SflNxtChg                 Ind  pos(76);
        End-DS;


        // Variables
       Dcl-S ChangedSubfileRecordFound Ind;
       Dcl-S count                     Zoned(4:0);
       Dcl-S CustName10                Char(10);
       Dcl-S defaultDate               Date  inz(d'0001-01-01');
       Dcl-C DUPKEY                    const(01021);
       Dcl-C ENTER                     const(x'F1');
       Dcl-S ErrorOccurred             Ind;
       Dcl-C FALSE                     const('0');
       Dcl-S FirstSflRRN               Zoned(4:0);
       Dcl-S KeepPositionerValues      Ind;
       Dcl-S NextRRNtoAdd              Zoned(4:0);
       Dcl-S Option                    Char(10);
       Dcl-S OrderBy                   Char(100);
       Dcl-S PreviousNameCt            like(s_NameCt);
       Dcl-S PreviousCust              like(s_CustNo);
       Dcl-S PreviousName10            like(s_Name10);
       Dcl-C RecordLock                const(01218);
       Dcl-S ReloadTheSubfile          Ind;
       Dcl-S returnNullSet             Ind;
       Dcl-S RRN                       Zoned(4:0) inz( *zero );
       Dcl-S SflPage                   Zoned(4:0) inz( 14 );
       Dcl-S sql                       Varchar(512);
       Dcl-S string                    Char(50);
       Dcl-S TopRecOnPage              Ind;
       Dcl-C TRUE                      const('1');
       Dcl-S User                      Char(10)   inz(*User);
       Dcl-S wCustNo                   Packed(9:0);
       Dcl-S wDivision                 Packed(2:0);

        // Customer Master
       Dcl-DS CustomerDS  extname('CSTMST') qualified;
        End-DS;

        // File Information Data Structure for WRKSTN file
       Dcl-DS info;
       KeyPress       Char(1)    Pos(369);
       LastSflRRN     Int(5)     Pos(380);  // last Sfl record number on the subfile
       End-DS;

        // Program Status Data Structure
       Dcl-DS psds ext PSDS extname('PSDS')  prefix( psds_ );
       End-DS;
        //-------------------------------------------------------------------------


        EXEC SQL  set option commit=*none;

        exsr init; // initialization

         DoU ExitRequested;
            write Footer;       // there is no pos on the footer
            exfmt SflCtl;
            exsr Process;
         EndDo;

         exsr ExitPgm;




       // S U B R O U T I N E S
       // *---------------------------------------------------------------------------------------
         begsr Process;

            Select;
               When ExitRequested;
                  // clear the outbound parameters and exit the program
                  CustName10 = *blanks;
                  Division   = *zero;
                  Customer   = *zero;
                  LeaveSR;

               When ClearPositionersRequested;
                  exsr ClearPositioners;  // clear the subfile positioners
                  exsr ReLoadSubfile;

               When RollUpRequested;
                  exsr LoadSubfilePage;

               When  s_NameCt   <> PreviousNameCt
                 or  s_CustNo   <> PreviousCust
                 or  s_Name10   <> PreviousName10;
                  exsr ReLoadSubfile;

               When KeyPress = ENTER;  // user pressed the Enter Key
                  exsr ProcessChangedSubfileRecords;

            EndSl;

         endsr;
       // *---------------------------------------------------------------------------------------
         begsr ProcessChangedSubfileRecords;

            s_RRN = s_TopRRN;       // keep subfile positioned on same page by default
            ChangedSubfileRecordFound = False;
            ErrorOccurred = False;
            ReloadTheSubfile = False;

            if rrn < 1;
               leaveSR;  // empty subfile
            endif;

            READC SFL;
            dow not %EOF;
               // work version of subfile fields to prevent subfile coruption on pgm calls
               wDivision = s_zDiv;
               wCustNo   = s_zCustNo;

               select;
                  // Customer Record Selected - Exit Program
                  when s_zOpt = '1' and ShowSelect = TRUE;
                     CustName10    = s_zName10;
                     Division      = s_zDiv;
                     Customer      = s_zCustNo;
                     s_zOpt        = *blank;   // subfile selector
                     UPDATE Sfl;

                     s_RRN   = rrn;    // position screen cursor
                     ExitRequested = True;

                  // Sample procedure or external program call
                  // when s_zOpt = '2';
                  //    DisplayCustomerRecord(wDivision: wCustNo);
                  //    s_zOpt = *blank;
                  //    UPDATE Sfl;
                  //    s_RRN   = rrn;    // position screen cursor

                  other;
                     s_zOpt = *blank;
                     UPDATE Sfl;
                     s_RRN   = rrn;    // position screen cursor
               endsl;

               READC SFL;
            enddo;

            select;
              when ErrorOccurred;

              when ReloadTheSubfile = TRUE;
                 exsr ReLoadSubfile;
            endsl;

         endsr;
       // *---------------------------------------------------------------------------------------
         begsr ReLoadSubfile;

            exsr ClearSubfile;
            exsr PrepareSQL;
            exsr LoadSubfilePage;

            // save the subfile positioner values
            PreviousNameCt      = s_NameCt;   // Customer Name Contains
            PreviousCust        = s_CustNo;   // Customer ID
            PreviousName10      = s_Name10;   // 10 position short cust name

         endsr;
       // *---------------------------------------------------------------------------------------
         begsr LoadSubfilePage;  // This is an expanding subfile.  Add one page.

            rrn = LastSflRRN;
            TopRecOnPage = True;
            Count = *zero;

            dow (count < SflPage)  AND  (rrn < 9999);

               EXEC SQL  FETCH NEXT FROM C1 into :CustomerDS;
               if sqlcod <> 0;
                  Leave;
               endif;

               rrn          = rrn + 1;
               count        = count + 1;
               s_zOpt       = *blank;
               s_zDLTFLG    = CUSTOMERDS.CMDEL;
               s_zName      = CustomerDS.CMNAME;
               s_zCity      = CustomerDS.CMCITY;
               s_zState     = CustomerDS.CMST;
               s_zZip5      = CustomerDS.CMZIP1;
               s_zCustNo    = CustomerDS.CMNUM;
               s_zDiv       = CustomerDS.CMDIV;
               s_zName10    = CustomerDS.CMALPH;
               WRITE sfl;

               if TopRecOnPage = True;    // save top rrn for cursor positioning
                  FirstSflRRN = rrn;
                  TopRecOnPage = False;
               endif;
            enddo;

            if rrn = *zero;
               SflDsp = *off;
               s_rrn = 1;         // display first subfile page (SFLRCDNBR parm)
            else;
               SflDsp = *on;
               s_rrn = FirstSflRRN;       // display the page just added
            endif;

            // Set the '*More' flag indicator (SFLEND)
               EXEC SQL  FETCH NEXT FROM C1 into :CustomerDS;
            if sqlcod <> 0;
               SflEnd = *on;
            else;
               SflEnd = *off;
               EXEC SQL  FETCH PRIOR FROM C1 into :CustomerDS;  // move the file cursor back
            endif;

         endsr;
       // *---------------------------------------------------------------------------------------
         begsr ClearSubfile;

            SflClr = *on;
            SflDsp = *off;
            SflDspCtl = *off;

            WRITE SflCtl;

            SflClr = *off;
            SflDspCtl = *on;
            rrn = *zero;
            NextRRNtoAdd = 1;
            s_rrn = 1;         // display first subfile page (SFLRCDNBR parm)

         endsr;
       // *---------------------------------------------------------------------------------------
         begsr PrepareSQL;  // prepare Stmt1 to enable subfile load

            OrderBy = *blanks;
            EXEC SQL  close C1;

            sql = 'Select cst.* from CSTMST cst ';

            // ------------------------
            // Build the Where clause
            // ------------------------
            If s_NameCt   <> *blanks
            or s_CustNo   <> *zero
            or s_Name10   <> *blanks;
               returnNullSet = False;
            else;
               returnNullSet = True; // display empty subfile if no selections
            endif;

            // -----------------------------------------------------------
            // Add where conditions
            // -----------------------------------------------------------
            sql = sql + 'Where 1=1';

            if s_Name10 <> *blanks;
          string = doubleSquote(s_Name10);
               string =  %trim(string) + '%';
               sql = sql + ' and ' + 'CMALPH like ' + quote(string) + ' ';
            endif;

            if s_CustNo <> *zero;
               sql = sql + ' and ' +'CMNUM = ' + %editc(s_CustNo: 'X') + ' ';
            endif;

            if s_NameCt <> *blanks;  // Customer Name Contains
               // replace single quotes (') with two single quotes ('')
               string = doubleSquote(s_NameCt);
               string =  '%' + %trim(string) + '%';
               sql = sql + ' and ' + 'CMNAME like ' + quote(string) + ' ';
            endif;

            // return null set (no records) if all search criteria left blank
            if returnNullSet;
               sql = sql + ' and ' + 'cmnum is NULL ';
            endif;

            // --------
            // Order By
            // --------
            sql = sql + ' Order by CMNAME';

            EXEC SQL  prepare Stmt1 from :SQL;
            if sqlcod <> 0;
               winmsg('Error occurred preparing SQL statement');
            endif;

            EXEC SQL  declare C1 dynamic scroll cursor for Stmt1;
            if sqlcod <> 0;
               winmsg('Error occurred declaring SQL statement');
            endif;

            EXEC SQL  open C1;
            if sqlcod <> 0;
               winmsg('Error occurred opening SQL cursor');
            endif;

         endsr;

       // *---------------------------------------------------------------------------------------
         begsr ClearPositioners; // clear the subfile positioners
               clear s_NameCt;
               clear s_CustNo;
               clear s_Name10;
               // the ReloadSubfile routine will reset the previous* fields
         endsr;
       // *---------------------------------------------------------------------------------------
         begsr init; // initialization every time

            if Customer <> *zero;
               s_CustNo = Customer;  // set subfile positioner based on inbound parameter
               if s_CustNo <> PreviousCust;
                  exsr ReLoadSubfile;
               endif;
            endif;

            // control display of subfile option "1=Select" (should be suppressed from menu's)
            ShowSelect = TRUE; // default
            if %parms >= 3;
               if ShowSelectYN <> 'Y'; // 3rd inbound parameter
                  ShowSelect = FALSE;
               endif;
            endif;

         endsr;
       // *---------------------------------------------------------------------------------------
         begsr *inzsr; // first pass initialization only

            s_Pgm = psds_pgm;     // Move program name to screen field

            // check if user wants subfile positioner values to be kept
            // from one call to the next.  If positioner values are to be kept
            // then do NOT set on LR when exiting program.
            KeepPositionerValues = TRUE;  // default ... do not keep the positioner values

            // initial load of the subfile
            exsr ClearSubfile;
            exsr PrepareSQL;
            exsr LoadSubfilePage;

         endsr;
       // *---------------------------------------------------------------------------------------
         begsr ExitPgm;
            if KeepPositionerValues = FALSE;
               *inLR = *on; // shut down program on exit
            endif;

            return;

         endsr;









        //******************************
        // S U B - P R O C E D U R E S *
        //******************************


