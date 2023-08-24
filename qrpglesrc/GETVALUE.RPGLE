      *********************************************************************
      * GetValue - Get a value from the VALUE file
      *
      * Purpose: Supports a generic VALUE utility using the VALUE file along with
      *          the SETVALUE and DLTVALUE programs.  Together, these elements
      *          provide a utility that can replace use of data areas.
      *********************************************************************
      * Date       Programmer  Project  Scan  Desc
      * 2006-08-14 Keck        12018          Created
      *********************************************************************
     FvalueL1   if   e           k DISK    prefix(v_)
      * Value by Function ID (Unique)
      *********************************************************************
     D P001            s                   like(v_Function)
     D P002            s                   like(v_String)
     D Number          s                   like(v_Number)
     D RtnCode         s             10

     D Function        s                   like(v_Function)
     D String          s                   like(v_String)

     D User            S             10    inz(*User)
      *********************************************************************

     c     *entry        plist
     c     function      parm                    P001
     c                   parm      String        P002
     c                   parm                    Number
     c                   parm                    RtnCode

      // Function and String are required parameters
      // Number and RtnCode are optional parameters


     c     Function      CHAIN     ValueR                             99

      * record found
     c                   if        *in99 = *off                                 FOUND

     c                   eval      String = v_String

     c                   if        %parms >= 3
     c                   eval      Number = v_Number
     c                   endif

     c                   if        %parms >= 4
     c                   eval      RtnCode = *blanks
     c                   endif

      * record not found
     c                   else                                                   NOT FOUND
     c                   eval      String = *blanks

     c                   if        %parms >= 3
     c                   eval      Number = *zero
     c                   endif

     c                   if        %parms >= 4
     c                   eval      RtnCode = 'NotFound'
     c                   endif

     c                   endif

     c                   eval      *inLR = *on
     c                   return
