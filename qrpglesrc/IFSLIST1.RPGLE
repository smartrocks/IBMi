     H option(*nodebugio : *srcstmt) dftactgrp(*no) actgrp(*CALLER) indent('| ')
      *------------------------------------------------------------------------------------------
      * IFSlist - List contents of an IFS Directory to a file
      *
      * Purpose: This program is called by IFSLISTCL.  Given the path to an IFS folder, this
      *          program will write the folder's directory listing to file QTEMP/IFSLIST.
      *------------------------------------------------------------------------------------------
      * Program Change Log
      *------------------------------------------------------------------------------------------
      * Date       Pgmr      Proj  Task  Scan Description
      * 2005-07-11 Keck      11264 2.00       Created
      * 2008-09-29 Drew      Morph       dl01 expand folder size
      *------------------------------------------------------------------------------------------
     FIFSLIST   O    E             DISK    Prefix(O_)
      * IFS Directory List
      *------------------------------------------------------------------------------------------
      * External Prototypes and Declarations
     d/copy QRPGLESRC,stmIOH

dl01 d folder          s            256
     d handle          s                   like( streamDirHandleType )
     d path            s             50


     c     *entry        plist
     c                   parm                    folder

      /free

       // --------------------------------------------
       // The program starts by opening the directory
       // --------------------------------------------
       handle = openStreamDir( %trim( folder ) );


       // ------------------------------------------------------------------
       // Directory entries are read into the streamDirEntry data structure
       // (which is defined in STMIOH), and then displayed
       // ------------------------------------------------------------------
       streamDirEntryPtr = nextStreamDirEntry( handle );

       dow streamDirEntryPtr <> *null;

          path = %subst( streamDirEntry.path: 1: streamDirEntry.len );

          if getStreamInfo( %trim( folder ) + '/' +
                %subst( streamDirEntry.path: 1: streamDirEntry.len ):
                streamInfo ) <> streamError;

          o_Name = path;              // file or directory name or '.' or '..'
          o_Type = streaminfo.type;   // file type (*DIR, *STMF, etc)
          write IFSlistR;

          endif;


          streamDirEntryPtr = nextStreamDirEntry( handle );
       enddo;


       // ------------------------------------------------------------------
       // The directory entries are similar to those returned by PC commands.
       // The first entry contains a single period "."
       // The second entry two periods ".."
       // Subsequent entries the contents of the directory.
       // ------------------------------------------------------------------


       // ------------------------------------------------------------------
       // Close the Directory
       // ------------------------------------------------------------------
       closeStreamDir( handle );

       *inlr = *on;

      /end-free
