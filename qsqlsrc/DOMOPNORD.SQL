--DOMOPNORD - Create work file of Domestic Open Orders

--Executed via JSE DOMOPNORD, CLLE DOMOPNORD

--Date        Programmer    Scan   Description
------------  ------------  ----   -------------------------------------------
--2023-02-02  Keck                 Created


Create or replace table QTEMP.DOMOPNORD as
(
with x as
(
select 'DOMOPNORD' as AS400_PROGRAM,
       oh.ohdiv as Division, oh.ohcust as Customer, c.cmname as Customer_Name,
       case when OHEREF = ' ' then 'N' else 'Y' end as EDI,
       oh.ohnum as Order_No, oh.ohseq as BO_SEQ, oh.ohlab as Label,
       oh.ohgtot as Amount,
       QGPL.NUM2DATE((20000000 +
           (oh.ohenty-72) * 10000 + ohentm * 100 + ohentd),'*ISO') as Entered,
       oh.ohpst as Status, pst.wodesc as Status_Desc,
       QGPL.NUM2DATE((20000000 +
           (oh.ohcsyr-72) * 10000 + ohcsmo * 100 + ohcsda),'*ISO')
           as Cust_Requested_Ship,
       QGPL.NUM2DATE((20000000 +
           (oh.ohcnyr-72) * 10000 + ohcnmo * 100 + ohcnda),'*ISO')
           as Cust_Requested_Cancel,
        QGPL.FMTDATSTR(oh.ohaon) as Arrive_On_Date,
        QGPL.FMTDATSTR(oh.ohana) as Arrive_not_After,
        QGPL.FMTDATSTR(oh.ohanb) as Arrive_not_Before,
        QGPL.FMTDATSTR(oh.ohson) as Ship_On,
        QGPL.FMTDATSTR(oh.ohsnb) as Ship_Not_Before,
        QGPL.FMTDATSTR(oh.ohsna) as Ship_Not_After,
        QGPL.FMTDATSTR(oh.ohcns) as Cancel_If_Not_Shipped,
        QGPL.FMTDATSTR(oh.ohcna) as Cancel_If_Not_Arrived

from nbjdta.cstmst c inner join nbjdta.ordhdr oh
on  oh.ohdiv  = c.cmdiv
and oh.ohcust = c.cmnum
                            left join nbjdta.wo_ohpstf pst
on  pst.wopst = oh.ohpst
where 1=1
and c.cmdiv in (1,9)
and   oh.ohpst not in (41,70,71) -- dk01 removed -99 from filter list
)
select * from x
order by Entered desc, Division, Customer, Order_No, BO_Seq
)
with data
on replace delete rows
;

