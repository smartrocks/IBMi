# IBMi
IBM  i Stuff

## Assumptions
1. The target library will contain both source and objects.
2. 

## Notes
1. /copy file directives of the form /copy NBTYGPL/QRPGLESRC,ILEHeader should be changed to reflect the target environment. One option is to change the command to /copy QRPGLESRC,ILEHeader removing the explicit library reference. In this way the /copy will use the library list of the job that's running the BUILD command. Also, it's a good idea to use INCLUDE instead of COPY. The syntax is the same and it handles SQL related includes better.
1. The build utility will create source PF's as needed and will replace any source PF members which have the same source file and member name. Source PF members which are not named the same as what the BUILD utility is importing will NOT be affected.

## Steps to clone and compile imported code from Github

### install git
1. check whether git is already installed
    1. from bash command line 
        1. git --version    // if version is returned then skip to Configure Git
    1. 

### configure git
1. configure VS Code as your default editor
    1. git config --global core.editor "code --wait"

### Clone from Github repository
1. Clone github repository https://github.com/smartrocks/IBMi to an IBM i IFS

### Copy cloned source from IFS to Source PF's and compile all objects
1.  Change IFS path and target library below as needed
1.  CRTBNDCL PGM(DAVIDKECK1/BUILD) 
    SRCSTMF('/home/davidkeck/smartrocks/ibmi/qcllesrc/build.clle') 
    TEXT('Copy src from IFS and build objects') DFTACTGRP(*NO) 
    ACTGRP(QILE) DBGVIEW(*ALL)                                        
1.  CRTCMD CMD(DAVIDKECK1/BUILD) PGM(DAVIDKECK1/BUILD) 
    SRCSTMF('/home/davidkeck/smartrocks/ibmi/qcmdsrc/build.cmd') 
    TEXT('Cpy IFS src and build') 

### Run the build command    

1. BUILD and F4 to prompt from IBM i command line
    1. BUILD LIBRARY(DAVIDKECK1) FOLDER('/home/davidkeck/smartrocks/ibmi')
        1.  ex. Target library:  DAVIDKECK1
        1.  ex. Source IFS path: /home/davidkeck/smartrocks/ibmi
