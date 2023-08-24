      *******************************************************************
      * SAMPLE_SQL -  How to update a table via embedded SQL
      *=================================================================================
      * Date       Programmer   Project Scan Desc
      * ---------- ------------ ------- ---- ------------------------------------------
      * 2014-03-04 Keck                      created
      *******************************************************************
     h option(*nodebugio: *srcstmt) dftactgrp(*no) actgrp(*caller)
      *******************************************************************
      /free

         exec sql  set option commit = *none;

         exec sql  UPDATE LAWMODS9/DBAPCVI_Y
                   SET STATUS = 'U'
                   WHERE ROW_DATE = CURRENT_DATE - 1 DAYS
                   AND STATUS IN ('E', 'I');

         *inlr = *on;
         return;
      /end-free
