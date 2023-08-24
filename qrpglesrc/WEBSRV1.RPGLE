     h option(*nodebugio: *srcstmt: *nounref) dftactgrp(*no) actgrp('QILE')
     h pgmInfo(*PCML: *MODULE)
      *--------------------------------------------------------------------
     D* Prototype Definitions

     F*dcommo    IF   E             DISK
      * prototypes

CPO1 d WEBSRV1         pi
     d*  f1                           5s 0 const
     d*  f2                           5s 0 const
     d   yyy                               likeds(zzz)

CPO1 d AS400cmd        pr                  extpgm('QCMDEXC')
 /   d                              120    const
 /   d                               15p 5 const

CPO1 d ovrfile         s            120
     d
     d

       dcl-s sum int(5);
       dcl-s i   int(5);

       dcl-ds zzz qualified;
          x1 char(1);
          x2 char(1);
          dcl-ds subds2;
             m1 char(1);
             m2 char(2);
          end-ds;
          x3 char(1);
          x4 char(1);
          dcl-ds subds1;
             m1 char(1);
             m2 char(2);
          end-ds;
          x5 char(1);
          x6 char(1);
          dcl-ds subds3 dim(3);
             m1 int(5);
             m2 int(5);
          end-ds;
       end-ds;
      *--------------------------------------------------------------------

      /free
                         // sum = f1 + f2;
                         zzz.x1 = 'A';
                         zzz.x2 = 'B';
                         zzz.x3 = 'C';
                         zzz.x4 = 'D';
                         zzz.x5 = 'E';
                         zzz.x6 = 'F';

                         zzz.subds1.m1 = '1';
                         zzz.subds1.m2 = '2';

                         zzz.subds2.m1 = '3';
                         zzz.subds2.m2 = '4';

                         for i = 1 to 2;
                            zzz.subds3(i).m1 = i;
                            zzz.subds3(i).m2 = i+1;
                         endfor;

                         yyy = zzz;

 /                    // eval      ovrfile = 'ADDLIBLE'
 /                    //           + ' ' + 'VNINV     ';
 /                    // callp(e)  AS400cmd(ovrfile:
 /                    //           %len(%trim(ovrfile)));
                      // if %error;
                      // endif;

         *inLR = *on;
         return;

      /end-free
