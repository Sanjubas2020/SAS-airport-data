options validvarname=v7;

/get the names as SAS wants/

libname tsa "C:\Users\Owner\Desktop\sas\SAScerti\SASbaseguide\Part_1_Airport";

proc import datafile="C:\Users\Owner\Desktop\sas\SAScerti\SASbaseguide\Part_1_Airport\TSAClaims2002_2017.csv" dbms=csv
out=tsa.Claims_cleaned1 replace;
guessingrows=max;
run;

/always check the few rows to make sure about variables/

proc contents data=tsa.Claims_cleaned1 (obs=20);
run;

/lets remove the duplicates/
proc sort data=tsa.Claims_cleaned1
out= tsa.Claims_cleaned1 nodupkey;
by all;
run;

/* lets sort the value by ascending date*/

proc sort data=tsa.Claims_cleaned1;
by incident_date;

    run;
data tsa.claim_cleaned2;
set tsa.claim_cleaned1;
if Claim_Type = " " then Claim_Type="unknown";
if Claim_Site = " " then Claim_Type="unknown";
if Disposition = " " then Claim_Type="unknown";
StateName =Propcase(statename);
State=Upcase (State);
format date_received year4.;
format Incident_Date year4.;
run;

 data tsa.claim_cleaned3;
set tsa.claim_cleaned2 ;
date_issues="Needs review";
if (incident_date = . or
   date_received =. or
   year (incident_date) < 2002 or 
   year (date_received_) < 2002 or
   year (incident_date) > 2007 or 
   year (date_received_) > 2007) then date_issues="Needs review";
run;

Data tsa.claim_cleaned3;
set tsa.claim_cleaned2 ;
format Incident_Date Date_Received date9. Close_Amount Dollar20.2; 
label Airport_Code="Airport Code" Airport_Name="Airport Name" Claim_Number="Claim Number" Claim_Site="Claim Site" Claim_Type="Claim Type" Close_Amount="Close Amount" date_issues="Date Issues" Date_Received="Date Received" Incident_Date="Incident Date" Item_Category="Item Category";
drop County City;
run;


title "Overall Date Issues in the Data"; 
proc freq data=tsa.claim_cleaned3;
table date_issues/ nocum nopercent; 
run;
title;


title " total number of claims per years";

/*i stay in NC and therefore want to find for the state*/
%let State= "NC"
title "claim type and dispositon for NC";
proc means data=tsa.claim_cleaned3;
var Close_Amount Date_Received Incident_Date;
where state ="&location";
run;

title;
 

ods pdf file="C:\Users\Owner\Desktop\sas\SAScerti\SASbaseguide\Part_1_Airport\ClaimsReports.pdf" style=Meadow;
ods proclabel "NC claims";