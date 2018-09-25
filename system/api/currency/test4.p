USING system.api.currency.*.
USING system.api.core.*.
USING OpenEdge.Web.*.
USING Progress.Json.ObjectModel.*.
USING org.apache.http.client.*.

DEFINE VARIABLE client AS HttpClient.

/*
for each currency:
	update currency.
end.	
*/
/*
create currency_rates.
currency_rates.id = NEXT-VALUE(currency_rates_id).
UPDATE currency_rates.
*/

DEFINE VARIABLE hDoc    AS HANDLE NO-UNDO.
DEFINE VARIABLE hRoot   AS HANDLE NO-UNDO.
DEFINE VARIABLE hNode   AS HANDLE NO-UNDO.
DEFINE VARIABLE hRow    AS HANDLE NO-UNDO.
/*
CREATE X-DOCUMENT hDoc.
 
hDoc:LOAD("file", "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml", TRUE).
*/
/*

<gesmes:Envelope xmlns:gesmes="http://www.gesmes.org/xml/2002-08-01" xmlns="http://www.ecb.int/vocabulary/2002-08-01/eurofxref">
<gesmes:subject>Reference rates</gesmes:subject>
<gesmes:Sender>
<gesmes:name>European Central Bank</gesmes:name>
</gesmes:Sender>
<Cube>
<Cube time="2018-09-20">
<Cube currency="USD" rate="1.1769"/>
<Cube currency="JPY" rate="131.98"/>
<Cube currency="BGN" rate="1.9558"/>
<Cube currency="CZK" rate="25.560"/>
<Cube currency="DKK" rate="7.4592"/>
<Cube currency="GBP" rate="0.88590"/>
<Cube currency="HUF" rate="323.75"/>
<Cube currency="PLN" rate="4.2925"/>
<Cube currency="RON" rate="4.6545"/>
<Cube currency="SEK" rate="10.3350"/>
<Cube currency="CHF" rate="1.1312"/>
<Cube currency="ISK" rate="129.60"/>
<Cube currency="NOK" rate="9.5885"/>
<Cube currency="HRK" rate="7.4265"/>
<Cube currency="RUB" rate="78.0670"/>
<Cube currency="TRY" rate="7.4320"/>
<Cube currency="AUD" rate="1.6158"/>
<Cube currency="BRL" rate="4.8390"/>
<Cube currency="CAD" rate="1.5174"/>
<Cube currency="CNY" rate="8.0559"/>
<Cube currency="HKD" rate="9.2313"/>
<Cube currency="IDR" rate="17471.00"/>
<Cube currency="ILS" rate="4.2052"/>
<Cube currency="INR" rate="84.7510"/>
<Cube currency="KRW" rate="1316.62"/>
<Cube currency="MXN" rate="22.0233"/>
<Cube currency="MYR" rate="4.8694"/>
<Cube currency="NZD" rate="1.7643"/>
<Cube currency="PHP" rate="63.436"/>
<Cube currency="SGD" rate="1.6064"/>
<Cube currency="THB" rate="38.055"/>
<Cube currency="ZAR" rate="17.0297"/>
</Cube>
</Cube>
</gesmes:Envelope>
*/

/*
DEFINE VARIABLE I AS INTEGER.
CREATE X-NODEREF hRoot.

hDoc:GET-DOCUMENT-ELEMENT( hRoot ).

REPEAT i = 1 TO hRoot:NUM-CHILDREN:
    MESSAGE hRoot:GET-CHILD(hNode, i).
END.
*/
DEFINE VARIABLE oJson AS JsonObject NO-UNDO.

oJson = NEW JsonObject().
/*
def var req as OpenEdge.Web.IWebRequest no-undo.
req = new WebRequest().
MESSAGE req:URI:ToString(). // http://localhost:8810/api/web/talks/abl-042
*/
/* req:URI:GetQueryValue('id'). // "" */

/*
req:PathParameterNames // "tlk,..."
req:UriTemplate // "/talks/{tlk}"
req:PathInfo // "/talks/abl-042"
req:TransportPath // "/web"
req:GetPathParameter('tlk') // "abl-042"
*/



DEFINE VARIABLE vcWebResp    AS CHARACTER        NO-UNDO.
DEFINE VARIABLE lSucess      AS LOGICAL          NO-UNDO.
DEFINE VARIABLE mResponse    AS MEMPTR           NO-UNDO.
DEFINE VARIABLE mRequest       AS MEMPTR.
DEFINE VARIABLE postUrl AS CHAR.
DEFINE VARIABLE vcRequest as char format "x(100)" no-undo.
DEFINE VARIABLE postData  as char format "x(100)" no-undo.
DEFINE VARIABLE vhSocket   AS HANDLE                                NO-UNDO.
CREATE SOCKET vhSocket.

vhSocket:CONNECT("-H www.ecb.europa.eu -S 443 -ssl -nohostverify") NO-ERROR.
IF vhSocket:CONNECTED() = FALSE THEN
do:
    message "Error".
    MESSAGE ERROR-STATUS:GET-MESSAGE(1) VIEW-AS ALERT-BOX.
end.
else
    message "Connected".

pause.
hide message no-pause.
message "GET".
postUrl = "/stats/eurofxref/eurofxref-daily.xml".
postData = "".

 vcRequest = 'GET ' +
             postUrl +
             postData +
             " HTTP/1.0 ~r~n" +
             "Host: www.ecb.europa.eu" +
             "~r~nUser-Agent: " +
             "~r~nConnection: close~r~n~r~n"
             .

SET-SIZE(mRequest)            = 0.
SET-SIZE(mRequest)            = LENGTH(vcRequest) + 1.
SET-BYTE-ORDER(mRequest)      = BIG-ENDIAN.
PUT-STRING(mRequest,1)        = vcRequest .

vhSocket:WRITE(mRequest, 1, LENGTH(vcRequest)).
hide message no-pause.
message "WRITE message complete".

PAUSE 5. /* 5 seconds */

DO WHILE vhSocket:GET-BYTES-AVAILABLE() > 0:
    SET-SIZE(mResponse) = vhSocket:GET-BYTES-AVAILABLE() + 1.
    SET-BYTE-ORDER(mResponse) = BIG-ENDIAN.
    vhSocket:READ(mResponse,1,1,vhSocket:GET-BYTES-AVAILABLE()).
    vcWebResp = vcWebResp + GET-STRING(mResponse,1).
END.

hide message no-pause.
message "READ Response complete".
pause.

hide message no-pause.
message "Response: " + vcWebResp
    VIEW-AS ALERT-BOX.
pause.

vhSocket:DISCONNECT().
DELETE OBJECT vhSocket.
message "END".
pause.