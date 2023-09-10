     h nomain

      /copy protype,xmlpr

      //--------------------------------------------------------------------------------------------
      // Procedure: CleanUpXML
      // This procedure replaces the special XML characters with the XML equivalent
      //--------------------------------------------------------------------------------------------
       //          & = &amp;
       //          ' = &apos;
       //          " = &quot;
       //          < = &lt;
       //          > = &gt;
       //-----------------------------------------------------------------------
     P CleanUpXML      b                   export

     D CleanUpXML      pi          1024    varying
     D  InString                   1024    varying value

     D ReturnString    s           1024
     D Pos             s              5i 0

     D AMPERSAND       c                   '&'
     D XMLAMPERSAND    c                   '&amp;'
     D APOSTROPHE      c                   ''''
     D XMLAPOSTROPHE   c                   '&apos;'
     D QUOTES          c                   '"'
     D XMLQUOTES       c                   '&quot;'
     D LESSTHAN        c                   '<'
     D XMLLESSTHAN     c                   '&lt;'
     D GREATERTHAN     c                   '>'
     D XMLGREATERTHAN  c                   '&gt;'

      /free

       ReturnString = InString;

       clear Pos;
       dou Pos = 0;
         Pos = %scan(AMPERSAND: ReturnString: Pos+1);
         if Pos > 0;
           ReturnString = %replace(XMLAMPERSAND: ReturnString:
                           Pos: %len(AMPERSAND));
         endif;
       enddo;

       clear Pos;
       dou Pos = 0;
         Pos = %scan(APOSTROPHE: ReturnString: Pos+1);
         if Pos > 0;
           ReturnString = %replace(XMLAPOSTROPHE: ReturnString:
                           Pos: %len(APOSTROPHE));
         endif;
       enddo;

       clear Pos;
       dou Pos = 0;
         Pos = %scan(QUOTES: ReturnString: Pos+1);
         if Pos > 0;
           ReturnString = %replace(XMLQUOTES: ReturnString:
                           Pos: %len(QUOTES));
         endif;
       enddo;

       clear Pos;
       dou Pos = 0;
         Pos = %scan(LESSTHAN: ReturnString: Pos+1);
         if Pos > 0;
           ReturnString = %replace(XMLLESSTHAN: ReturnString:
                           Pos: %len(LESSTHAN));
         endif;
       enddo;

       clear Pos;
       dou Pos = 0;
         Pos = %scan(GREATERTHAN: ReturnString: Pos+1);
         if Pos > 0;
           ReturnString = %replace(XMLGREATERTHAN: ReturnString:
                           Pos: %len(GREATERTHAN));
         endif;
       enddo;


       return ReturnString;

      /end-free

     P CleanUpXML      e
