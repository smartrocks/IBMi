wj001H*Nomain
wj001H Nomain bnddir('QC2LE')
wj001 * The order in which the members should be implemented is:-
      * 1/.  STRINGBN  (BNDSRC) binding source and/or
      *      STRINGPR  (PROTYPE) prototype
      * 2/.  STRINGSP  (SRVMOD) service module
      * 3/.  STRINGSP  (RPGSRV) service program

      * When implementing the service program, use
      * option 1 (Override creation attribute) with the following
      * parameters:-
      * Service program  . . . . . . . . > STRINGSP
      *   Library  . . . . . . . . . . . >   #PGMLIB
      * Module . . . . . . . . . . . . .   STRINGSP
      *   Library  . . . . . . . . . . .     *LIBL
      * Export . . . . . . . . . . . . . > *SRCFILE
      * Export source file . . . . . . .   QBNDSRC
      *   Library  . . . . . . . . . . .     NBTYGPL
      * Export source member . . . . . .   STRINGBN
      *
‚     **********************************************************************
‚     * MODIFICATIONS:
‚     * -------------
‚     *   Date      PGMR     MOD     Reasons
‚     * --------  ---------  ----  -----------------------------------------
‚     * 07/18/05  Alans     AS001  Included the Prototype for the new Service Progarm
‚     *                            REMOVE2BLNK. This service program will trim ALL
‚     *                            leading spaces from the input data, AND replace
‚     *                            ALL multiple blanks in between words, with single
‚     *                            blanks.
‚     *
wj001 * 11/22/06  willie   wj001   proj 12429 letter project call java routine to
wj001 *                            convert name to personal greeting
‚     *
AM001 * 09/08/08  Amarnath AM001   Proj-AROMA. Ean Code Check digit Validation.
AM001 *
      * 08/19/10  Lloyd    lb001   Added procedure like, which functions similar
      *                            to the SQL like pattern match function, with
      *                            limitations
      * 12/16/10  Lloyd    lb002   Fix bug in FindAndReplace. If you request to replace a string
      *                            with a value that contains that replace string value, the
      *                            routine gets caught in loop.
‚     **********************************************************************

     FBadHexChr if   e             disk    usropn

      * Prototypes
wj001 /Copy PROTYPE,STRINGPR

       //-------------------------------------------------------------------------------------------
       //                                Global ProtoTypes
       //-------------------------------------------------------------------------------------------
     D ibmIConvOpen    Pr                  extproc('QtqIconvOpen')
     D                                     LikeDS(iconv_T)
     D  toCCSID                            LikeDS(QtqCode_T)
     D  fromCCSID                          LikeDS(QtqCode_T)

     D ibmIConv        Pr            10u 0 extproc('iconv')
     D  hConv                              LikeDS(iconv_t) VALUE
     D  pInBuff                        *   VALUE
     D  nInLen                         *   VALUE
     D  pOutBuff                       *   VALUE
     D  nOutLen                        *   VALUE

     D ibmIconvClose   Pr            10i 0 extproc('iconv_close')
     D  hConv                              LikeDS(iconv_t) VALUE

       //-------------------------------------------------------------------------------------------
       //                          Global Data Structure Templates
       //-------------------------------------------------------------------------------------------
     D qtqCode_T       DS                  Qualified
     D  CCSID                        10I 0 Inz(0)
     D  cvtAlt                       10I 0 Inz(0)
     D  subAlt                       10I 0 Inz(0)
     D  shiftState                   10I 0 Inz(1)
     D  inLenOpt                     10I 0 Inz(0)
     D  mixDataErrorOpt...
     D                               10I 0 Inz(0)
     D  reserved                      8A   Inz(*ALLX'00')

     D iConv_t         DS                  Qualified
     D  rtn_value                    10I 0
     D  cd                           10I 0 Dim(12)

      **********************************************************************
      * Find RMVCHAR in RMVFROM and remove it with a concatination
      **********************************************************************
     P RemoveAndCat    b                   export

     D RemoveAndCat    pi         32765    varying
     D  RmvChar                   32765    value varying
     D  RmvFrom                   32765    value varying
     D  StrPos                        5  0 const options(*nopass)

     D Ix              s              5  0
     D Iy              s              5  0
     D Iz              s              5  0
     D St              s              5  0

     C                   if        %parms > 2
     C                   eval      St = StrPos
     C                   else
     C                   eval      St = 1
     C                   endif

     C                   eval      RmvFrom = %trim(RmvFrom)
     C                   dou       Ix = 0 or St > %len(%trim(RmvFrom))
     C                   eval      Ix = %scan(RmvChar:RmvFrom:St)
     C                   if        Ix <> 0
     C                   eval      Iy = Ix+%len(RmvChar)
     C                   eval      Iz = %len(RmvFrom)
     C                   if        Ix+%len(RmvChar) > %len(RmvFrom)
     C                   eval      RmvFrom = %subst(RmvFrom:1:Ix-1)
     C                   else
     C                   eval      RmvFrom=%subst(RmvFrom:1:Ix-1) +
     C                               %subst(RmvFrom:Ix+%len(RmvChar))
     C                   endif
     C                   endif

     C                   enddo

     C                   return    %trim(RmvFrom)

     P                 e



      **********************************************************************
      * Find FINDCHAR in FROMSTRING and Replace it With REPLACECHAR
      **********************************************************************
     P FindAndReplace  b                   export

     D FindAndReplace  pi         32765    varying
     D  FindChar                  32765    value varying
     D  FromString                32765    value varying
     D  ReplaceChar               32765    value varying
     D  StrPos                        5  0 const options(*nopass)

     D Ix              s              5  0
     D St              s              5  0

     C                   if        %parms > 3
     C                   eval      St = StrPos
     C                   else
     C                   eval      St = 1
     C                   endif

     C                   dou       Ix = 0 or St > %len(%trim(FromString))
     C                   eval      Ix = %scan(FindChar:FromString:St)
     C                   if        Ix <> 0
     C                   if        Ix+%len(FindChar) < %len(FromString)
     C                   eval      FromString=%subst(FromString:1:Ix-1) +
     C                               ReplaceChar +
     C                               %subst(FromString:Ix+%len(FindChar))
     C                   else
     C                   eval      FromString = %subst(FromString:1:Ix-1) +
     C                               ReplaceChar
     C                   endif
                         // The next starting position is current position + length
                         // of string to replace with.
lb002C                   eval      St = Ix + %len(ReplaceChar)
     C                   endif

     C                   enddo

     C                   return    %trim(FromString)

     P                 e

      **********************************************************************
      * Convert a character field into a numeric field
      **********************************************************************
     P NumFromChar     b                   export
     D                 pi            25p 9
     D String                        32a   value
     D OptValid                       1a   options(*nopass)
     D IsNumber        s              1a   inz(*off)
     D Value           s             25p 9 inz(0)
     D StringLength    s             10i 0 inz(0)
     D WorkString      s             33a   inz(*blanks)
     D ThisChar        s              1a   based(ThisChar@)
     D ThisChar@       s               *
     D LastChar        s              1a   based(LastChar@)
     D LastChar@       s               *
     D Digit           s              1p 0
     D Negative        s              1a   inz(*off)
     D IntoDecimals    s              1a   inz(*off)
     D DecPlace        s             10u 0 inz(10)

     C                   do
     C                   if        String = *blanks
     C                   eval      IsNumber = *on
     C                   leave
     C                   endif

     C                   eval      WorkString = %trim(String)
     C                   eval      StringLength = %len(%trim(WorkString))
     C                   eval      IsNumber = *on
     C                   eval      Negative = *off
     C                   eval      ThisChar@ = %addr(WorkString)
     C                   eval      LastChar@=ThisChar@+StringLength-1

     C                   select

     C                   when      ThisChar='(' and LastChar = ')'
     C                   eval      Negative=*on
     C                   eval      ThisChar=*blanks
     C                   eval      LastChar=*blanks

     C                   when      ThisChar='-'
     C                   eval      ThisChar=*blanks
     C                   eval      Negative=*on

     C                   when      ThisChar='+'
     C                   eval      ThisChar=*blanks

     C                   when      LastChar='-'
     C                   eval      LastChar=*blanks
     C                   eval      Negative=*on

     C                   when      LastChar='+'
     C                   eval      LastChar=*blanks

     C                   when      LastChar = 'R' and StringLength > 1
     C                   eval      ThisChar@=LastChar@-1
     C                   if        ThisChar='C'
     C                   eval      negative=*on
     C                   eval      ThisChar=*blanks
     C                   eval      LastChar=*blanks
     C                   endif

     C                   endsl

     C                   eval      WorkString=%trim(WorkString)
     C                   eval      StringLength = %len(%trim(WorkString))
     C                   eval      ThisChar@ = %addr(WorkString)
     C                   eval      LastChar@=ThisChar@+StringLength-1

     C                   dow       ThisChar@ <= LastChar@

     C                   eval      Digit = IsDigit(ThisChar)

     C                   select
     C                   when      ThisChar=*blanks
     C                   eval      Isnumber=*off
     C                   leave

     C                   when      ThisChar='.' and IntoDecimals=*off
     C                   eval      IntoDecimals=*on

     C                   when      Digit >= *zero
     C                   if        IntoDecimals = *off
     C                   eval      value = (value*10) + digit
     C                   else
     C                   eval      value = value + (digit/decplace)
     C                   eval      decplace=decplace * 10
     C                   endif

     C                   when      ThisChar = ','

     C                   other
     C                   eval      isnumber = *off
     C                   leave
     C                   endsl

     C                   eval      ThisChar@ = ThisChar@ + 1

     C                   enddo

     C                   if        isnumber = *on and negative = *on
     C                   eval      value = value * -1
     C                   endif

     C                   enddo

     C                   if        %parms > 1
     C                   eval      optvalid=isnumber
     C                   endif

     C                   if        isnumber = *on
     C                   return    value
     C                   else
     C                   return    *zero
     C                   endif
     P                 e

      **********************************************************************
      *  returns integer 0-9 if Digit is in range 0-9, else returns - 1
      **********************************************************************
     P IsDigit         b                   export
     D                 pi             5i 0
     D digit                          1a   value
     D signedds        ds
     D  number                        1s 0
     D  Char                          1a   overlay(Number:1)
     C                   if        Digit < '0' or Digit > '9'
     C                   return    -1
     C                   endif
     C                   eval      Char = Digit
     C                   return    Number
     P                 e
AS018 *****************************************************************
‚     * Removes ALL leading spaces, and all occurrences of multiple
‚     * blanks between characters.
‚     *****************************************************************
AS018P Remove2blnk     b                   export
      *
AS018D Remove2blnk     pi         32765    varying
AS018D Adrline                    32765    value varying
‚     *
AS018D Len2            s              7  0
AS018D Len3            s              7  0
AS018D Pos2            s              7  0
AS018D Strpos          s              7  0 inz(1)
AS018D Hldline         s          32765
‚     *
AS018C                   Eval      Hldline = %trim(Adrline)
AS018C                   Eval      Len2 = %len(%trim(Hldline))
AS018C                   eval      Pos2 = Len2
AS018C                   Eval      Len3 = %len('  ')
AS018C                   dou       Pos2 = 0 or
AS018C                             Pos2 > Len2
AS018C                   eval      Pos2 = 0
AS018C     '  ':LEN3     scan      Hldline:StrposPos2
AS018C                   if        Pos2 <> 0 and
AS018C                             Pos2 <= Len2
AS018C                   Eval      Hldline = %replace(' ':Hldline:Pos2:Len3)
AS018C                   Eval      Len2 = %len(%trim(Hldline))
AS018C                   endif
AS018C                   enddo
     C                   return    Hldline
‚     *
AS018P Remove2blnk     e
‚     *
      * Thanks to Hans Boldt from IBM for the code below.
     P center          b                   export
     D center          pi           100a   varying
     D   instr                      100a   value varying
     D   len                         10i 0 value
     D outstr          s            100a   varying
     D pos             s             10i 0
      /free
         // Check if input string is bigger than desired output
         instr = %trim(instr);
         if %len(instr) > len;
            %len(instr) = len;
         endif;

         // Find position of centered string in output
         pos = %div(len - %len(instr):2) + 1;

         // Build and return centered output string
         %len(outstr) = len;
         %subst(outstr:pos) = instr;
         return outstr;
      /end-free
     P center          e
wj001 ***************************************************************************
wj001 * convert name to friendly
wj001 *   Returns the Tracking Number
wj001 *   Parm: ACCT# , Package#, Error Flag
wj001 **********************************************************************
wj001P Cnvnamadr       b                   export

wj001D Cnvnamadr       pi            30
wj001D  namein                       30    value
wj001d NewCaseConverter...
wj001D                 pr              O   extproc(*java:
wj001d                                      'com.nbty.activecase.CaseConverter':
wj001d                                      *constructor)
wj001d                                     class(*java:
wj001d                                     'com.nbty.activecase.CaseConverter')

wj001d CaseConverterObj...
wj001d                 s               O    class(*java:
wj001d                                     'com.nbty.activecase.CaseConverter')

wj001d ConvertString...
wj001D                 pr              O   extproc(*java:
wj001d                                      'com.nbty.activecase.CaseConverter':
wj001d                                      'convertString')
wj001d                                     class(*java:'java.lang.String')
wj001d Name                            O   class(*java:'java.lang.String')
wj001d Type                            O   class(*java:'java.lang.String')

wj001d NewString...
wj001d                 pr              O   extproc(*java:
wj001d                                      'java.lang.String':
wj001d                                      *constructor)
wj001d                                     class(*java:
wj001d                                     'java.lang.String')
wj001d*trimstring      PR              O   EXTPROC(*java:
wj001d*                                     'java.lang.String':
wj001d*                                     'trim')
wj001d*                                    class(*java:
wj001d*                                    'java.lang.String')
wj001d  Bytes                     32767    varying

wj001d StringGetBytes...
wj001D                 pr         32767    extproc(*java:
wj001d                                      'java.lang.String':
wj001d                                      'getBytes')
wj001d                                     varying

wj001d ConvertNameObj...
wj001d                 s               O    class(*java:
wj001d                                     'java.lang.String')
wj001d ConvertTypeObj...
wj001d                 s               O    class(*java:
wj001d                                     'java.lang.String')
wj001d ConvertedNameObj...
wj001d                 s               O    class(*java:
wj001d                                     'java.lang.String')

wj001d convertthis     s          32767      varying
wj001d ConvertType     s          32767    inz('Name') varying
wj001d ConvertedName   s             30

wj001D classpath       PR                  ExtPgm('CVNNAMECL')


wj001 /free

wj001      callp classpath();


wj001  // THIS WORKS
wj001   convertthis = namein;
wj001  ConvertNameObj = NewString(ConvertThis);
wj001  ConvertTypeObj = NewString(ConvertType);
wj001  ConvertedName = StringGetBytes(ConvertNameObj);

wj001  ConvertedName = StringGetBytes(ConverttypeObj);
wj001  // THIS DOESNT WORK
wj001  CaseConverterObj = NewCaseConverter();
wj001  ConvertNameObj = NewString(ConvertThis);
wj001  ConvertTypeObj = NewString(ConvertType);
wj001  ConvertedNameObj = ConvertString(CaseConverterObj:
wj001                                   ConvertNameObj:
wj001                                   ConvertTypeObj);
wj001  //
wj001            /////ConvertNameObj = trimstring(ConvertNameObj);
wj001  //
wj001  // ConvertedNameObj = ConvertString(
wj001  //                                 ConvertNameObj:
wj001  //                               ConvertTypeObj);
wj001     ConvertedName = StringGetBytes(ConvertedNameObj);

wj001      return ConvertedName;

wj001 /end-free

wj001P Cnvnamadr       e

wj001 ***************************************************************************
wj001 * Remove Bad Hex Characters
wj001 **********************************************************************
wj001P RmvBadChar      b                   export

wj001D RmvBadChar      pi         65535    varying
wj001D  inString                  65535    value varying

     D ReturnString    s          65535    varying
     D Pos             s              5i 0
     D iX              s              5i 0
     D badChar         s              1
     D firstCall       s               n   Static Inz('1')
     D iY              s             10i 0 Static
     D badCharArray    s              1    dim(9999) Static
     D replCharArray   s              1    dim(9999) Static

      /free

       ReturnString = InString;

       // If this is the first time the procedure is called,
       // then load up the static badCharArray
       if firstCall;
         open BadHexChr;
         dou %eof(BadHexChr);
           read BadHexChr;
           if not %eof(BadHexChr);
             iY += 1;
             badCharArray(iY) = BHCChar;
             replCharArray(iY) = BHCRepl;
           endif;
         enddo;
         clear firstCall;
         close BadHexChr;
       endif;

       clear iX;
       dou iX = iY;
         iX += 1;
         badChar = badCharArray(iX);

         clear Pos;
         dou Pos = 0 or Pos = %len(ReturnString);
           Pos = %scan(BadChar: ReturnString: Pos+1);
           if Pos > 0;
             ReturnString = %replace(replCharArray(iX): ReturnString:
                             Pos: %len(BHCChar));
           endif;
         enddo;

       enddo;

       return ReturnString;

wj001 /end-free

wj001P RmvBadChar      e
AM001 **********************************************************************
|     *  Returns the EAN code check digit validation result
|     **********************************************************************
|    P EanCheckDigit   b                   export
|    D EanCheckDigit   pi             1a
|    D eancode                       20
|    d*----------------------------------------------------------------
|    d*  Work variables used  to hold sum values
|    d*----------------------------------------------------------------
|    d odd             s              3  0
|    d newodd          s              4  0
|    d even            s              3  0
|    d total           s              5  0
|    d hold            s              1
|    d hold#           s              1  0
|    d hold@           s              2  0
|    d eanhld          s              1  0
|    d eanflg          s              1
|    d
|    d                 ds
|    d eancder                       20  0
|    d  ean#a                        20    overlay(eancder)
|    d   ean1                         1  0 overlay(ean#a)
|    d   ean2                         1  0 overlay(ean#a:2)
|    d   ean3                         1  0 overlay(ean#a:3)
|    d   ean4                         1  0 overlay(ean#a:4)
|    d   ean5                         1  0 overlay(ean#a:5)
|    d   ean6                         1  0 overlay(ean#a:6)
|    d   ean7                         1  0 overlay(ean#a:7)
|    d   ean8                         1  0 overlay(ean#a:8)
|    d   ean9                         1  0 overlay(ean#a:9)
|    d   ean10                        1  0 overlay(ean#a:10)
|    d   ean11                        1  0 overlay(ean#a:11)
|    d   ean12                        1  0 overlay(ean#a:12)
|    d   ean13                        1  0 overlay(ean#a:13)
|    d   ean14                        1  0 overlay(ean#a:14)
|    d   ean15                        1  0 overlay(ean#a:15)
|    d   ean16                        1  0 overlay(ean#a:16)
|    d   ean17                        1  0 overlay(ean#a:17)
|    d   ean18                        1  0 overlay(ean#a:18)
|    d   ean19                        1  0 overlay(ean#a:19)
|    d   ean20                        1  0 overlay(ean#a:20)
|    d
|     *---------
|     * SUM ALL DIGITS IN THE ODD POSITIONS
|     *---------
|    c                   move      eancode       eancder
|     /Free
|       odd = ean7 + ean9 + ean11 + ean13 + ean15 + ean17 + ean19;
|
|                // MULTIPLY THIS SUM BY THREE
|
|      newodd = odd * 3;
|
|                // SUM ALL DIGITS IN THE EVEN POSITIONS
|
|      even = ean8 + ean10 + ean12 + ean14 + ean16 + ean18;
|
|                // ADD THIS SUM TO THE PRODUCT CALCULATED FROM THE ODD
|
|      total = even + newodd;
|
|     /end-free
|     *
|     *---------
|    c*  CALCULATE 14TH POSITION OF EAN CODE
|     *---------
|     *
|    c                   move      total         hold
|    c                   move      hold          hold#
|    c     10            sub       hold#         hold@
|    c                   if        hold@ = 10
|    c                   movel     *zero         eanhld
|    c                   else
|    c                   move      hold@         eanhld
|    c                   endif
|     *
|    c                   if        eanhld <> ean20
|    c                   move      *on           eanflg
|    c                   else
|    c                   move      *off          eanflg
|    c                   endif
|     *
|    c                   return    eanflg
|     *
|    P EanCheckDigit   e
AM001 *

      ***************************************************************************
      * Convert a string from one CCSID to another CCSID
      **********************************************************************
     P convertCCSID    b                   export

     D convertCCSID    pi         65535    varying
     D  inString                  65535    varying const
     D  inFromCCSID                   5  0 const
     D  inToCCSID                     5  0 const

     D fromCCSID       DS                  LikeDS(QtqCode_T)
     D                                     Inz(*LIKEDS)
     D toCCSID         DS                  LikeDS(QtqCode_T)
     D                                     Inz(*LIKEDS)
     D hConv           DS                  LikeDS(iconv_T)
     D                                     Inz(*LIKEDS)

     D input           S          65535
     D pInput          s               *
     D ppInput         s               *   inz(%addr(pInput))
     D output          S          65535
     D pOutput         s               *
     D ppOutput        s               *   inz(%addr(pOutput))
     D inputLen        S             10I 0
     D outputLen       S             10I 0
     D rc              S             20I 0

      /free

       clear output;

       fromCCSID.CCSID = inFromCCSID;
       toCCSID.CCSID = inToCCSID;
       hConv = *ALLX'00';
       hConv = ibmIConvOpen(toCCSID:fromCCSID);

       input = inString;
       inputLen = %len(%trimr(input));
       pInput = %addr(input);
       outputLen = %size(output);
       pOutput = %addr(output);

       ibmIConv(hConv:ppInput:%addr(inputLen):ppOutput:%addr(outputLen));

       ibmIconvClose(hConv);

       return %TRIMR(output);

      /end-free

     P convertCCSID    e


      //********************************************************************************************
      // Routine similar to the SQL "Like" pattern match function.
      //
      // return '1' - if pattern exists in the search string
      // otherwise, return '0'
      //
      // Limitations:
      //  - This routine can not ignore the case of the characters.
      //  - It does not have the capability to do single character (underscore "_") patterns.
      //  - Leading & trailing spaces are significant. Use %trim(R or L) when necessary.
      //
      // Examples:
      // 1) parmSearch = "ABCDEF"
      //    parmPattern = "AB%F" <- Must begin with AB and end with F
      //    Like(%trim(parmSearch), %trim(parmPattern)) will return true
      //
      // 2) parmSearch = "ABCDEF"
      //    parmPattern = "AB%D" <- Must begin with AB and end with D
      //    Like(parmSearch, parmPattern) will return false, does not end with D
      //
      // 2) parmSearch = "ABCDEF"
      //    parmPattern = "AB*E*" <- Must begin with AB and contain E after AB.
      //    Like(parmSearch, parmPattern, "*") will return true
      //
      // The trick to this program is treating the wildcard as a delimiter
      //
      // Note: Trailing spaces are counted in the pattern so truncate
      //       trailing spaces where necessary!
      //
      //       A wildcard must be passed otherwise the test will fail
      //       (even if a wildcard isn't specified in the pattern)
      //
      //********************************************************************************************
lb001PLike             B                   Export
lb001DLike             PI              N
lb001D parmSearch                 32767    Const Varying
lb001D parmPattern                  256    Const Varying
lb001D parmWildCard                  10    Const Varying
lb001D                                     Options(*NoPass)

lb001DwrkWildCard      S                   Like(parmWildCard) Inz('%')
lb001DarrPattern       S            256    Dim(128) Varying
lb001DStart            S              5I 0
lb001DEnd              S              5I 0
lb001DCount            S              5I 0
lb001DNoPatterns       S              5I 0
lb001Di                S              5I 0
lb001DMatch            S               N   Inz(*On)
lb001DMatchBegin       S               N   Inz(*On)
lb001DMatchEnd         S               N   Inz(*On)

     C/Free
         //
         // Override default wildcard when supplied
         //
lb001    If %Parms>=3;
lb001        wrkWildCard=parmWildCard;
lb001    EndIf;
         //
         // Ignore cases we know will fail
         //
lb001    If %Len(wrkWildCard)=*Zero
lb001    Or %Len(wrkWildCard)>%Len(parmPattern)
lb001    Or %Len(wrkWildCard)>%Len(parmSearch);
lb001        Return *Off;
lb001    EndIf;
         //
         // Test if we need to do an exact match at the beginning
         //
lb001    If %Subst(parmPattern:1:%Len(wrkWildCard))=wrkWildCard;
lb001        MatchBegin=*Off;
lb001    EndIf;
         //
         // Test if we need to do an exact match at the end
         //
lb001    If %Subst(parmPattern:%Len(parmPattern)-%Len(wrkWildCard)+1:
lb001       %Len(wrkWildCard))=wrkWildCard;
lb001        MatchEnd=*Off;
lb001    EndIf;

lb001    Start=1;
lb001    End=%Scan(wrkWildCard:parmPattern);

lb001    Dow End>*Zero
lb001    And Count<%Elem(arrPattern);
lb001        Count+=1;
lb001        arrPattern(Count)=%Subst(parmPattern:Start:(End-Start));
lb001        Start=End+1;
lb001        If Start<=%Len(parmPattern);
lb001            End=%Scan(wrkWildCard:parmPattern:Start);
lb001        Else;
lb001            End=*Zero;
lb001        EndIf;
lb001    EndDo;

         // Get Last Pattern in List
lb001    If Start<=%Len(parmPattern)
lb001    And Count<%Elem(arrPattern)
lb001    And End=*Zero;
lb001        Count+=1;
lb001        arrPattern(Count)=%Subst(parmPattern:Start);
lb001    EndIf;
lb001    NoPatterns=Count;


         // For each pattern identified, test if it exists in the search
         // string.
lb001    Start=1;
lb001    For i=1 To NoPatterns;
lb001        If arrPattern(i)>'';
lb001            // Bail if pattern too long or not found
lb001            If %Len(arrPattern(i))<=%Len(parmSearch)-Start+1;
lb001                Start=%Scan(arrPattern(i):parmSearch:Start);
lb001                If Start=*Zero;
lb001                    Match=*Off;
lb001                    Leave;
lb001                EndIf;
lb001            Else;
lb001                Match=*Off;
lb001                Leave;
lb001            EndIf;
lb001            Start+=%Len(arrPattern(i));
lb001        EndIf;
lb001    EndFor;
         //
         // If required, test for exact matches
         //
lb001    If Match And MatchBegin;
lb001        If %Subst(parmSearch:1:%Len(arrPattern(1)))<>arrPattern(1);
lb001            Return *Off;
lb001        EndIf;
lb001    EndIf;

lb001    If Match And MatchEnd;
lb001        If %Subst(parmSearch:%Len(parmSearch) -
lb001                             %Len(arrPattern(NoPatterns))+1:
lb001            %Len(arrPattern(NoPatterns)))<>arrPattern(NoPatterns);
lb001            Return *Off;
lb001        EndIf;
lb001    EndIf;

lb001    Return Match;
      /End-Free
lb001PLike             E
      ***************************************************************************
      * Convert a string to mixed case
      **********************************************************************
AS019  dcl-proc Cr8mixedcase  export;

AS019  dcl-pi Cr8mixedcase        varchar(32767);
AS019   in_Name                   varchar(32767) const;
AS019  end-pi;

       dcl-s HoldFullName            char(60);
       dcl-s HoldChar                char(1);
       dcl-s First_space             zoned(6:0);
       dcl-s Ia                      zoned(6:0);
       dcl-s Ib                      zoned(6:0);
       dcl-s Ic                      zoned(6:0);
       dcl-s Id                      zoned(6:0);
       dcl-s Ie                      zoned(6:0);
       dcl-s Ig                      zoned(6:0);
       dcl-s Ih                      zoned(6:0);
       dcl-s Ii                      zoned(6:0);
       dcl-s Ij                      zoned(6:0);
       dcl-s Ik                      zoned(6:0);
       dcl-s Il                      zoned(6:0);
       dcl-s Im                      zoned(6:0);
       dcl-s Iq                      zoned(6:0);
       dcl-s Ir                      zoned(6:0);
       dcl-s Is                      zoned(6:0);
       dcl-s It                      zoned(6:0);
       dcl-s Ix                      zoned(6:0);
       dcl-s Iy                      zoned(6:0);

       dcl-ds Holdname_full;
         Holdname                char(32766);
         Holdnameind             char(1) dim(32766) pos(1);
       end-ds;

        HoldFullName = in_Name;
        exsr Name_as_case;

        return HoldName;
        //------------------------------------------------------------------
        begsr Name_as_case;

          exec sql
            select lower(:HoldFullName)  into :Holdname from SYSIBM.SYSDUMMY1;
          HoldChar = HoldNameInd(1);
          exec sql
            select upper(:HoldChar) into :HoldChar from SYSIBM.SYSDUMMY1;
          HoldNameInd(1) = Holdchar;
          First_space = 0;
          Iy = 1;
          Ir = 1;
          It = 1;
          Ib = 1;
          Id = 1;
          Ig = 1;
          Ii = 1;
          Ik = 1;
          Im = 1;
          Dou Ix = 0;
            select;
            when Iy > %len(%trim(Holdname));
              Ix = 0;
            other;
              Ix = %scan(' ' : %trim(Holdname) : Iy);
              if First_space = 0;
                First_space = Ix;
              endif;
              if Ix <> 0;
                Iy = Ix + 1;
                HoldChar = HoldNameInd(Iy);
                exec sql
                  select upper(:HoldChar) into :HoldChar from SYSIBM.SYSDUMMY1;
                HoldNameInd(Iy) = Holdchar;
              endif;
            endsl;
          enddo;
          Dou Iq = 0;
            select;
            when Ir > %len(%trim(Holdname));
              Iq = 0;
            other;
              Iq = %scan('.' : %trim(Holdname) : Ir);
              if Iq <> 0;
                Ir = Iq + 1;
                HoldChar = HoldNameInd(Ir);
                exec sql
                  select upper(:HoldChar) into :HoldChar from SYSIBM.SYSDUMMY1;
                HoldNameInd(Ir) = Holdchar;
              endif;
            endsl;
          enddo;
          Dou Is = 0;
            select;
            when It > %len(%trim(Holdname));
              Is = 0;
            other;
              Is = %scan('''' : %trim(Holdname) : It);
              if Is <> 0;
                if Is > First_space;
                  Ix = Is + 2;
                  It = Is + 1;
                  if HoldNameInd(Ix) <> ' ';
                    HoldChar = HoldNameInd(It);
                    exec sql
                      select upper(:HoldChar) into :HoldChar
                        from SYSIBM.SYSDUMMY1;
                    HoldNameInd(It) = Holdchar;
                  endif;
                else;
                  Is = 0;
                endif;
              endif;
            endsl;
          enddo;
          Dou Ia = 0;
            select;
            when Ib > %len(%trim(Holdname));
              Ia = 0;
            other;
              Ia = %scan('/' : %trim(Holdname) : Ib);
              if Ia <> 0;
                Ib = Ia + 1;
                HoldChar = HoldNameInd(Ib);
                exec sql
                  select upper(:HoldChar) into :HoldChar from SYSIBM.SYSDUMMY1;
                HoldNameInd(Ib) = Holdchar;
              endif;
            endsl;
          enddo;
          Dou Ic = 0;
            select;
            when Id > %len(%trim(Holdname));
              Ic = 0;
            other;
              Ic = %scan('-' : %trim(Holdname) : Id);
              Id = Ic + 1;
              HoldChar = HoldNameInd(Id);
              exec sql
                select upper(:HoldChar) into :HoldChar from SYSIBM.SYSDUMMY1;
              HoldNameInd(Id) = Holdchar;
            endsl;
          enddo;
          Dou Ie = 0;
            select;
            when Ig > %len(%trim(Holdname));
              Ie = 0;
            other;
              Ie = %scan('&' : %trim(Holdname) : Ig);
              if Ie <> 0;
                if Ie  < First_space;
                  Ig = Ie + 1;
                  HoldChar = HoldNameInd(Ig);
                  exec sql
                    select upper(:HoldChar) into :HoldChar
                      from SYSIBM.SYSDUMMY1;
                  HoldNameInd(Ig) = Holdchar;
                  Ie = 0;
                else;
                  Ie = 0;
                endif;
              endif;
            endsl;
          enddo;
          Dou Ih = 0;
            select;
            when Ii > %len(%trim(Holdname));
              Ih = 0;
            other;
              Ih = %scan(' Mc' : %trim(Holdname) : Ii);
              if Ih <> 0;
                Ii = Ih + 3;
                HoldChar = HoldNameInd(Ii);
                exec sql
                  select upper(:HoldChar) into :HoldChar from SYSIBM.SYSDUMMY1;
                HoldNameInd(Ii) = Holdchar;
              endif;
            endsl;
          enddo;
          Ii = 1;
          Dou Ih = 0;
            select;
            when Ii > %len(%trim(Holdname));
              Ih = 0;
            other;
              Ih = %scan('-Mc' : %trim(Holdname) : Ii);
              if Ih <> 0;
                Ii = Ih + 3;
                HoldChar = HoldNameInd(Ii);
                exec sql
                  select upper(:HoldChar) into :HoldChar from SYSIBM.SYSDUMMY1;
                HoldNameInd(Ii) = Holdchar;
              endif;
            endsl;
          enddo;
          Dou Ij = 0;
            select;
            when Ik > %len(%trim(Holdname));
              Ij = 0;
            other;
              Ij = %scan('(' : %trim(Holdname) : Ik);
              if Ij <> 0;
                Ik = Ij + 1;
                HoldChar = HoldNameInd(Ik);
                exec sql
                  select upper(:HoldChar) into :HoldChar from SYSIBM.SYSDUMMY1;
                HoldNameInd(Ik) = Holdchar;
              endif;
            endsl;
          enddo;
          Dou Il = 0;
            select;
            when Im > %len(%trim(Holdname));
              Il = 0;
            other;
              Il = %scan('+' : %trim(Holdname) : Im);
              if Il <> 0;
                Im = Il + 1;
                HoldChar = HoldNameInd(Im);
                exec sql
                  select upper(:HoldChar) into :HoldChar
                    from SYSIBM.SYSDUMMY1;
                HoldNameInd(Im) = Holdchar;
                Il = 0;
              endif;
            endsl;
          enddo;
          Im = 1;
          Dou Il = 0;
            select;
            when Im > %len(%trim(Holdname));
              Il = 0;
            other;
              Il = %scan('_' : %trim(Holdname) : Im);
              if Il <> 0;
                Im = Il + 1;
                HoldChar = HoldNameInd(Im);
                exec sql
                  select upper(:HoldChar) into :HoldChar
                    from SYSIBM.SYSDUMMY1;
                HoldNameInd(Im) = Holdchar;
                Il = 0;
              endif;
            endsl;
          enddo;
          Im = 1;
          Dou Il = 0;
            select;
            when Im > %len(%trim(Holdname));
              Il = 0;
            other;
              Il = %scan(',' : %trim(Holdname) : Im);
              if Il <> 0;
                Im = Il + 1;
                HoldChar = HoldNameInd(Im);
                exec sql
                  select upper(:HoldChar) into :HoldChar
                    from SYSIBM.SYSDUMMY1;
                HoldNameInd(Im) = Holdchar;
                Il = 0;
              endif;
            endsl;
          enddo;
          Holdname = %ScanRpl(' Md ' : ' MD ' : Holdname);
          Holdname = %ScanRpl(' Iii ' : ' III ' : Holdname);
          Holdname = %ScanRpl('_Iii ' : '_III ' : Holdname);
          Holdname = %ScanRpl(' Ii ' : ' II ' : Holdname);
          Holdname = %ScanRpl('_Ii ' : '_II ' : Holdname);
          Holdname = %ScanRpl(' Iv ' : ' IV ' : Holdname);
          Holdname = %ScanRpl('_Iv ' : '_IV ' : Holdname);
          Holdname = %ScanRpl(' Vi ' : ' VI ' : Holdname);
          Holdname = %ScanRpl('_Vi ' : '_VI ' : Holdname);
          Holdname = %ScanRpl(' Vii ' : ' VII ' : Holdname);
          Holdname = %ScanRpl('_Vii ' : '_VII ' : Holdname);
          Holdname = %ScanRpl(' Dds ' : ' DDS ' : Holdname);
          Holdname = %ScanRpl('_Dds ' : '_DDS ' : Holdname);
          Holdname = %ScanRpl(' Dds,' : ' DDS,' : Holdname);
          Holdname = %ScanRpl('_Dds,' : '_DDS,' : Holdname);
          Holdname = %ScanRpl(' Dvm ' : ' DVM ' : Holdname);
          Holdname = %ScanRpl('_Dvm ' : '_DVM ' : Holdname);
          Holdname = %ScanRpl(' Rso ' : ' RSO ' : Holdname);
          Holdname = %ScanRpl('_Rso ' : '_RSO ' : Holdname);
          Holdname = %ScanRpl(' Lpn ' : ' LPN ' : Holdname);
          Holdname = %ScanRpl('_Lpn ' : '_LPN ' : Holdname);
          Holdname = %ScanRpl(' Lsw ' : ' LSW ' : Holdname);
          Holdname = %ScanRpl('_Lsw ' : '_LSW ' : Holdname);
          Holdname = %ScanRpl(',m.D.' : ',M.D.' : Holdname);
          Holdname = %ScanRpl('_m.D.' : '_M.D.' : Holdname);
          Holdname = %ScanRpl(', Ms ' : ', MS ' : Holdname);
          Holdname = %ScanRpl(',_Ms ' : ',_MS ' : Holdname);
          Holdname = %ScanRpl(' Pa ' : ' PA ' : Holdname);
          Holdname = %ScanRpl('_Pa ' : '_PA ' : Holdname);
          Holdname = %ScanRpl(' Pc ' : ' PC ' : Holdname);
          Holdname = %ScanRpl('_Pc ' : '_PC ' : Holdname);
          Holdname = %ScanRpl(' Phd' : ' PhD' : Holdname);
          Holdname = %ScanRpl('_Phd' : '_PhD' : Holdname);
          Holdname = %ScanRpl(' Pllc ' : ' PLLC ' : Holdname);
          Holdname = %ScanRpl('_Pllc ' : '_PLLC ' : Holdname);
          Holdname = %ScanRpl(' Rn ' : ' RN ' : Holdname);
          Holdname = %ScanRpl('_Rn ' : '_RN ' : Holdname);
          Holdname = %ScanRpl(' Tlv ' : ' TLV ' : Holdname);
          Holdname = %ScanRpl('_Tlv ' : '_TLV ' : Holdname);
          Holdname = %ScanRpl(' And ' : ' and ' : Holdname);
          Holdname = %ScanRpl('_And ' : '_and ' : Holdname);
          Holdname = %ScanRpl(' Llc' : ' LLC' : Holdname);
          Holdname = %ScanRpl('_Llc' : '_LLC' : Holdname);
          Holdname = %ScanRpl(' Or ' : ' or ' : Holdname);
          Holdname = %ScanRpl('_Or ' : '_or ' : Holdname);
          Holdname = %ScanRpl(' Mhs' : ' MHS' : Holdname);
          Holdname = %ScanRpl('_Mhs' : '_MHS' : Holdname);
          Holdname = %ScanRpl(',iii ' : ',III ' : Holdname);
          Holdname = %ScanRpl(' Ph,d, ': 'PhD, ' : Holdname);
          Holdname = %ScanRpl(',Md ': ',MD ' : Holdname);
          Holdname = %ScanRpl('Lcsw' : 'LCSW' : Holdname);
          Holdname   = remove2blnk(Holdname);

        endsr;

AS019  end-proc Cr8mixedcase;

