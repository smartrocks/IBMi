**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);
ctl-opt option(*srcstmt:*nodebugio);

dcl-pi *n;
    INTERFACE   like(ftp.INTERFACE);
    FTPSRVR     like(ftp.FTPSRVR);    
    FTPUSER     like(ftp.FTPUSER);
    FTPPWD      like(ftp.FTPPWD);
    IFSINBND    like(ftp.IFSINBND);
    IFSOUTBND   like(ftp.IFSOUTBND);    
    IFSARCHFLR  like(ftp.IFSARCHFLR);
    RMTDIR      like(ftp.RMTDIR);
    ARCHDAYS    like(ftp.ARCHDAYS);
    IFSFILNAM   like(ftp.IFSFILNAM);
    IFSFILEXT   like(ftp.IFSFILEXT);
    rtnCod      char (10);
end-pi;

dcl-ds FTP extname('FTPINBOUTB') qualified end-ds;

EXEC SQL SET OPTION commit=*none;

exec sql
    select distinct * 
    into :FTP
    from FTPINBOUTB x
    where x.INTERFACE = :INTERFACE;

    select;
        when sqlcod < *zero;
            rtnCod = 'ERROR';
        when sqlcod = 100;
            rtnCod = 'NOT FOUND';
            // INTERFACE  - leave unchanged from input value */
            FTPSRVR     = *blanks;    
            FTPUSER     = *blanks;
            FTPPWD      = *blanks;
            IFSINBND    = *blanks;
            IFSOUTBND   = *blanks;    
            IFSARCHFLR  = *blanks;
            RMTDIR      = *blanks;
            ARCHDAYS    = *blanks;
            IFSFILNAM   = *blanks;
            IFSFILEXT   = *blanks;
        other;
            rtnCod = 'OK';
            INTERFACE   = ftp.INTERFACE;
            FTPSRVR     = ftp.FTPSRVR;    
            FTPUSER     = ftp.FTPUSER;
            FTPPWD      = ftp.FTPPWD;
            IFSINBND    = ftp.IFSINBND;
            IFSOUTBND   = ftp.IFSOUTBND;    
            IFSARCHFLR  = ftp.IFSARCHFLR;
            RMTDIR      = ftp.RMTDIR;
            ARCHDAYS    = ftp.ARCHDAYS;
            IFSFILNAM   = ftp.IFSFILNAM;
            IFSFILEXT   = ftp.IFSFILEXT;
    endsl;

*inlr = *on;
return;