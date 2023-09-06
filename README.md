# IBMi
IBM  i Stuff

## How to import source from GitHub repository and build on an IBM i

1. Clone github repository https://github.com/smartrocks/IBMi to an IBM i IFS
1. Create IFS List Utility (which creates a file QTEMP/IFSLIST with list of file in IFS folder)
    1. Create source physical files if needed. Change MyLib.
        1. CRTSRCPF FILE(MYLIB/QDDSSRC)   // defaults to rln 92
        1. CRTSRCPF FILE(MYLIB/QRPGLESRC) RCDLEN(112)
        1. CRTSRCPF FILE(MYLIB/QCLSRC)
        1. CRTSRCPF FILE(MYLIB/QCLLESRC) RCDLEN(112)
        1. CRTSRCPF FILE(MYLIB/QCMDSRC)
        1. CRTSRCPF FILE(MYLIB/QSQLSRC) RCDLEN(112) // same length as used in local environment
        1. CRTSRCPF FILE(MYLIB/QSRVSRC) RCDLEN(112) // same length as used in local environment
        1. CRTSRCPF FILE(MYLIB/QBNDSRC) RCDLEN(112) // same length as used in local environment
    1. Copy source files from IFS to physical source file members

        1. CPYFRMSTMF FROMSTMF('/home/DAVIDKECK/smartrocks/IBMi/qddssrc/IFSLIST.PF')
        TOMBR('/QSYS.LIB/DAVIDKECK1.LIB/QDDSSRC.FILE/IFSLIST.MBR')
        MBROPT(*REPLACE) 

        1. CPYFRMSTMF FROMSTMF('/home/DAVIDKECK/smartrocks/IBMi/qrpglesrc/IFSLIST.RPGLE') TOMBR('/QSYS.LIB/DAVIDKECK1.LIB/QRPGLESRC.FILE/IFSLIST.MBR') MBROPT(*REPLACE)  

        1. CPYFRMSTMF FROMSTMF('/home/DAVIDKECK/smartrocks/IBMi/qclsrc/IFSLISTCL.CLP') TOMBR('/QSYS.LIB/DAVIDKECK1.LIB/QCLSRC.FILE/IFSLISTCL.MBR') MBROPT(*REPLACE)                                                                                                                                    
        1. CPYFRMSTMF FROMSTMF('/home/DAVIDKECK/smartrocks/IBMi/qcmdsrc/IFSLIST.CMD') TOMBR('/QSYS.LIB/DAVIDKECK1.LIB/QCMDSRC.FILE/IFSLIST.MBR') MBROPT(*REPLACE)                                                                    
    1. Add member types to the IFSLIST* members
        1. CHGPFM FILE(DAVIDKECK1/QDDSSRC) MBR(IFSLIST) SRCTYPE(PF)
        1. CHGPFM FILE(DAVIDKECK1/QRPGLESRC) MBR(IFSLIST) SRCTYPE(RPGLE)
        1. CHGPFM FILE(DAVIDKECK1/QCLSRC) MBR(IFSLISTCL) SRCTYPE(CLP) 
        1. CHGPFM FILE(DAVIDKECK1/QCMDSRC) MBR(IFSLIST) SRCTYPE(CMD)  

    1. Compile the following in sequence
        1. IFSLIST      PF
        1. IFSLISTCL    CLP  
        1. IFSLIST      RPGLE
        1. IFSLIST      CMD
    1. Note that DSPF and PF files can not be compiled directly from the IFS.
        1. Copy from IFS using:  
