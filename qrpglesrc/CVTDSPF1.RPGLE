      *--------------------------------------------------------------------
      * CvtDSPF1 - Convert a DSPF38 source member to DSPF
      *
      *--------------------------------------------------------------------
      * Date       Pgmr     Project  Task Scan Description
      * ---------- -------- ------- ----- ---- ----------------------------
      * 2005-12-29 Keck       12050  1.00      Created
      *--------------------------------------------------------------------
     H option(*NODEBUGIO : *SRCSTMT) dftactgrp(*no) actgrp('QILE')
      *--------------------------------------------------------------------
     FSRCIN     IF   E             DISK    prefix(IN_)
     F                                     rename(SrcIn : SrcInR)
      * DSPF38 source to be converted

     FSRCOUT    O    E             DISK    prefix(OUT_)
     F                                     rename(SrcOut : SrcOutR)
      * DSPF output source
      *--------------------------------------------------------------------
     D char            S              1
     D continuation    S             36    varying

     D ConvertedSegment...
     D                 S             32    varying

     D error           S             10    inz('ERROR')
     D keyword         S             72    varying
     D kwd             S              6
     D len             S              5i 0
     D MainLine        S             80
     D NewSource       S             80
     D pos             S              5i 0
     D pos2            S              5i 0
     D pos3            S              5i 0
     D pos4            S              5i 0
     D pos5            S              5i 0
     D pos6            S              5i 0
     D RtnCod          S             10
     D segment         S             32    varying
     D SegWork         S             32    varying
     D x               S              5i 0

     D                 DS
     D work                          72
     D workArray                      1    dim(72) overlay(work)
      *--------------------------------------------------------------------
     C     *entry        plist
     C                   parm                    RtnCod
      /free

         read SrcInR;    // DSPF38 source member
         dow not %eof;

            keyword = %trim(%subst(in_srcdta : 45 : 36));
            kwd = keyword;  // isolate 1st 6 positions in fixed len work field
            NewSource = in_SrcDta;

            select;
               when %subst(in_srcdta : 7 : 1) = '*';  // comment line
                  exsr out;

               when keyword = *blanks;                // no keyword
                  exsr out;

               when %scan('.' : keyword) = *zero;     // keyword without dots
                  exsr out;

               // The following conditions require special handling
               when %subst(kwd : 1 : 3) = 'REF'     or
                    %subst(kwd : 1 : 5) = 'PRINT'   or
                    %subst(kwd : 1 : 5) = 'PFILE'   or
                    %subst(kwd : 1 : 6) = 'REFFLD';
                  exsr Process;

               other;
                  exsr out;
            endsl;

            read SrcInR;    // DSPF38 source member
         enddo;


         exsr ExitPgm;



         //  ***************        ***************        ***************
         //  * SUBROUTINES *        * SUBROUTINES *        * SUBROUTINES *
         //  ***************        ***************        ***************


         begsr Process;

            MainLine = in_SrcDta;  // save in case we read continuation line

            // if continuation line exists, append it to keyword
            pos  = %len(keyword);
            char = %subst(keyword : pos : 1);
            if (char = '+')  or  (char = '-');
               exsr Continue;  // get continuation string
               // append continuation to keyword, dropping continuation symbol
               keyword = %subst(keyword : 1 : (pos - 1)) +
                         %trim(Continuation);
            endif;

            // isolate all xxx.yyy segments to be converted
            // replace converted segments in keyword
            exsr ConvertKeyword;

            // keyword has been converted. Write out the converted DDS
            exsr WriteConvertedSource;

         endsr;



         begsr ConvertKeyword;

            // isolate all xxx.yyy segments to be converted
            // replace converted segments in keyword

            // set POS2 = the position of the delimiter prior to the segment
            pos  = %scan('.' : keyword);
            dow pos <> *zero;
               work = keyword;
               pos2 = *zero;
               for x = pos DownTo 1;
                  if workArray(x) = *blank  or  workArray(x) = '(';
                     pos2 = x;
                     leave;
                  endif;
               endfor;

               // check for missing left hand delimiter
               if pos2 = *zero;
                  RtnCod = Error;
                  exsr ExitPgm;
               endif;

               // set POS6 = the position of the 1st delimiter after the segment
               pos3 = %scan(  ')'  :  keyword  : pos );
               pos5 = %scan(  ' '  :  keyword  : pos );
               select;
                  when pos3 = *zero  and  pos5 = *zero;
                     RtnCod = Error;
                     exsr ExitPgm;  // error - DDS missing righthand delimiter
                  when pos3 <> *zero  and  pos5 <> *zero;
                     if pos3 <= pos5;
                        pos6 = pos3;   // the nearest delimiter
                     else;
                        pos6 = pos5;   // the nearest delimiter
                     endif;
                  other;
                     if pos3 = *zero;
                        pos6 = pos5;   // the nearest delimiter
                     else;
                        pos6 = pos3;   // the nearest delimiter
                     endif;
               endsl;


               // isolate the segment based on the delimiter positions
               pos2 += 1;
               len = pos6 - pos2;
               segment = %subst(keyword : pos2 : len);

               // convert the isolated segment
               exsr ConvertSegment;
               %subst(keyword : pos2 : len) = ConvertedSegment;

               // find next segment
               pos  = %scan('.' : keyword);
            enddo;

         endsr;



         begsr ConvertSegment;

            // convert segment from xxx.yyy --> yyy/xxx
            pos4  = %scan('.' : segment);
            SegWork = %subst(segment : pos4 + 1 : len - pos4);
            Segwork = Segwork + '/';
            ConvertedSegment = Segwork + %subst(segment : 1 : pos4 - 1);

         endsr;



         begsr WriteConvertedSource;

            // keyword has been converted. Write out the converted DDS

            len = %len(keyword);
            if len <= 36;  // it fits on one line
               NewSource = %subst(MainLine : 1 : 44) + Keyword;
               exsr out;
            else;
               // split across two lines of source

               // write the first line
               NewSource = %subst(MainLine : 1 : 44) + Keyword;
               %subst(Newsource : 80 : 1) = '-';   // continuation char
               exsr out;

               // write the second line
               NewSource = in_SrcDta;
               %subst(NewSource : 45 : 36) = %subst(keyword : 36);
               exsr out;
            endif;

         endsr;



         begsr Continue;

            dou %eof;
               read SrcInR;    // DSPF38 source member

               if %eof;
                  RtnCod = Error;
                  exsr ExitPgm;   // continuation line missing
               endif;

               Continuation = %trim(%subst(in_srcdta : 45 : 36));

               // write out intervening source lines
               if %subst(in_srcdta : 7 : 1) = '*'  OR
                  Continuation = *blanks;
                  exsr Out;
               else;
                  Leave;  // we have isolated the continuation line
               endif;

            enddo;

         endsr;



         begsr Out;

            out_SrcSeq = in_SrcSeq;
            out_SrcDat = in_SrcDat;
            out_SrcDta = NewSource;
            write SrcOutR;  // DSPF source member

         endsr;



         begsr ExitPgm;

            *inLR = *on;
            return;

         endsr;

      /end-free
