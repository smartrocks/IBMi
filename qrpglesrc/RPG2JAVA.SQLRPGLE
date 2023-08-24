      *------------------------------------------------------------------------------------------
      * RPG2JAVA - Test RPG call to Java
      *
      * External Function References
      *------------------------------
      * Function          ServiceProgram BindingDirectory Purpose
      * ----------------  -------------- ---------------- ----------------------------------------
      * WinMsg            MESSAGE        BLUESTAR         Display 3 line message window
      *------------------------------------------------------------------------------------------
      * Program Change Log
      *------------------------------------------------------------------------------------------
      * Date       Programmer Project Scan Desc
      * 2013-01-30 Keck                    Created
      *------------------------------------------------------------------------------------------
     H option(*nodebugio : *srcstmt) dftactgrp(*no) actgrp(*CALLER) indent('| ')
     H bnddir('BLUESTAR') thread(*SERIALIZE)
      *------------------------------------------------------------------------------------------
      * Prototypes
     D/define PROTOTYPES
     D/include nbtygpl/qrpglesrc,MESSAGE
     D/undefine PROTOTYPES

      * Entry Parameters
     D P001            s                   like(LegVendor)
     D P002            s                   like(Invoice)

     D LegVendor       s              9
     D Invoice         s             22

     D class_GetPayGroup...
     D                 C                   'database.GetInvoicePayGroup'

      * object variables
     D newString       PR              O   EXTPROC(*JAVA
     D                                             :'java.lang.String'
     D                                             : *CONSTRUCTOR)
     D  value                     65535A   VARYING CONST

     D legVendorO      s                   like(newString)
     D invoiceO        s                   like(newString)
     D payGroupO       s                   like(newString)

      * Class:  GetInvoicePayGroup
      * Method: getPayGroup
     D getPayGroup...
     D                 PR                  LIKE(newString)
     D                                     extproc(*JAVA
     D                                             :class_GetPayGroup
     D                                             :'getPayGroup')
     D                                     STATIC
     D legacyVendorO                       like(legVendorO) CONST
     D invoiceO                            like(invoiceO)   CONST

     D getRPGStringFromJavaString...
     D                 PR         65535A   VARYING
     D                                     EXTPROC(*JAVA
     D                                             :'java.lang.String'
     D                                             :'getBytes')


      * Simple Variables
     D FALSE           c                   const('0')
     D msg1            s             50
     D msg2            s             50
     D msg3            s             50
     D payGroup        s             15    VARYING
     D TRUE            c                   const('1')

      *------------------------------------------------------------------------------------------
     C     *ENTRY        PLIST
     C     LegVendor     PARM                    P001
     C     Invoice       PARM                    P002
      *------------------------------------------------------------------------------------------

      /free

        EXEC SQL  set option commit=*none;

         legVendorO = newString(legVendor);
         invoiceO   = newString(invoice  );

         payGroupO = getPayGroup(legVendorO: invoiceO);
         payGroup  = getRPGStringFromJavaString(payGroupO);

         msg1 = 'legacyVendor: ' + legVendor;
         msg2 = 'invoice: ' + invoice;
         msg3 = 'payGroup: ' + payGroup;
         winmsg(msg1: msg2: msg3);

         exsr ExitPgm;




       // S U B R O U T I N E S
       // *---------------------------------------------------------------------------------------
         begsr ExitPgm;
            *inLR = *on; // shut down program on exit
            return;
         endsr;

      /end-free








      *******************************
      * S U B - P R O C E D U R E S *
      *******************************


