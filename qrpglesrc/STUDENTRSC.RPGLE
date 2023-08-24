     H NOMAIN PGMINFO(*PCML:*MODULE:*DCLCASE)

       DCL-F STUDENTDB USAGE(*INPUT:*UPDATE:*OUTPUT:*DELETE) KEYED;

     D studentRec      DS                  qualified template
     D  studentID                     9A
     D  firstName                    50A
     D  lastName                     50A
     D  gender                       10A

     D getAll          PR
     D  students_...
     D  LENGTH                       10i 0
     D  students                           likeds(studentRec) dim(1000)
     D                                     options(*varsize)
     D  httpStatus                   10i 0
     D  httpHeaders                 100a   dim(10)

     D getByID         PR
     D  studentID                     9a   const
     D  student                            likeds(studentRec)
     D  httpStatus                   10i 0
     D  httpHeaders                 100a   dim(10)

     D create          PR
     D  student                            likeds(studentRec)
     D  httpStatus                   10i 0
     D  httpHeaders                 100a   dim(10)

     D update          PR
     D  student                            likeds(studentRec)
     D  httpStatus                   10i 0

     D remove          PR
     D  studentID                     9a   const
     D  httpStatus                   10i 0

     D H_SERVERERROR   c                    const(500)
     D H_OK            c                    const(200)
     D H_NOTFOUND      c                    const(404)
     D H_CREATED       c                    const(201)
     D ERR_DUPLICATE_WRITE...
     D                 c                    const(01021)
     D H_CONFLICT      c                    const(409)
     D H_NOCONTENT     c                    const(204)




       //-----------------------------------------------------------------------
     P getAll          B                   EXPORT
     D getAll          PI
     D  students_...
     D  LENGTH                       10i 0
     D  students                           likeds(studentRec) dim(1000)
     D                                     options(*varsize)
     D  httpStatus                   10i 0
     D  httpHeaders                 100a   dim(10)

       clear httpHeaders;
       clear students;
       students_LENGTH = 0;

       //openStudentDB();

       setll *loval STUDENTDB;

       read(e) studentR;
       if (%ERROR);
        httpStatus = H_SERVERERROR;
        return;
       endif;

       dow (NOT %eof);
        students_LENGTH = students_LENGTH+1;
        students(students_LENGTH).studentID =  studentID;
        students(students_LENGTH).firstName =  firstName;
        students(students_LENGTH).lastName  =  lastName;
        students(students_LENGTH).gender    =  gender;

        read(e) studentR;
        if (%ERROR);
          httpStatus = H_SERVERERROR;
          return;
        endif;
       enddo;

       httpStatus = H_OK;
       httpHeaders(1) = 'CacheControl: nocache, nostore';

       //closeStudentDB();

     P getAll          E
         //-----------------------------------------------------------------------



         //-----------------------------------------------------------------------
     P getByID         B                   EXPORT
     D getByID         PI
     D  studentID                     9a   const
     D  student                            likeds(studentRec)
     D  httpStatus                   10i 0
     D  httpHeaders                 100a   dim(10)

       clear httpHeaders;
       clear student;

       //openStudentDB();

       chain(e) studentID STUDENTDB;
       if (%ERROR);
        httpStatus = H_SERVERERROR;
        return;
       elseif %FOUND;
        student.studentID = studentID;
        student.firstName = firstName;
        student.lastName  = lastName;
        student.gender    = gender;

        httpStatus = H_OK;
       else;
        httpStatus = H_NOTFOUND;
       endif;

       httpHeaders(1) = 'CacheControl: nocache, nostore';

       //closeStudentDB();

     P getByID         E
       //-----------------------------------------------------------------------



       //-----------------------------------------------------------------------
     P create          B                   EXPORT
     D create          PI
     D  student                            likeds(studentRec)
     D  httpStatus                   10i 0
     D  httpHeaders                 100a   dim(10)

       //openStudentDB();

       studentID = student.studentID;
       firstName = student.firstName;
       lastName  = student.lastName;
       gender    = student.gender;

       write(e) studentR;
       if NOT %ERROR;
        httpStatus = H_CREATED;
        httpHeaders(1) = 'LOCATION: ' +
        'http:/' + '/server/web/service/students/' + studentID;
       elseif %STATUS = ERR_DUPLICATE_WRITE;
        httpStatus = H_CONFLICT;
       else;
        httpStatus = H_SERVERERROR;
       endif;

       //closeStudentDB();

     P create          E
       //-----------------------------------------------------------------------



       //-----------------------------------------------------------------------
     P update          B                   EXPORT
     D update          PI
     D  student                            likeds(studentRec)
     D  httpStatus                   10i 0

       //openStudentDB();

       chain(e) student.studentID STUDENTDB;
       if (%ERROR);
        httpStatus = H_SERVERERROR;
        return;
       elseif %FOUND;
        studentID = student.studentID;
        firstName = student.firstName;
        lastName  = student.lastName;
        gender    = student.gender;

        update(e) studentR;
        if NOT %ERROR;
          httpStatus = H_NOCONTENT;
        else;
          httpStatus = H_NOTFOUND;
        endif;
       else;
        httpStatus = H_NOTFOUND;
       endif;

       //closeStudentDB();

     P update          E
       //-----------------------------------------------------------------------



       //-----------------------------------------------------------------------
     P remove          B                   EXPORT
     D remove          PI
     D  studentID                     9a   Const
     D  httpStatus                   10i 0

       //openStudentDB();

       chain(e) studentID STUDENTDB;
       if (%ERROR);
        httpStatus = H_SERVERERROR;
        return;
       elseif %FOUND;
        delete(e) studentr;
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

       //closeStudentDB();

     P remove          E
       //-----------------------------------------------------------------------

