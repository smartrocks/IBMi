     H NOMAIN

      /copy copybook,socket_h
      /copy protype,sockutilpr

     D CalcBitPos      pr
     D  Descr                        10i 0
     D  ByteNo                        5i 0
     D  BitMask                       1




     P RdLine          b                   export

     D RdLine          pi            10i 0
     D  SockDesc                     10i 0 value
     D  Line                           *   value
     D  Length                       10i 0 value
     D  XLate                          n   const options(*nopass)
     D  LF                            1    const options(*nopass)
     D  CR                            1    const options(*nopass)

     D Buffer          s          32766    based(Line)
     D WrkLength       s             10i 0
     D RcvLength       s             10i 0
     D RcvChr          s              1
     D WrkXLate        s               n
     D WrkLF           s              1
     D WrkCR           s              1

      * Set the default values to unpassed parms
     C                   if        %parms() > 3
     C                   eval      WrkXLate = XLate
     C                   else
     C                   eval      WrkXLate = '0'
     C                   endif

     C                   if        %parms() > 4
     C                   eval      WrkLF = LF
     C                   else
     C                   eval      WrkLF = x'0A'
     C                   endif

     C                   if        %parms() > 5
     C                   eval      WrkCR = CR
     C                   else
     C                   eval      WrkCR = x'0D'
     C                   endif

      * Clear the line of data
     C                   eval      %subst(Buffer:1:Length) = *blanks

     C                   dow       1 = 1

      * Read 1 byte of data
     C                   eval      RcvLength = recv(SockDesc:%addr(RcvChr):1:0)
     C                   if        RcvLength < 1
     C                   if        WrkLength > 0
     C                   leave
     C                   else
     C                   return    -1
     C                   endif
     C                   endif

      * if LF is found, were done reading
     C                   if        RcvChr = WrkLF
     C                   leave
     C                   endif

      * Any other character besides CR gets added to the buffer
     C                   if        RcvChr <> WrkCR
     C                   eval      WrkLength += 1
     C                   eval      %subst(Buffer:WrkLength:1) = RcvChr
     C                   endif

      * If buffer is full, exit now -- there is no space to read the data into
     C                   if        WrkLength = Length
     C                   leave
     C                   endif

     C                   enddo

      * Translate ASCII to EBCDIC if necessary
     C                   if        WrkXLate and WrkLength > 0
     C                   callp     Translate(WrkLength:Buffer:'QTCPEBC')
     C                   endif

     C                   return    WrkLength

     P RdLine          e



     P WrLine          b                   export

     D WrLine          pi            10i 0
     D  SockDesc                     10i 0 value
     D  Line                        256    const
     D  Length                       10i 0 value options(*nopass)
     D  XLate                          n   const options(*nopass)
     D  EOL1                          1    const options(*nopass)
     D  EOL2                          1    const options(*nopass)

     D Buffer          s            256
     D WrkLength       s             10i 0
     D WrkXLate        s               n
     D WrkEOL          s              2
     D WrkEOLLength    s             10i 0
     D SendLength      s             10i 0

      * If the length was not passed or the length passed is not -1, calculate the length
      *  of data to send.
     C                   if        %parms > 2 and Length <> -1
     C                   eval      WrkLength = Length
     C                   else
     C                   eval      WrkLength = %len(%trim(Line))
     C                   endif

     C                   if        %parms() > 3
     C                   eval      WrkXLate = XLate
     C                   else
     C                   eval      WrkXLate = '0'
     C                   endif

      * Set the end of line character(s)
     C                   eval      WrkEOL = ' '
     C                   eval      WrkEOLLength = 0

     C                   if        %parms() > 4
     C                   eval      %subst(WrkEOL:1:1) = EOL1
     C                   eval      WrkEOLLength = 1
     C                   endif

     C                   if        %parms() > 5
     C                   eval      %subst(WrkEOL:2:1) = EOL2
     C                   eval      WrkEOLLength = 2
     C                   endif

     C                   if        WrkEOLLength = 0
     C                   eval      WrkEOL = x'0D0A'
     C                   eval      WrkEOLLength = 2
     C                   endif

      * Translate the data to ASCII if necessary
     C                   eval      Buffer = Line
     C                   if        WrkXLate and WrkLength > 0
     C                   callp     Translate(WrkLength:Buffer:'QTCPASC')
     C                   endif

      * Send the buffer, followed by the end of line and return te length of data sent
     C                   if        WrkLength > 0
     C                   eval      SendLength = Send(SockDesc:%addr(Buffer):
     C                              WrkLength:0)
     C                   if        SendLength < WrkLength
     C                   return    SendLength
     C                   endif
     C                   endif

     C                   eval      SendLength = Send(SockDesc:%addr(WrkEOL):
     C                              WrkEOLLength:0)
     C                   if        SendLength < WrkEOLLength
     C                   return    SendLength
     C                   endif

     C                   return    SendLength + WrkLength

     P WrLine          e



     P FD_SET          b                   export

     D FD_SET          pi
     D  FD                           10i 0
     D  FDSet                        28

     D WkByteNo        s              5i 0
     D WkMask          s              1
     D WkByte          s              1

     C                   callp     CalcBitPos(FD: WkByteNo: WkMask)
     C                   eval      WkByte = %subst(FDSet: WkByteNo: 1)
     C                   biton     WkMask        WkByte
     C                   eval      %subst(FDSet: WkByteNo: 1) = WkByte

     P FD_SET          e



     P FD_CLR          b                   export

     D FD_CLR          pi
     D  FD                           10i 0
     D  FDSet                        28

     D WkByteNo        s              5i 0
     D WkMask          s              1
     D WkByte          s              1

     C                   callp     CalcBitPos(FD: WkByteNo: WkMask)
     C                   eval      WkByte = %subst(FDSet: WkByteNo: 1)
     C                   bitoff    WkMask        WkByte
     C                   eval      %subst(FDSet: WkByteNo: 1) = WkByte

     P FD_CLR          e



     P FD_ISSET        b                   export

     D FD_ISSET        pi             1n
     D  FD                           10i 0
     D  FDSet                        28

     D WkByteNo        s              5i 0
     D WkMask          s              1
     D WkByte          s              1

     C                   callp     CalcBitPos(FD: WkByteNo: WkMask)
     C                   eval      WkByte = %subst(FDSet: WkByteNo: 1)
     C                   testb     WkMask        WkByte                   88
     C                   return    *in88

     P FD_ISSET        e



     P FD_ZERO         b                   export

     D FD_ZERO         pi
     D  FDSet                        28

     D WkByteNo        s              5i 0
     D WkMask          s              1
     D WkByte          s              1

     C                   eval      FDSet = *allx'00'

     P FD_ZERO         e



     P CalcBitPos      b

     D CalcBitPos      pi
     D  Descr                        10i 0
     D  ByteNo                        5i 0
     D  BitMask                       1

     D WkGroup         s              5  0
     D WkByteNo        s              2  0
     D WkBitNo         s              2  0

     D dsMakeMask      ds
     D  dsZeroByte             1      1a
     D  dsMask                 2      2a
     D  dsBitMult              1      2u 0 inz(0)

     C     Descr         div       32            WkGroup
     C                   mvr                     WkByteNo
     C                   div       8             WkByteNo
     C                   mvr                     WkBitNo
     C                   eval      WkByteNo = 4 - WkByteNo
     C                   eval      ByteNo = (WkGroup * 4) + WkByteNo
     C                   eval      dsBitMult = 2 ** WkBitNo
     C                   eval      dsZeroByte = x'00'
     C                   eval      BitMask = dsMask

     P CalcBitPos      e
