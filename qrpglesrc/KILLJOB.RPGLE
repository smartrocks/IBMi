     dInterruptJob     pr                  extpgm('QWCJBITP')
     d Controls                            likeds(Controls) const
     d CtlFormat                      8    const
     D ErrorCode                     10i 0 const
     dControls         ds
     d PgmName                       10    inz('RUNCMD')
     d PgmLib                        10    inz('DXKLIB')
     d TgtJob                        26
     d Reserved                       2    inz(*ALLx'00')
     d OffPgmDta                     10i 0
     d LenPgmDta                     10i 0
     d PgmDta                       512
     c     *entry        plist
     c                   parm                    Job              26
     c                   parm                    Cmd             512
      * Set target job ID
     c                   eval      TgtJob = Job
      * Set length of command to execute
     c                   eval      LenPgmDta= %len(%trimr(Cmd))
      * Set the command to execute
     c                   eval      PgmDta= %subst(Cmd:1 :LenPgmDta)
      * Set the offset to the command
     c                   eval      OffPgmDta= (%addr(PgmDta)
     c                                         -%addr(Controls))
      * Call the program in job TgtJob
     c                   callp     InterruptJob( Controls :'JITP0100' :0)

     c                   return
