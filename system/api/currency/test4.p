/*
for each currency:
	update currency.
end.	
*/

create currency_rates.
currency_rates.id = NEXT-VALUE(currency_rates_id).
UPDATE currency_rates.