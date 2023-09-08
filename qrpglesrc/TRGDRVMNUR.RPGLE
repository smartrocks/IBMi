      /copy QGPL/QSRVSRC,QILEHeader
     HBndDir('MFGBIND')
     HBndDir('TOOLBIND')
     HBnddir('QC2LE')
     F
     FtrgdrvmnudCF   E             Workstn

     D* - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
     D
     D* Execute Command (system) Subprocedure Variables 
     D System          PR            10I 0 ExtProc('system')
     D  CmdText                        *   Value Options(*String)
     D
     D ErrorCPF        S              7A   Import('_EXCP_MSGID')
     D ErrorFlag       S             10I 0 Inz(0)
     D
     D systemString    s            256a   Inz
     D* - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -
     D addTriggerPgm...
     D                 pr                  ExtPGM('ADDTRG10R')
     D
     D triggerHandlePgm...
     D                 pr                  ExtPGM('TRGDRV10R')
     D
     D triggerExceptPgm...
     D                 pr                  ExtPGM('TRGDRVX10R')
     D
     D triggerErrorData...
     D                 pr                  ExtPGM('TRGERR20R')
     D
     D emailGroupPgm...
     D                 pr                  ExtPGM('TRGEMSG10R')
     D
     D wrkTriggerDef...
     D                 pr                  ExtPGM('TRGDEF10R')
     D
     D processTrgDef...
     D                 pr                  ExtPGM('CHGTRG20R')
     D passOption                     3a   Const
     D
     D
      /Free

        dou (*in03);
          exfmt screen;

        select;

          when (option = 10);
            callp addtriggerpgm();
            clear option;

          when (option = 15);
            callp wrkTriggerDef();
            clear option;

          when (option = 17);
            callp processTrgDef('RMV');
            clear option;

          when (option = 18);
            callp processTrgDef('ADD');
            clear option;

          when (option = 20);
            callp triggerHandlePgm();
            clear option;

          when (option = 30);
            callp triggerExceptpgm();
            clear option;

          when (option = 50);
            callp triggerErrorData();
            clear option;

          when (option = 70);
            callp emailgrouppgm();
            clear option;

          endsl;

        enddo;

        *inlr = *on;
        return;


