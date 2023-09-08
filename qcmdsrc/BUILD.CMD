             CMD        PROMPT('BUILD SRC & OBJ FROM IFS') +
                        TEXT('Crt Src PF from IFS and build')

             PARM       KWD(LIBRARY) TYPE(*CHAR) LEN(10) +
                          PROMPT('Target Library (must exist)')

             PARM       KWD(FOLDER) TYPE(*CHAR) LEN(256) +
                          PROMPT('Root IFS SourceFolder')                      
