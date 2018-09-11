define input parameter balance_date   as date.
define input parameter create_user   AS char.
define input parameter cif   AS CHARACTER.
define input parameter document_id  as int64.
define input parameter deal_number AS CHARACTER.
define input parameter branch AS CHARACTER.
define input parameter trx_status  AS INTEGER.
define input parameter authorize_user   AS char.
define input parameter authorize_date   as date.
define output parameter trx_number AS INT64.

DEFINE VARIABLE id AS INT64.
{global.i}.
trx_number = next-value(jhnum).
FIND LAST transaction_header NO-LOCK USE-INDEX id NO-ERROR.
IF AVAILABLE transaction_header THEN id = transaction_header.id + 1. ELSE id = 1.

do transaction :
    create transaction_header.
    assign transaction_header.id             = id
           transaction_header.header_id      = trx_number
           transaction_header.balance_date   = balance_date
           transaction_header.create_user    = create_user
           transaction_header.cif            = cif
           transaction_header.document_id    = document_id
           transaction_header.deal_number    = deal_number
           transaction_header.branch         = branch
           transaction_header.head_status    = trx_status
           transaction_header.authorize_user = authorize_user
           transaction_header.authorize_date = authorize_date.
           
end.
