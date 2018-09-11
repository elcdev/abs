for each gl_balance where total_debet ne 0.0 or total_credit ne 0.0 :
    total_debet = 0.
    total_credit = 0.0.
    balance = 0.0.
    display gl_balance.
end.
for each account_balance where total_debet ne 0.0 or total_credit ne 0.0 :
    total_debet = 0.    
    total_credit = 0.0.
    balance = 0.0.
    available_balance = 0.0.
        display account_balance.
end.