**FREE
Ctl-Opt NOMAIN PGMINFO(*PCML: *MODULE: *DCLCASE);

DCL-F STUDENTDB USAGE(*INPUT:*update:*OUTPUT:*DELETE) KEYED prefix(s_);
DCL-F STUDCLASS USAGE(*INPUT:*update:*OUTPUT:*DELETE) KEYED prefix(sc_);

Dcl-DS studentRec  qualified dim(10);  // options(*varsize not allowed???)
   studentID      Char(9);
   firstName      Char(50);
   lastName       Char(50);
   gender         Char(10);
   dcl-ds classRec dim(3);
      studentID   like(sc_studentID);
      classID     like(sc_classID);
      descrip     like(sc_descrip);
   End-DS;
end-ds;

///
// printf
// Print to standard out
// @param String value pointer
///
dcl-pr printf int(10) extproc('printf');
   format pointer value options(*string);
end-pr;

Dcl-PR getAll;
   students_LENGTH   Int(10);
   students          likeds(studentRec) dim(1000) options(*varsize);
   httpStatus        Int(10);
   httpHeaders       Char(100)  dim(10);
End-PR;

Dcl-PR getByID;
   studentID      Char(9)    const;
   student        likeds(studentRec);
   httpStatus     Int(10);
   httpHeaders    Char(100)  dim(10);
End-PR;

Dcl-PR create;
   student        likeds(studentRec);
   httpStatus     Int(10);
   httpHeaders    Char(100)  dim(10);
End-PR;

Dcl-PR createmulti;
   students       likeds(studentRec) dim(1000) options(*varsize) const;
   httpStatus     Int(10);
   httpHeaders    Char(100)  dim(10);
End-PR;

Dcl-PR update;
   student                   likeds(studentRec);
   httpStatus     Int(10);
End-PR;

Dcl-PR remove;
   studentID      Char(9)    const;
   httpStatus     Int(10);
end-pr;

Dcl-C H_SERVERERROR const(500);
Dcl-C H_OK       const(200);
Dcl-C H_NOTFOUND const(404);
Dcl-C H_CREATED  const(201);
Dcl-C ERR_DUPLICATE_WRITE const(01021);
Dcl-C H_CONFLICT const(409);
Dcl-C H_NOCONTENT const(204);

dcl-s i int(5); // data structure instace pointer for students
dcl-s j int(5); // data structure instace pointer for classes

// -----------------------------------------------------------------------
Dcl-Proc getAll EXPORT;
   Dcl-PI getAll;
      students_LENGTH  Int(10);
      students         likeds(studentRec) dim(1000) options(*varsize);
      httpStatus       Int(10);
      httpHeaders      Char(100)  dim(10);
   end-pi;

   clear httpHeaders;
   clear students;
   students_LENGTH = 0;

   // openStudentDB();

   setll *loval STUDENTDB;

   read(e) STUDENTR;
   if (%ERROR);
      httpStatus = H_SERVERERROR;
      return;
   endif;

   dow (NOT %eof);
      i += 1;
      students(i).studentID =  s_studentID;
      students(i).firstName =  s_firstName;
      students(i).lastName  =  s_lastName;
      students(i).gender    =  s_gender;

      setll s_studentID STUDCLASS;
      reade(e) s_studentID STUDCLASS;
      if (%ERROR);
         httpStatus = H_SERVERERROR;
         return;
      endif;

      j=0;
      dow not %eof;
         j += 1;
         students(i).classrec(j).studentID =  sc_studentID;
         students(i).classrec(j).classID   =  sc_classID;
         students(i).classrec(j).descrip   =  sc_descrip;

         read(e) STUDCLASSR;
         if (%ERROR);
            httpStatus = H_SERVERERROR;
            return;
         endif;
      enddo;

      read(e) STUDENTR;
      if (%ERROR);
         httpStatus = H_SERVERERROR;
         return;
      endif;
   enddo;

   httpStatus = H_OK;
   httpHeaders(1) = 'Cache-Control: no-cache, no-store';
   students_LENGTH = i;
   // closeStudentDB();

End-Proc;


// -----------------------------------------------------------------------
// -----------------------------------------------------------------------
Dcl-Proc getByID EXPORT;
   Dcl-PI getByID;
      studentID      Char(9)    const;
      student        likeds(studentRec);
      httpStatus     Int(10);
      httpHeaders    Char(100)  dim(10);
   End-PI;

   clear httpHeaders;
   clear student;

   // openStudentDB();

   chain(e) studentID STUDENTDB;
   if (%ERROR);
      httpStatus = H_SERVERERROR;
      return;
   elseif %FOUND;
      student.studentID = s_studentID;
      student.firstName = s_firstName;
      student.lastName  = s_lastName;
      student.gender    = s_gender;

      setll s_studentID STUDCLASS;
      reade(e) s_studentID STUDCLASS;
      if (%ERROR);
         httpStatus = H_SERVERERROR;
         return;
      endif;

      j=0;
      dow not %eof;
         j += 1;
         student.classrec(j).studentID =  sc_studentID;
         student.classrec(j).classID   =  sc_classID;
         student.classrec(j).descrip   =  sc_descrip;

         read(e) STUDCLASSR;
         if (%ERROR);
            httpStatus = H_SERVERERROR;
            return;
         endif;
      enddo;

      httpStatus = H_OK;
   else;
      httpStatus = H_NOTFOUND;
   endif;

   httpHeaders(1) = 'Cache-Control: no-cache, no-store';

   // closeStudentDB();

End-Proc;
// -----------------------------------------------------------------------



// -----------------------------------------------------------------------
// Dcl-Proc create EXPORT;
//    Dcl-PI create;
//       student        likeds(studentRec);
//       httpStatus     Int(10);
//       httpHeaders    Char(100)  dim(10);
//    End-PI;

//    // openStudentDB();   // why is this suggested by the compiler?

//    // studentRec  qualified template;
//    studentID = student.studentID;
//    firstName = student.firstName;
//    lastName  = student.lastName;
//    gender    = student.gender;

//    write(e) STUDENTR;
//    if NOT %ERROR;
//       httpStatus = H_CREATED;
//       httpHeaders(1) = 'LOCATION: ' +
//         'http:/' + '/server/web/service/students/' + studentID;
//    elseif %STATUS = ERR_DUPLICATE_WRITE;
//       httpStatus = H_CONFLICT;
//    else;
//       httpStatus = H_SERVERERROR;
//    endif;

//    // closeStudentDB();

// End-Proc;
// // -----------------------------------------------------------------------


// -----------------------------------------------------------------------
Dcl-Proc createmulti EXPORT;
   Dcl-PI createmulti;
      students       likeds(studentRec) dim(1000) options(*varsize) const;
      httpStatus     Int(10);
      httpHeaders    Char(100)  dim(10);
   End-PI;

   // openStudentDB();   // why is this suggested by the compiler?
   i=1;
   dow (i <= %elem(students)) and (students(i).studentID <> ' ');

      // studentRec  qualified data structure;
      s_studentID = students(i).studentID;
      s_firstName = students(i).firstName;
      s_lastName  = students(i).lastName;
      s_gender    = students(i).gender;

      write(e) STUDENTR;
      if NOT %ERROR;
         httpStatus = H_CREATED;
         httpHeaders(1) = 'LOCATION: ' +
            'http:/' + '/server/web/service/students/' + s_studentID;
      elseif %STATUS = ERR_DUPLICATE_WRITE;
         httpStatus = H_CONFLICT;
      else;
         httpStatus = H_SERVERERROR;
      endif;

      j=1;
      dow (j <= %elem(students(i).classrec)) and (students(i).classrec(j).studentID <> *blank);
         sc_studentID = students(i).classrec(j).studentID;
         sc_classID   = students(i).classrec(j).classID;
         sc_descrip   = students(i).classrec(j).descrip;

         write(e) STUDCLASSR;
         if NOT %ERROR;
            httpStatus = H_CREATED;
            httpHeaders(1) = 'LOCATION: ' +
            'http:/' + '/server/web/service/students/' + sc_studentID + '-' + sc_classID;
         elseif %STATUS = ERR_DUPLICATE_WRITE;
            httpStatus = H_CONFLICT;
         else;
            httpStatus = H_SERVERERROR;
         endif;
         j+=1;
      enddo;

      i+=1;
   enddo;
   // closeStudentDB();

End-Proc;

// -----------------------------------------------------------------------
Dcl-Proc update EXPORT;
   // there are design consideration regarding updates to classes

   Dcl-PI update;
      student        likeds(studentRec);
      httpStatus     Int(10);
   End-PI;

   // openStudentDB();

   chain(e) student.studentID STUDENTDB;
   if (%ERROR);
      httpStatus = H_SERVERERROR;
      return;
   elseif %FOUND;
      s_studentID = student.studentID;
      s_firstName = student.firstName;
      s_lastName  = student.lastName;
      s_gender    = student.gender;

      update(e) STUDENTR;
      if NOT %ERROR;
         httpStatus = H_NOCONTENT;
      else;
         httpStatus = H_NOTFOUND;
      endif;
   else;
      httpStatus = H_NOTFOUND;
   endif;

   // closeStudentDB();

End-Proc;
// -----------------------------------------------------------------------



// -----------------------------------------------------------------------
Dcl-Proc remove EXPORT;
   // should also remove class records
   Dcl-PI remove;
      studentID      Char(9)    Const;
      httpStatus     Int(10);
   End-PI;

   // openStudentDB();

   chain(e) studentID STUDENTDB;
   if (%ERROR);
      httpStatus = H_SERVERERROR;
      return;
   elseif %FOUND;
      delete(e) STUDENTR;
      if NOT %ERROR;
         httpStatus = H_NOCONTENT;
      elseif NOT %FOUND;
         httpStatus = H_NOTFOUND;
      else;
         httpStatus = H_SERVERERROR;
      endif;
   else;
      httpStatus = H_NOTFOUND;
   endif;

   // closeStudentDB();

End-Proc;
// -----------------------------------------------------------------------
