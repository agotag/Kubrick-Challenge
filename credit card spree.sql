/*What is the longest continuous credit card transaction spending spree per customer? 
What age bin are they in? Are they an outlier according to stdev for their age bin?*/
use bank
go
;with cte_trans
as
(
select
	 cast(trans_id as int) trans_id
	,cast([date] as date) transaction_date
	,account_id 
	--,[type]
from dbo.trans
where [type] = 'VYDAJ'
)
,cte_disp
as
(
select
	 cast(client_id as int) client_id
	,cast(account_id as int) account_id
from dbo.disp
)
,cte_client
as
(
select 
	cast(client_id as int) client_id
from dbo.client
)


select
	 t.trans_id
	,t.transaction_date
	,cast(lead(transaction_date) over (partition by trans_id order by transaction_date asc) as date) next_transaction_date
	,datediff(dd, transaction_date, lead(transaction_date) over (partition by trans_id order by transaction_date asc)) days_between_transactions
from cte_trans as t
join cte_disp as d
	on t.account_id = d.account_id
join cte_client as c
	on d.client_id = c.client_id 
order by days_between_transactions desc