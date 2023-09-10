      /If not Defined (PROTOTYPE)
      /include QGPL/QSRVSRC,QILEHeader
     H Bnddir('QC2LE':'RXSBND':'TOOLBIND':'STRINGSP')
     H bnddir('RPGMAIL')

      * The order in which the members should be implemented is:-
      * 1/.  USPSsp (BNDSRC) binding source
      * 2/.  USPSsp (SRVMOD) service module
      * 3/.  USPSsp (SRVPGM) service program

      * When implementing the service program, use
      * option 1 (Override creation attribute) with the following
      * parameters:-
      * Service program  . . . . . . . . > USPSsp
      *   Library  . . . . . . . . . . . >   #PGMLIB
      * Module . . . . . . . . . . . . .   USPSsp
      *   Library  . . . . . . . . . . .     *LIBL
      * Export . . . . . . . . . . . . . > *srcfile
      * Export source file . . . . . . .   QBNDSRC
      *   Library  . . . . . . . . . . .     NBTYGPL
      * Export source member . . . . . .   USPSBN
      *
      **********************************************************************************************
      * Description: United States Postal Service Service Procedures
      *
      * Programmer:  Linda Buonasera
      * Date:        November, 2017
      **********************************************************************************************
‚     **********************************************************************
‚     * MODIFICATIONS:
‚     * -------------
‚     *   Date      PGMR     MOD     Reasons
‚     * --------  ---------  ----  -----------------------------------------
      * 04/19/18  LBuonasera lxb01 -USPS does not supply days in transit for
      *                            APO/FPO/DPO addresses, and an error is
      *                            being thrown. We will trap for this message
      *                            and default as 3 days.
      *                            -Change email distribution list to IT Direct
      *                            Response.
      *                            -If we get a server type error from USPS,
      *                            try one more time.
‚     **********************************************************************

     fUSPSPMDIT uf a e           k disk    prefix(UPD_) usropn
     fUSPSPMERRPo    e           k disk    prefix(ERR_) usropn
     fWCFSvcCtl if   e           k disk    prefix(wcf_) usropn

      /include rxs,RXSCp
      /include protype,xmlpr
      /include protype,stringpr
      /include copybook,psds
      /include copybook,FKeys
      /include qsource,RPGMailCP

      /Define PROTOTYPE
      /Include qsrvsrc,fnjobapi
      /Undefine PROTOTYPE

      // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
      // Execute Command (system) Subprocedure Variables
     D System          PR            10I 0 ExtProc('system')
     D  CmdText                        *   Value Options(*String)

     D ErrorCPF        S              7A   Import('_EXCP_MSGID')
     D ErrorFlag       S             10I 0 Inz(0)

      // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -

     D RtvJobInf       PR                  ExtPgm('QUSRJOBI')
     D   RcvVar                   32766A   options(*varsize)
     D   RcvVarLen                   10I 0 CONST
     D   Format                       8A   CONST
     D   JobName                     26A   CONST
     D   IntJobID                    16A   CONST
     D   ErrorCode                32766A   options(*varsize)

     D dsJobI0100      DS                  qualified
     D   ByteRtn                     10I 0
     D   ByteAvl                     10I 0
     D   JobName                     10A
     D   UserID                      10A
     D   JobNbr                       6A
     D   IntJob                      16A
     D   Status                      10A
     D   Type                         1A
     D   SbType                       1A
     D   Reserv1                      2A
     D   RunPty                      10I 0
     D   TimeSlc                     10I 0
     D   DftWait                     10I 0
     D   Purge                       10A

     D dsEC            DS                  qualified
     D  BytesP                 1      4I 0 INZ(256)
     D  BytesA                 5      8I 0 INZ(0)
     D  MsgID                  9     15
     D  Reserv                16     16
     D  MsgDta                17    256
      // - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -

     D sleep           Pr            10U 0 ExtProc('sleep')
     D                               10U 0 Value

      //*-----------------------------------------------------------------------
      //*     Non-Exported Prototypes for Procedures used just in this SrvPgm
      //*-----------------------------------------------------------------------

      //*-----------------------------------------------------------------------
      //*                     Non-Exported Global Constants
      //*-----------------------------------------------------------------------
     d TRUE            c                   '1'
     d FALSE           c                   '0'
     d TRUEWORD        c                   'true'
     d FALSEWORD       c                   'false'
     d ERRORELEMENT    c                   '/Error'

      //*-----------------------------------------------------------------------
      //*                Non-Exported Global Variables / Arrays
      //*-----------------------------------------------------------------------
     d gError          ds                  likeds(RXS_Error)
     d gInCfg          ds                  likeds(RXS_GetUriIn) inz
     d gRspData        s                   like(RXS_XMLData)
     d gRspHttpHdr     s                   like(RXS_XMLData)
     d gReqData        s                   like(RXS_XMLData)
lb01 d gReqSTMF        s                   like(RXS_FilePath)
lb01 d gRspSTMF        s                   like(RXS_FilePath)
     d gSOAPElement    s                   like(wcf_SOAPElmt)
     d today           s               D
     d numOriginZip    s              5  0
     d numDestinationZip...
     d                 s              5  0
     d Email_body      s            512
     d Email_subj      s            512
     D CR              C                   x'0D25'
     d gSMTPHostAddress...
     d                 s            256    dtaara(smtpAddr)
     d gSMTPHostPort   s              5    dtaara(smtpPort)
      //*-----------------------------------------------------------------------
      //*                   Non-Exported Global Data Structures
      //*-----------------------------------------------------------------------
     d gPriorityMailResults...
     d                 ds                  likeds(rtnPriorityMailDS)
     d                                     inz


      //*-----------------------------------------------------------------------
      //*                   Non-Exported Data Areas
      //*-----------------------------------------------------------------------
     d gUSPSUserId...
     d                 s             50    dtaara(USPSUSERID)

       //-------------------------------------------------------------------------------------------
       // Non-Exported ProtoTypes
       //-------------------------------------------------------------------------------------------
     d validatePriorityMail...
     d                 pr
     d  pUserId                      50    const
     d  pOriginZipCode...
     d                                5    const
     d  pDestinationZipCode...
     d                                5    const

     d composePriorityMail...
     d                 pr
     d  puserid                      50    const
     d  pOriginZipCode...
     d                                5    const
     d  pDestinationZipCode...
     d                                5    const
     d  pDebug                         n   const options(*nopass)

     d parsePriorityMail...
     d                 pr

     d prPriorityMailHandler...
     d                 pr
     d  pEvntType                          value like(RXS_Type)
     d  pXPath                             value like(RXS_XPath)
     d  pData                              value like(RXS_XmlData)
     d  pDataLen                           value like(RXS_Length)

     d prPriorityMailErrHandler...
     d                 pr
     d  pCurLine                     10i 0 value
     d  pCurCol                      10i 0 value
     d  pErrStr                    1024a   value varying

     d getCallingProgram...
     d                 pr            10a

     d transmitRequest...
     d                 pr
     d  inURI                              const like(wcf_URIPath)
     d  inSOAPOper                         const like(wcf_WCFOper)
     d  inDebug                        n   const options(*nopass)

     d dumpXMLVar...
     d                 pr
     d inXMLVar                            const like(gRspData)

     d sendEmail...
     d                 pr
     d InEmail_body                 512
     d InEmail_subj                 512

      //*-----------------------------------------------------------------------
      /EndIf



      //*=======================================================================
      //* Begin of Components to be copied via /Include by other PGMs / SRVPGMs
      //*=======================================================================

      //*-----------------------------------------------------------------------
      //*                    Exported Prototype Definitions
      //*-----------------------------------------------------------------------
     d PriorityMail...
     d                 pr                  likeds(rtnPriorityMailDS)
     d  pOriginZipCode...
     d                                5    const
     d  pDestinationZipCode...
     d                                5    const
     d  pDebug                         n   const options(*nopass)
     d  pLR                            n   const options(*nopass)

      //------------------------------------------------------------------------
      //* Return Structure for PriorityMail
      //------------------------------------------------------------------------
     d rtnPriorityMailDS...
     d                 ds                  qualified
     d                                     based(templatePtr)
     d  originZipCode                 5
     d  destinationZipCode...
     d                                5
     d  daysInTransit                 3
     d  error                              likeds(errorDS)

      //*-----------------------------------------------------------------------
      //*                         Exported Constants
      //*-----------------------------------------------------------------------
     d NOXMLRESPONSE   c                   'No Response Received in the -
     d                                     XML Data'
     d EMPTYXMLRESPONSE...
     d                 c                   'Received an empty XML response'
     d FAULTERROR      c                   'Fault Error Received'
     d YES             c                   'Y'
     d NO              c                   'N'
     d GENERAL_ERROR...
     d                 c                   'GENERAL_ERROR'
     d SERVER_FAILED   c                   'SERVER_FAILED'
lxb01d APOMESSAGE      c                   'The origin and/or destination +
     d                                      ZIP Code supplied is an +
     d                                      APO/FPO/DPO ZIP code. +
     d                                      Priority Mail service standards +
     d                                      to this location are not available.'
      //*-----------------------------------------------------------------------
      //*                     Exported Variables / Arrays
      //*-----------------------------------------------------------------------

      //*-----------------------------------------------------------------------
      //*                       Exported Data Structures
      //*-----------------------------------------------------------------------
     d errorDS         ds                  qualified
     d                                     based(templatePtr)
     d  hasError                       n
     d  code                         50a
     d  message                     128a

      //*=======================================================================
      //* End of Components to be copied via /Include by other PGMs / SRVPGMs
      //*=======================================================================

      //*-----------------------------------------------------------------------
      /If Defined(PROTOTYPE)
      /EOF
      /EndIf



      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
      //*          P R O C E D U R E   priorityMail
      //* This procedure receives a FROM and TO Zip code and returns the number
      //* of days in transit.
      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     p priorityMail...
     p                 b                   export

     d priorityMail...
     d                 pi                  likeds(rtnPriorityMailDS)
     d  pOriginZipCode...
     d                                5    const
     d  pDestinationZipCode...
     d                                5    const
     d  pDebug                         n   const options(*nopass)
     d  pLR                            n   const options(*nopass)

     d wkDebug         s               n

      /free

       clear gPriorityMailResults;
       clear gError;
       clear gInCfg;
       clear gRspData;
       clear gRspHttpHdr;
       clear gReqData;
       clear gSOAPElement;

       if %parms() > 3  and pLR;
         exsr cleanUp;

       else;
         exsr initialize;
         if not gPriorityMailResults.error.hasError;
           validatePriorityMail(gUSPSUserID:pOriginZipCode:
                                      pDestinationZipCode);

           if not gPriorityMailResults.error.hasError;
             clear wkDebug;
             if %parms() > 2;
               wkDebug = pDebug;
             endif;
             today = %date();
             Chain (today:numoriginzip:numdestinationzip) uspspmdit;
             If %found(uspspmdit);
               gPriorityMailResults.OriginZipCode = %editc(upd_uorgzip:'X');
               gPriorityMailResults.DestinationZipCode =
                                                  %editc(upd_udstzip:'X');
               gPriorityMailResults.DaysInTransit = %editc(upd_udysintrn:'X');
             Else;
             // Get the WCFSVCCTL Web Service Control Data
             if not %open(WCFSvcCtl);
               open WCFSvcCtl;
             endif;

             wcf_WCFId = 'PriorityMail';
             chain wcf_WCFId WCFSvcCtl;
             if not %found(WCFSvcCtl);
               gPriorityMailResults.error.hasError = TRUE;
               gPriorityMailResults.error.code = 'WCFSETUP';
               gPriorityMailResults.error.message =
                    'WCFSvcCtl record not found for '+
                    'PriorityMail.';
             endif;
             close WCFSvcCtl;
             gSOAPElement = wcf_SOAPElmt;
             if not gPriorityMailResults.error.hasError;
               composePriorityMail(gUSPSUserId:
                                   pOriginZipCode:
                                   pDestinationZipCode:
                                   wkDebug);
               if gError.code <> *blanks;
                 gPriorityMailResults.error.hasError = TRUE;
                 gPriorityMailResults.error.code = gError.code;
                 gPriorityMailResults.error.message = gError.Text;

               else;
                 transmitRequest(wcf_URIPath:wcf_WCFOper:WkDebug);
lxb01            if gerror.code = 'RXS0000010';                                //server error
lxb01              clear gerror;                                               //clear error
                   sleep(10);
lxb01              transmitRequest(wcf_URIPath:wcf_WCFOper:WkDebug);           //try again once
lxb01            endif;
                 if gError.code <> *blanks;
                   gPriorityMailResults.error.hasError = TRUE;
                   gPriorityMailResults.error.code = gError.code;
                   gPriorityMailResults.error.message = gError.text;

                 else;
                   parsePriorityMail();
                   if gError.code <> *blanks;
                     gPriorityMailResults.error.hasError = TRUE;
                     gPriorityMailResults.error.code = gError.code;
                     gPriorityMailResults.error.message = gError.text;
                   Else;
                     If gpriorityMailresults.error.haserror <> TRUE;
                       upd_udateupd = %date();
                       upd_uorgzip =
                             %dec(gpriorityMailResults.OriginZipCode:5:0);
                       upd_udstzip =
                             %dec(gPriorityMailResults.DestinationZipCode:5:0);
                       upd_udysintrn =
                             %dec(gPriorityMailResults.DaysInTransit:3:0);
                       Write uspspmditr;
                     EndIf;
                   endif;
                 endif;
               endif;
             endif;
             EndIf;
           endif;
         endif;
       endif;
       If gPriorityMailResults.error.hasError = TRUE;
         err_etimstmp = %timestamp();
         err_EPGMNAM  = getCallingProgram();
         err_EORGZIP = pOriginZipCode;
         err_EDSTZIP = pDestinationZipCode;
         err_eerrcode = gPriorityMailResults.error.code;
         err_eerrtext = gPriorityMailResults.error.message;
         err_EREQUEST = greqdata;
         err_ERESPONSE= grspdata;
         Write uspspmerr;
         Email_subj = 'PriorityMail Days In Transit call Ended in Error';
         Email_body = 'PriorityMail Days In Transit call Ended in Error.' +
                      CR +
                      'The PriorityMail service program in ' +
                      'QSRVSRC/USPSSP failed when called from ' +
                      'program ' + err_epgmnam +
                      ' at ' + %char(err_etimstmp) + '.' +
                      CR +
                      'Check PRODFA/USPSPMERRP file for details.';
         sendEmail(Email_body:Email_subj);
       EndIf;

       *inlr = *on;
       return gPriorityMailResults;

       //=======================================================================
       //                       Initialize Procedure
       //=======================================================================
        begSr initialize;

       if not %open(USPSPMDIT);
         open(e) USPSPMDIT;
         if %error();
           gPriorityMailResults.error.hasError = TRUE;
           gPriorityMailResults.error.code = 'INIT';
           gPriorityMailResults.error.message = 'Error opening '+
                            'the USPS Pm days in transit '+
                            'file, USPSPMDIT';
         endIf;
       endif;

        In(e) gUSPSUserID;
        If %error();
         gPriorityMailResults.error.hasError = TRUE;
         gPriorityMailResults.error.code = 'INIT';
         gPriorityMailResults.error.message =
                                    'Unable to retrieve the USPS '+
                                    'User Id value from data area USPSUSERID.';
        endif;
       if not %open(USPSPMERRP);
         open(e) USPSPMERRP;
         if %error();
           gPriorityMailResults.error.hasError = TRUE;
           gPriorityMailResults.error.code = 'INIT';
           gPriorityMailResults.error.message = 'Error opening '+
                            'the USPS PM error file, USPSPMERRP';
         endIf;
       endif;

        endSr;


       //=======================================================================
       //                           Clean Up
       //=======================================================================
        begSr cleanUp;

       if %open(USPSPMDIT);
         close USPSPMDIT;
       endif;
       if %open(USPSPMERRP);
         close USPSPMERRP;
       endif;

        endSr;

      /end-free

     p priorityMail...
     p                 e



      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
      //*      P R O C E D U R E   validatePriorityMail
      //*
      //* Validate the paramters passed into PriorityMail
      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     p validatePriorityMail...
     p                 b

     d validatePriorityMail...
     d                 pi
     d  pUserId                      50    const
     d  pOriginZipCode...
     d                                5    const
     d  pDestinationZipCode...
     d                                5    const


      /free

       clear gPriorityMailResults;

       select;
         when puserId = *blanks;
           gprioritymailResults.error.hasError = TRUE;
           gprioritymailResults.error.code = 'UserId';
           gprioritymailResults.error.message = 'UserId is blanks';

         when pOriginZipCode = *blanks;
           gpriorityMailResults.error.hasError = TRUE;
           gprioritymailResults.error.code = 'OriginZipCode';
           gprioritymailResults.error.message = 'Blank Origin Zip Code';

         when pDestinationZipCode = *blanks;
           gprioritymailResults.error.hasError = TRUE;
           gprioritymailResults.error.code = 'DestinationZipCode';
           gprioritymailResults.error.message = 'Blank Destination Zip Code';

       endsl;
       monitor;
           numoriginzip = %dec(pOriginZipCode:5:0);
           numDestinationZip = %dec(pDestinationZipCode:5:0);
       on-error;
           gprioritymailResults.error.hasError = TRUE;
           gprioritymailResults.error.code = 'Non-Numeric Zip';
           gprioritymailResults.error.message =
                                       'Either the Origin or Destination '+
                                       'Zip Code is not numeric';
       endmon;

      /end-free

     p validatePriorityMail...
     p                 e



      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
      //*      P R O C E D U R E   composePriorityMail
      //*
      //* Compose the XML Web Service for PriorityMail
      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     p composePriorityMail...
     p                 b

     d composePriorityMail...
     d                 pi
     d  pUserId                      50    const
     d  pOriginZipCode...
     d                                5    const
     d  pDestinationZipCode...
     d                                5    const
     d  pDebug                         n   const options(*nopass)

     d wkDebug         s               n

      /free

       clear gReqData;
       clear wkDebug;

       // see if degug parameter was passed in
       if %parms()>4;
         wkDebug = pDebug;
       endif;

       monitor;
         RXS_initTplEng(RXS_VAR: *omit: *omit: *omit: *omit: wkDebug);
         //gReqData = 'API=PriorityMail'+
         // '&XML=' +
         // '<PriorityMailRequest USERID="' + %trim(puserid) + '">' +
         // '<OriginZip>' + %trim(pOriginZipCode) + '</OriginZip>' +
         // '<DestinationZip>' +%trim(pDestinationZipCode) +
         // '</DestinationZip>' +
          //'</PriorityMailRequest>';
          gReqData = 'API=PriorityMail'+
           '&XML=' +
           '%3CPriorityMailRequest USERID="' + %trim(puserid) + '"%3E' +
           '%3COriginZip%3E' + %trim(pOriginZipCode) + '%3C/OriginZip%3E' +
           '%3CDestinationZip%3E' +%trim(pDestinationZipCode) +
           '%3C/DestinationZip%3E' +
           '%3C/PriorityMailRequest%3E';
       on-error;
         gError = RXS_catchError();
       endmon;

      /end-free

     p composePriorityMail...
     p                 e



      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
      //*      P R O C E D U R E   parsePriorityMail
      //*
      //* Parse the returned XML stream from PriorityMail
      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     p parsePriorityMail...
     p                 b

     d parsePriorityMail...
     d                 pi

      /free

       monitor;

         if gRspData <> ' ';
           RXS_addHandler(%trim(gSOAPElement)+'/':
                          %paddr(prPriorityMailHandler));
           RXS_addHandler(ERRORELEMENT+'/':
                          %paddr(prPriorityMailHandler));
           RXS_allElemContentHandler(
                          %paddr(prPriorityMailHandler));
           RXS_parse(%trim(gRspData): RXS_VAR:
                     %paddr(prPriorityMailErrHandler));

         else;
           gPriorityMailResults.error.hasError = '1';
           gPriorityMailResults.error.code = 'NORESP';
           gPriorityMailResults.error.message = EMPTYXMLRESPONSE;
         endif;

       on-error;
         gError = RXS_catchError();
       endmon;

      /end-free

     p parsePriorityMail...
     p                 e



      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
      //*      P R O C E D U R E   prPriorityMailHandler
      //*
      //* XML Parse handler for PriorityMail
      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     p prPriorityMailHandler...
     p                 b

     d prPriorityMailHandler...
     d                 pi
     d  pEvntType                          value like(RXS_Type)
     d  pXPath                             value like(RXS_XPath)
     d  pData                              value like(RXS_XmlData)
     d  pDataLen                           value like(RXS_Length)

      /free

       select;

         when pXPath = %trim(gSOAPElement) + '/';
           clear gPriorityMailResults.error;

         when pXPath = ERRORELEMENT + '/';
           gPriorityMailResults.error.hasError = TRUE;
           gPriorityMailResults.error.code = 'FAULT';
           gPriorityMailResults.error.message = FAULTERROR;

         when pXPath = ERRORELEMENT + '/Number/';
           gPriorityMailResults.error.hasError = TRUE;
           gPriorityMailResults.error.code = %trim(pdata);

         when pXPath = ERRORELEMENT + '/Source/';
           gPriorityMailResults.error.hasError = TRUE;
           gPriorityMailResults.error.message = %trim(pData);

         when pXPath = ERRORELEMENT + '/Description/';
           gPriorityMailResults.error.hasError = TRUE;
           gPriorityMailResults.error.message =
           %trim(gPriorityMailResults.error.message) + ' ' + %trim(pData);

         when pXPath = '/PriorityMailResponse/OriginZip/';
           gPriorityMailResults.OriginZipCode = %trim(pData);

         when pXPath = '/PriorityMailResponse/DestinationZip/';
           gPriorityMailResults.DestinationZipCode = %trim(pData);

         when pXPath = '/PriorityMailResponse/Days/';
lxb01      If pData = 'Military Mail';
lxb01        gPriorityMailResults.DaysInTransit = '003';
lxb01      Else;
           If pData = 'No Data';
             gPriorityMailResults.error.hasError = TRUE;
             gPriorityMailResults.error.code = pData;
           Else;
             gPriorityMailResults.DaysInTransit =
               %editc(%dec(%trim(pData):3:0):'X');
           Endif;
lxb01      Endif;
         when pXPath = '/PriorityMailResponse/Message/';
lxb01      If Pdata <> APOMESSAGE;
lxb01        gPriorityMailResults.error.hasError = TRUE;
lxb01        gPriorityMailResults.error.message = %trim(pData);
lxb01      EndIf;

       endsl;

      /end-free

     p prPriorityMailHandler...
     p                 e



      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
      //*      P R O C E D U R E   PriorityMailErrHandler
      //*
      //* XML Parse error handler for PriorityMail
      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
      //*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     p prPriorityMailErrHandler...
     p                 b

     d prPriorityMailErrHandler...
     d                 pi
     d  pCurLine                     10i 0 value
     d  pCurCol                      10i 0 value
     d  pErrStr                    1024a   value varying

      /free

       gError.code = 'PARSEERROR';
       gError.severity = 100;
       gError.pgm = 'PriorityMail';
       gError.text =
         'Line:' + %char(pCurLine) +
         ' Column:' + %char(pCurCol) +
         ' ' + pErrStr;

      /end-free

     p prPriorityMailErrHandler...
     p                 e

      *------------------------------------------------------------------------
      * Procedure name: getCallingProgram
      * Purpose:        Get the program name that called these procedures
      * Returns:        The calling program or blank if not found
      *------------------------------------------------------------------------
     p getCallingProgram...
     p                 b

     D getCallingProgram...
     D                 pi            10a

     d returnCallingProgram...
     d                 s             10a

     d iX              s             10i 0
     d wkCallStackEntry...
     d                 ds                  likeds(callStackEntryDS)

      /free

       clear returnCallingProgram;
       clear iX;

       dou not wkCallStackEntry.isFound or returnCallingProgram<>' ';
         wkCallStackEntry = fnGetCallStackEntry(iX);
         if wkCallStackEntry.isFound
             and wkCallStackEntry.programName <> psdsPgmName;
           returnCallingProgram = wkCallStackEntry.programName;
         endif;
         iX += 1;
       enddo;

       return returnCallingProgram;

      /end-free

     p getCallingProgram...
     p                 e

       //-------------------------------------------------------------------------------------------
       // Transmit the XML Web Service Request
       //-------------------------------------------------------------------------------------------
     P transmitRequest...
     P                 b
     d transmitRequest...
     d                 pi
     d  inURI                              const like(wcf_URIPath)
     d  inSOAPOper                         const like(wcf_WCFOper)
     d  inDebug                        n   const options(*nopass)

     d wkDebug         s               n

      /free

       if %parms() > 2;
         wkDebug = inDebug;
       else;
         wkDebug='0';
       endif;

       monitor;
         gInCfg.URI = inURI;
         gInCfg.CCSID = 819;
         gInCfg.Timeout = 180;
         if wkDebug;
           gInCfg.Debug = RXS_YES;
           gInCfg.DebugFile = '/USPS/Debug/getUriDebug.txt';
         else;
           gInCfg.Debug = RXS_NO;
         endif;
         gInCfg.ContType  = 'application/x-www-form-urlencoded';
         gInCfg.Accept  = '*/*';

         RXS_getUri(gInCfg: gReqData: gRspData: gRspHttpHdr);

lb01     if wkDebug;
lb01       RXS_log(RXS_DIAG: 'gRspData from transmission to '+inSOAPOper);
lb01       dumpXMLVar(gRspData);
lb01     endif;

       on-error;
         gError = RXS_catchError();
       endmon;

      /end-free

     p transmitRequest...
     p                 e



       //-------------------------------------------------------------------------------------------
       // Dump out the XML Variable to the job log for debugging
       //-------------------------------------------------------------------------------------------
     p dumpXMLVar...
     p                 b

     d dumpXMLVar...
     d                 pi
     d inXMLVar                            const like(gRspData)

     d lastIX          s             10i 0 inz(1)
     d iX              s             10i 0 inz(1)
     d iY              s             10i 0 inz(1)
     d message         s            132

     d CRLF_Found      s               n

     d CRLF            c                   x'0D25'
     d DEBUG           c                   'DEBUG: '

      /free

       reset iX;
       reset lastIX;
       clear CRLF_Found;

       dou iX = 0;
         iX = %scan(CRLF: inXMLVar: iX);
         if iX <> 0;
           CRLF_Found='1';
           message = %subst(inXMLVar: lastIX: iX-lastIX);
           RXS_log(RXS_DIAG: DEBUG+message);
           iX += %len(CRLF);
           lastIX = iX;
         endif;
       enddo;

       if not CRLF_Found;
         reset iX;
         reset lastIX;
         dow iX < %len(%trim(inXMLVar));
           message = DEBUG + %subst(inXMLVar: iX);
           RXS_log(RXS_DIAG: %trim(message));
           iX += %len(message)-%len(DEBUG);
         enddo;
       endif;

      /end-free

     p dumpXMLVar...
     p                 e
      //--------------------------------------------------------------------------------------------
      //‚Email the CSV file utilizing RPGMAIL
      //--------------------------------------------------------------------------------------------
     p sendEmail...
     p                 b

     d sendEmail...
     d                 pi
     d InEmail_body                 512
     d InEmail_subj                 512

     D wkEmail         s               o   class(*java: RPGMail)
     D wkIFSFileName   s            128
     D wkAttachedFileName...
     D                 s            128
     d EMAIL_BODY      s            512
     d EMAIL_SUBJECT   s            512
     d Infile2send     s             75
     d ATTACHED_FILE_NAME...
     d                 s            128


     d FROM_ADDRESS    c                   'NOREPLY@NBTY.COM'
lxb01d TO_ADDRESS      c                   'ITDIRECTRESPONSE@NBTY.COM'
     d SUBJECT         c                   'USPS Priority Mail DIT Error'
     d TEXT_PLAIN      c                   'text/plain'
     d APPLICATION_CSV...
     d                 c                   'application/csv'

      /free

       EMAIL_BODY = InEmail_Body;
       EMAIL_SUBJECT = InEmail_Subj;

       //‚Bring in the SMTP host address and port# which will be used to
       //‚send the email
        in gSmtpHostAddress;
        in gSmtpHostPort;

       //‚Initialize the RPGMAIL
       monitor;
         RPGMail_init();
       on-error;
       endmon;

       //‚Set up the new email and send it
       monitor;
         //‚Create a new RPGMail java object
         wkEmail = RPGMail_new();

         //‚Define the from email address
         RPGMail_addAddress(wkEmail: 'FROM': FROM_ADDRESS:' ');

         //‚Define the to email address
         //‚Multiple email addresses can be added by simply calling
         //‚RPGMail_addAddress with every address to receive the email

         RPGMail_addAddress(wkEmail: 'TO': To_Address: ' ');

         //‚Define the email's subject
         RPGMail_setSubject(wkEmail: Email_SUBJECT);

         //‚Define the email's body
         RPGMail_setBodyText(wkEmail: EMAIL_BODY:TEXT_PLAIN);

         //‚Define the SMTP Host address to deliver the email
         RPGMail_setSMTPHost(wkEmail: gSMTPHostAddress);

         //‚Define the SMTP port# to deliver the email
         RPGMail_setSMTPPort(wkEmail: gSMTPHostPort);

         //‚Send the email
         RPGMail_send(wkEmail);

       on-error;
         //‚An error ocurred - catch the error and throw it
         //‚up to the level above
       endmon;

      /end-free

     p sendEmail...
     p                 e

