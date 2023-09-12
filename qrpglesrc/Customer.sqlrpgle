     h Option(*SrcStmt:*NoDebugIO)
     h alwnull(*usrctl)
     H PgmInfo(*PCML:*MODULE) dftactgrp(*no) Actgrp('QILE')
      **********************************************************************************************
      * Program Name: CUSTOMER
      * Written By:   DK + GC with help from AS
      * Date:         2023-07-12
      *
      **********************************************************************************************
      * MODIFICATIONS:
      * -------------
      * Date      Pgmr       MOD   Reasons
      * --------  ---------  ----  -----------------------------------------------------------------
      **********************************************************************************************
AS001  dcl-f Cstmst     usage(*input) keyed usropn prefix (cust_);
       dcl-f Cntrycd    usage(*input) keyed usropn;

       // order header by division / customer
       dcl-f invcus     usage(*input) keyed usropn prefix(oh_);
       //-------------------------------------------------------------------------------------------

       dcl-pi Customer;
        inCstDiv              packed(2:0) const;
        inCstNbr              packed(9:0) const;
        RtnVar2               likeds(CustInfo);
       end-pi;

       //-------------------------------------------------------------------------------------------
       // Global Variables
       //-------------------------------------------------------------------------------------------
       dcl-s gCommand           char(120);
       dcl-s gPickHeaderID    packed(9:0);
       dcl-s gWarehouse       packed(3:0);


       dcl-pr getOrders;
         division packed(2:0) value;
         customer packed(9:0) value;
       end-pr;
       //-------------------------------------------------------------------------------------------
       // Global Data Structures
       //-------------------------------------------------------------------------------------------

       dcl-ds CUSTINFO qualified inz;
         Cmdiv like(cust_cmdiv);
         Cmnum like(cust_cmnum);
         Cmname like(cust_cmname);
         Cmadd1 like(cust_cmadd1);
         Cmadd2 like(cust_cmadd2);
         Cmadd3 like(cust_cmadd3);
         Cmcity like(cust_cmcity);
         Cmst   like(cust_cmst);
         Cmzip1 like(cust_cmzip1);
         Cmzip2 like(cust_cmzip2);
         Cmysr8 like(cust_cmysr8);
         Cname like (cname); // country name from table Cntrycd
            dcl-ds Order dim(10) inz;
               id      packed(6:0);
               Date    date;
               Amount  packed(11:2);
            end-ds;
       end-ds;


       dcl-pr GetCustInf;
        inCstDiv              packed(2:0) const;
        inCstNbr              packed(9:0) const;
        RtnVar                LikeDS(CUSTINFO);
       end-pr;

       dcl-pr InitializeSQL;
       end-pr;

       dcl-pr qCmdExc extpgm ;
         *n char(1000) options(*varsize);
         *n packed(15:5);
       end-pr;



       InitializeSQL();
       getCustInf(inCstDiv: inCstNbr: CustInfo);

       RtnVar2 = CustInfo;

       *inlr = *on;
       return;

       //--------------
       // SUB-PROCEDURES
       //--------------


       //-----------------------------------------------------------------------------
       // InitializeSQL non-exported procedure
       //-----------------------------------------------------------------------------
       dcl-proc InitializeSQL;

       dcl-pi InitializeSQL;
       end-pi;

       exec Sql Set Option Commit=*CS, CLOSQLCSR=*ENDMOD, DECMPT=*PERIOD;
       exec Sql Set Option DATFMT = *ISO, NAMING = *SQL;

       end-proc InitializeSQL;


       //*******************************************************************
       // Return back Customer name and address
       //*******************************************************************
       dcl-proc GetCustInf;

       dcl-pi GetCustInf;
        inCstDiv              packed(2:0) const;
        inCstNbr              packed(9:0) const;
        RtnVar                LikeDS(CUSTINFO);
       end-pi;

       //-------------------------------------------------------------------
       //Stand Alone Fields - TOP
       //-------------------------------------------------------------------
       dcl-s Cntrycode         packed(5:0);
       dcl-s Pocodemask        char(15);
       dcl-c CustNotFound      '*** Not found ***';
       //-------------------------------------------------------------------
       // Stand Alone Fields - BOTTOM
       //-------------------------------------------------------------------

       if not %open(Cstmst);
         open Cstmst;
       endif;

       if not %open(Cntrycd);
         open Cntrycd;
       endif;

       if not %open(invCus);
         open InvCus;
       endif;

       clear Custinfo;
       chain ( InCstDiv: InCstNbr ) Cstmst;

       if not %found(Cstmst);
         Reset CUSTINFO;          // Clear out all data
         Custinfo.Cmdiv  = inCstDiv;       // Set customer division requested
         CustInfo.Cmnum  = inCstNbr;       // Set customer number requested
         CustInfo.Cmname = CustNotFound;   //   and error code

       else;
         CustInfo.Cmdiv  = cust_cmdiv;
         CustInfo.Cmnum  = cust_cmnum;
         CustInfo.Cmname = cust_cmname;
         CustInfo.Cmadd1 = cust_cmadd1;
         CustInfo.Cmadd2 = cust_cmadd2;
         CustInfo.Cmadd3 = cust_cmadd3;
         CustInfo.Cmcity = cust_cmcity;
         CustInfo.Cmst   = cust_cmst;
         CustInfo.Cmzip1 = cust_cmzip1;
         CustInfo.Cmzip2 = cust_cmzip2;
         CustInfo.Cmysr8 = cust_cmysr8;

         if CustInfo.Cmysr8 = ' ';  // country code
           CustInfo.Cname   = ' ';  // country name
         else;
           exsr GetCntryname;
         endif;

         getOrders(inCstDiv:inCstNbr);
       endif;

       if %open(Cstmst);
         close Cstmst;
       endif;
       if %open(Cntrycd);
         close Cntrycd;
       endif;
       if %open(Cntrycd);
         close InvCus;
       endif;

       return;
       //-------------------------------------------------------------------------------------------

       begsr GetCntryname;

       chain (cust_Cmysr8) Cntrycd;
       if not %found(Cntrycd);
         Cname = 'Undefined Country code';
       endif;

       endsr;

       end-proc GetCustInf;


       dcl-proc getOrders;
          dcl-pi *n;
            division packed(2:0) value;
            customer packed(9:0) value;
          end-pi;
         dcl-s i int(3);
         setll (division:customer) invcus; // order header by division/customer
         reade (division:customer) invcus;
         i=1;
         dow not %eof() and (i<=5);
            custInfo.Order(i).id     = oh_ohnum;
            custInfo.order(i).date   =
               %date((((2000+oh_ohenty-72)*10000)+
               (oh_ohentm*100)+oh_ohentd):*ISO);
            custInfo.order(i).amount = oh_OHGTOT;
            reade (division:customer) invcus;
            i+=1; // index
         enddo;
       end-proc;

