      /if not defined (PROTOTYPES)
     H nomain  option(*nodebugio : *srcstmt)
     H bnddir('BLUESTAR')
      *----------------------------------------------------------
      * Service Program for Date Functions
      *
      * NOTE: To access the programs in this service program do the following...
      *       1. Add   BNDDIR('BLUESTAR')   to your H-spec.
      *       2. Copy the following compiler directives to the
      *          D-spec section of your program.
      */define PROTOTYPES
      */copy NBTYGPL/QRPGLESRC,date
      */undefine PROTOTYPES
      *
      *----------------------------------------------------------
      * NOTE: See the BLUESTAR Service Program Documentation for instructions
      *       on how to update and promote this servive program.
      *
      * Program Change Log
      *--------------------------------------------------------------------------------
      * Date       Programmer Project Scan Description
      * 2009-05-29 Keck       P286613 dk04 added MS4Up/MS4Down *YM and *Y capability
      * 2009-04-02 Keck       P346902 dk03 added EndOfPriorMonth, StartOfPriorMonth
      * 2007-12-28 Keck       H267107 DK02 added NUM2DATE ...... use as SQL UDF
      * 2007-02-22 Keck       H215915 DK01 Fix MS4UP/Down zero date handling
      * 2005-07-21 Keck       11264        Standardize all Bluestar Service Programs
      * 2004-03-23 Keck                    Created
      *--------------------------------------------------------------------------------

      /endif


      **********************************************
      * Date Service Program Prototypes (Exported) *
      **********************************************


     *** Convert a Date field to Signed YMD or MDY
     D SignedDate      Pr             6s 0
     D  DateIn                         d   Const
     D  ToFmt                         4    Value options(*nopass)

     *** For a given date, return the End Of Month Date
     D EndOfMonth      Pr              d
     D  DateIn                         d   Const

     *** For a given date, return the Start Of Month Date
     D StartOfMonth    Pr              d
     D  DateIn                         d   Const

     *** Check if given number is a valid date in the specified format (Dft is *YMD)
     D isValidDate     Pr              n
     D  DateIn                        8s 0 Value
     D  DateFormat                    4    Value options(*nopass)

     *** Return Day of Week code (1=Sun 2=Mon 3=Tue 4=Wed 5=Thu 6=Fri 7=Sat)
     D DayOfWeek       Pr             1s 0
     D  DateIn                         d   Value

      * Given a numeric date and input date format, return a true date
dk02 D NUM2DATE        PR              d
dk02 D  DateIn                        8S 0 Const
dk02 D  DateTypeIn                    4A   Const
dk02 D                                     Varying

      * Return the date the prior month ended
dk03 D EndOfPriorMonth...
dk03 D                 Pr              d

      * Return the date the prior month started
dk03 D StartOfPriorMonth...
dk03 D                 Pr              d


       //if defined (PROTOTYPES)
       //eof
       //endif



      ****************************************
      * Supporting Prototypes (Not Exported) *
      ****************************************
      /define PROTOTYPES
      /include nbtygpl/qrpglesrc,API
      /undefine PROTOTYPES


      ********************
      * Global Variables *
      ********************
     D False           s               n   inz('0')
     D True            s               n   inz('1')




      *######################
      * EXPORTED PROCEDURES *
      *######################

      *------------------------------------------------------------------------
      * SignedDate
      *
      * Purpose: Convert a Date field to Signed YMD or MDY format
      *
      * Parameters: DateIn - any date format field, including %date(*Date)
      *             ToFmt  - target signed format (*YMD *MDY)
      *                      optional ... *YMD is the default
      *
      * Examples:  signedDateYMD = SignedDate( isoDate : '*MDY' )
      *            signedDateYMD = SignedDate( %date(*date))
      *            signedDateMDY = SignedDate( %date(*date)  : '*MDY' )
      *------------------------------------------------------------------------
     P SignedDate      B                   Export
     D SignedDate      Pi             6s 0
     D  DateIn                         d   Const
     D  ToFmt                         4    Value options(*nopass)
     D                 ds
     D YMD                            6s 0
     D YMDa                           6    overlay ( YMD )
     D                 ds
     D MDY                            6s 0
     D MDYa                           6    overlay ( MDY )

      /free

         // set the default target date format
         select;
           when %parms = 1;
            ToFmt = '*YMD';

           when ToFmt <> '*YMD' and
                ToFmt <> '*MDY';

            ToFmt = '*YMD';
         endsl;

         select;
           when ToFmt = '*YMD';
             YMDa = %char( DateIn : *YMD0 );
             return YMD;

           when ToFmt = '*MDY';
             MDYa = %char( DateIn : *MDY0 );
             return MDY;
         endsl;

      /end-free

     P SignedDate      E




      *------------------------------------------------------------------------
      * EndOfMonth
      *
      * Purpose: For a given date, return the End Of Month date
      *
      * Parameters: DateIn - any date format field
      *
      * Examples:  eom = EndOfMonth( someDate )
      *            eom = EndOfMonth( %date(*date))
      *------------------------------------------------------------------------
     P EndOfMonth      B                   Export
     D EndOfMonth      Pi              d
     D  DateIn                         d   Const

     D EOM             s               d
     D WorkDate        s               d
     D days            s              5u 0

      /free

           WorkDate = DateIn + %months(1);
           days = %subdt(workdate : *d);
           EOM  = workdate - %days(days);
           return EOM;

      /end-free

     P EndOfMonth      E




      *------------------------------------------------------------------------
      * StartofMonth
      *
      * Purpose: For a given date, return the Start Of Month date
      *
      * Parameters: DateIn - any date format field
      *
      * Examples:  eom = StartOfMonth( someDate )
      *            eom = StartOfMonth( %date(*date))
      *------------------------------------------------------------------------
     P StartOfMonth    B                   Export
     D StartOfMonth    Pi              d
     D  DateIn                         d   Const

     D SOM             s               d
     D days            s              5u 0

      /free

           days = %subdt(DateIn : *d);
           SOM  = DateIn - %days(days - 1);
           return SOM;

      /end-free

     P StartOfMonth    E




      *------------------------------------------------------------------------
      * isValidDate
      *
      * Purpose: Check if input number is a valid date in the specified format.
      *          The format is an optional parameter, defaulting to (*YMD).
      *
      * Note: This function uses the TEST(d) op code.  This is better than using "monmsg"
      *       in free form RPG because monmsg bloats your job log with messages.
      *
      * Parameters: DateIn     - any 6 or 8 digit number
      *             DateFormat - Optional - Defaults to *YMD
      *                          (*YMD *DMY *MDY *ISO *EUR *USA *JUL *JIS are supported)
      *
      * Examples:
      *
      *       1. Below, s_OrderDate is a Signed 6.0 from a display file, and is
      *          expected to be in *YMD format.
      *
      *            if isValidDate(s_OrderDate);
      *               ...code ...
      *            endif;
      *
      *       2. The previous example can also be coded as follows.
      *            if isValidDate(s_OrderDate : *YMD);
      *               ...code ...
      *            endif;
      *
      *       3. Below, s_OrderDate is a Signed 8.0 from a display file, and is
      *          expected to be in *ISO format (i.e. CCYYMMDD)
      *            if isValidDate(s_OrderDate : *ISO);
      *               ...code ...
      *            endif;
      *------------------------------------------------------------------------


     P isValidDate     B                   Export
     D isValidDate     Pi              n
     D  DateIn                        8s 0 Value
     D  DateFormat                    4    Value options(*nopass)


     C                   SELECT

     C                   WHEN      %parms = 1
     C     *YMD          test(de)                DateIn
     C                   if        %error
     C                   return    False
     C                   else
     C                   return    True
     C                   endif


     C                   WHEN      DateFormat = '*YMD'
     C     *YMD          test(de)                DateIn
     C                   if        %error
     C                   return    False
     C                   else
     C                   return    True
     C                   endif


     C                   WHEN      DateFormat = '*MDY'
     C     *MDY          test(de)                DateIn
     C                   if        %error
     C                   return    False
     C                   else
     C                   return    True
     C                   endif


     C                   WHEN      DateFormat = '*DMY'
     C     *DMY          test(de)                DateIn
     C                   if        %error
     C                   return    False
     C                   else
     C                   return    True
     C                   endif


     C                   WHEN      DateFormat = '*EUR'
     C     *EUR          test(de)                DateIn
     C                   if        %error
     C                   return    False
     C                   else
     C                   return    True
     C                   endif


     C                   WHEN      DateFormat = '*ISO'
     C     *ISO          test(de)                DateIn
     C                   if        %error
     C                   return    False
     C                   else
     C                   return    True
     C                   endif


     C                   WHEN      DateFormat = '*USA'
     C     *USA          test(de)                DateIn
     C                   if        %error
     C                   return    False
     C                   else
     C                   return    True
     C                   endif


     C                   WHEN      DateFormat = '*JUL'
     C     *JUL          test(de)                DateIn
     C                   if        %error
     C                   return    False
     C                   else
     C                   return    True
     C                   endif


     C                   WHEN      DateFormat = '*JIS'
     C     *JIS          test(de)                DateIn
     C                   if        %error
     C                   return    False
     C                   else
     C                   return    True
     C                   endif


     C                   OTHER
     C                   return    False

     C                   ENDSL

     P isValidDate     E




      *------------------------------------------------------------------------
      * DayOfWeek    (1=Sun 2=Mon 3=Tue 4=Wed 5=Thu 6=Fri 7=Sat)
      *
      * Purpose: Given any valid date, return a one digit code signifying a day of the week.
      *
      * Parameters: DateIn     - any true date field
      *             Return     - (1=Sun 2=Mon 3=Tue 4=Wed 5=Thu 6=Fri 7=Sat)
      *
      * Examples:
      *
      *       1. Below, s_OrderDate is a Signed 6.0 from a display file, and is
      *          expected to be in *YMD format.
      *
      *            if DayOfWeek(%Date) = 4;
      *               // we know it's a Wednesday
      *            endif;
      *
      *------------------------------------------------------------------------

     P DayOfWeek       B                   Export
     D DayOfWeek       Pi             1s 0
     D  DateIn                         d   Value

      * We know that 1/2/2000 is a Sunday
     D BaseDate        S               D   inz(d'2000-01-02')
     D days            S             10i 0
     D wDayOfWeek      S              1s 0

      /free

         days = %abs(%diff(BaseDate : DateIn : *days));
         wDayOfWeek = %rem(Days: 7) + 1;
         return wDayOfWeek;

      /end-free


     P DayOfWeek       E





      *------------------------------------------------------------------------
      * NUM2DATE
      *
      * Purpose: Given a numeric date and input date format, return a true date.
      *          This function is available as an SQL UDF.
      *
      * Returns:        DateIn as type Date
      * Parameter:      DateIn => Numeric date to be converted to type Date
      * Parameter:      TypeIn => (*ISO *YMD *MDY *DMY)
      *
      * Note: If the Input Date is zero or invalid, the Return Date will be 0001-01-01.
      *
      * Example
      *    MyDate = NUM2DATE(myDate);     // The input date type defaults to *YMD
      *  or
      *    MyDate = NUM2DATE(myDate);            // *ISO = *CYMS  ex. 2007-12-28
      *------------------------------------------------------------------------
dk02 P NUM2DATE        B                   EXPORT
dk02 D NUM2DATE        PI              d
dk02 D  DateIn                        8S 0 const
dk02 D  DateTypeIn                    4A   const
     D                                     varying

      * Local fields
dk02 D DefaultDate     s               d   inz(d'0001-01-01')
dk02 D DateOut         s               d
dk02 D pCount          s              5i 0
dk02 D Type            s              8


      /FREE

         Type = DateTypeIn;                                       // DK02

         if Type <> '*ISO' and                                       // DK02
            Type <> '*YMD' and                                       // DK02
            Type <> '*MDY' and                                       // DK02
            Type <> '*DMY';                                          // DK02
            Return DefaultDate;                                      // DK02
         endif;                                                      // DK02

         if DateIn = *zero  or  IsValidDate(DateIn : Type) = False;  // DK02
            Return DefaultDate;                                      // DK02
         endif;                                                      // DK02

         select;                                                     // DK02
            when type = '*ISO';                                      // DK02
               DateOut = %date(dateIn : *ISO);                      // DK02
            when type = '*YMD';                                      // DK02
               DateOut = %date(dateIn : *YMD);                      // DK02
            when type = '*MDY';                                      // DK02
               DateOut = %date(dateIn : *MDY);                      // DK02
            when type = '*DMY';                                      // DK02
               DateOut = %date(dateIn : *DMY);                      // DK02
         endsl;                                                      // DK02

         RETURN DateOut;                                             // DK02

      /END-FREE

     P NUM2DATE        E




      *------------------------------------------------------------------------
      * EndofPriorMonth
      *
      * Purpose: Return the date of the End Of the Prior Month
      *
      * Examples:  eom = EndOfPriorMonth();
      *            eom = EndOfPriorMonth();
      *------------------------------------------------------------------------
dk03 P EndOfPriorMonth...
dk03 P                 B                   Export
dk03 D EndOfPriorMonth...
dk03 D                 Pi              d

dk03 D EOPM            s               d
dk03 D wDate           s               d

dk03  /free

dk03       wDate  = %date - %months(1);
dk03       EOPM = EndOfMonth(wDate);
dk03       return EOPM;  // End Of Prior Month

dk03  /end-free

dk03 P EndOfPriorMonth...
dk03 P                 E




      *------------------------------------------------------------------------
      * StartofPriorMonth
      *
      * Purpose: Return the date of the Start Of the Prior Month
      *
      * Examples:  eom = StartOfPriorMonth();
      *            eom = StartOfPriorMonth();
      *------------------------------------------------------------------------
dk03 P StartOfPriorMonth...
dk03 P                 B                   Export
dk03 D StartOfPriorMonth...
dk03 D                 Pi              d

dk03 D SOPM            s               d
dk03 D wDate           s               d

dk03  /free

dk03       wDate  = %date - %months(1);
dk03       SOPM = StartOfMonth(wDate);
dk03       return SOPM;  // Start Of Prior Month

dk03  /end-free

dk03 P StartOfPriorMonth...
dk03 P                 E

      *##########################
      * NON-EXPORTED PROCEDURES *
      *##########################
