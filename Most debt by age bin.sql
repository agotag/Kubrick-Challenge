use bank
go

--EXEC sp_configure 'show advanced options', 1;  
--GO  
--RECONFIGURE ;  
--GO  
--EXEC sp_configure 'two digit year cutoff', 2000 ;  
--GO  
--RECONFIGURE;  
--GO  

;with cte_loan
as
(
select 
	 cast(account_id as int) 'account_id'
	,cast([date] as date) 'date'
	,cast(amount as int) 'amount'
from dbo.loan 
) 

,cte_client
as
(
select
	 cast(client_id as int) 'client_id'
	,cast(birth_number as int) birth_number
	,cast(
		cast(
			case
				when substring(birth_number,3,1) not in ('0','1')
				then (cast(birth_number as int)-5000)
				else cast(birth_number as int) 
			end 
		as varchar(50))
	as date) as dob
	,case
		when substring(birth_number,3,1) not in ('0','1')
		then 'FEMALE'
		else 'MALE'
	end as gender
from dbo.client
)

,cte_account
as
(
select
	cast(account_id as int) account_id
from dbo.account  
)

,cte_disp
as
(
select
	cast(client_id as int) client_id
	,account_id
from dbo.disp  
where [type] = 'OWNER'
)


select
	 a.account_id as account_id
	,c.client_id as client_id
	,l.[date] as loan_date
	,l.amount as loan_amount
	,c.dob
	,datediff(yy, dob, [date]) age_at_loan_start
	,floor(datediff(yy, dob, [date])/10)*10 as age_bucket
	,avg(l.amount) over (partition by floor((datediff(yy, dob, [date])/10)*10)) avg_debt_age_group

from cte_loan as l
join cte_account as a
	on l.account_id = a.account_id
join cte_disp as d
	on a.account_id = d.account_id
join cte_client as c
	on d.client_id = c.client_id 

order by avg_debt_age_group desc

/* 
question: At what age do on average (provide all necessary statistics to back up your suggestion) 
our clients take on the “most” debt (define “most”) to the bank.
answer: 10-19 age bucket */



--;with cte_trans
--as
--(
--select
--	cast(account_id as int) account_id
--	--,k_symbol
--	,cast([date] as date) date_of_loan_payment
--	,cast(amount as decimal) amount_paid 
--from dbo.trans
--where k_symbol = 'UVER'-- only showing transactions that are loan payments
--) 