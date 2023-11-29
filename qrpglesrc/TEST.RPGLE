dcl-ds CustomerData;
    CustomerNumber packed(5:0);
    CustomerName   char(50);
end-ds;

dcl-ds SubfileRecord qualified dim(9999);
    CustomerNumber packed(5:0);
    CustomerName   char(50);
end-ds;

dcl-ds SubfileControl qualified;
    SubfileRecord SubfileData(9999);
    SubfileRecord SubfileDataFormat;
end-ds;

ctl-opt dftactgrp(*no) actgrp('MYACTGRP');

dcl-f CustomerMaster keyed usage(*input) extfile('CUSTOMER');

dcl-s FilterName char(50);
dcl-s SelectedCustomer packed(5:0);

// Subfile Control Variables
dcl-s SubfileSize int(10) inz(0);
dcl-s SubfilePage int(10) inz(1);
dcl-s SubfileMaxSize int(10) inz(9999);

// Subfile Record Counter
dcl-s RecordCounter int(10) inz(0);

// Subfile Selection Indicator
dcl-s SelectedRow int(10) inz(0);

// Subfile Load Procedure
dcl-proc LoadSubfile;
    dcl-pi *n;
        FilterName char(50) const;
    end-pi;

    clear SubfileRecord;

    setll (CustomerNumber: FilterName) CustomerMaster;

    dow not %eof(CustomerMaster) and RecordCounter < SubfileMaxSize;
        if %subst(CustomerName: 1: %len(FilterName)) = FilterName;
            RecordCounter += 1;
            SubfileRecord(RecordCounter).CustomerNumber = CustomerNumber;
            SubfileRecord(RecordCounter).CustomerName = CustomerName;
        endif;

        read next CustomerMaster;
    enddo;

    SubfileSize = RecordCounter;
    SubfilePage = 1;
    SelectedRow = 0;
    *inlr = *on;
end-proc;

// Subfile Display Procedure
dcl-proc DisplaySubfile;
    dcl-pi *n;
        SubfilePage int(10) const;
    end-pi;

    clear SubfileControl;

    SubfileControl.SubfileDataFormat = SubfileRecord(1);

    exfmt SubfileControl.SubfileDataFormat;

    dow SubfilePage = SubfilePage and not *in03;
        if SubfilePage = 1;
            exsr LoadSubfile(FilterName);
        endif;

        exsr DisplaySubfilePage;

        exsr ProcessSubfileInput;
    enddo;

    *inlr = *on;
end-proc;

// Subfile Page Display Procedure
dcl-proc DisplaySubfilePage;
    dcl-pi *n;
    end-pi;

    clear SubfileControl.SubfileData;

    for i = 1 to SubfileSize;
        SubfileControl.SubfileData(i) = SubfileRecord(i);
    endfor;

    write SubfileControl.SubfileData;
    exfmt SubfileControl.SubfileDataFormat;
end-proc;

// Subfile Input Handling Procedure
dcl-proc ProcessSubfileInput;
    dcl-pi *n;
    end-pi;

    dow *in03;
        exfmt SubfileControl.SubfileDataFormat;

        if *in03;
            if SelectedRow > 0;
                SelectedCustomer = SubfileRecord(SelectedRow).CustomerNumber;
                // Return the selected customer number to the calling program
                // You can use RPGLE's RETURN operation to pass the value back
            endif;
        endif;
    enddo;
end-proc;

// Main Program
begsr Main;
    dsply 'Customer Inquiry Application';

    dow *in03;
        dsply 'Enter partial customer name (or blank to exit): ';
        read CustomerName;

        if %trim(CustomerName) <> '';
            exsr DisplaySubfile(SubfilePage);
        endif;
    enddo;

    *inlr = *on;
endsr;

