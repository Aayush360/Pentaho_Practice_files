
DELIMITER //

CREATE PROCEDURE validate_qa()
BEGIN
insert into QA.fc_balance(account_number, tran_date,balance,balance_qa,balance_before_1_day,balance_before_1_day_qa,balance_before_2_day,balance_before_2_day_qa,balance_before_3_day,balance_before_3_day_qa,balance_status, balance_before_1_day_status,balance_before_2_day_status,balance_before_3_day_status)
select combined.account_number,combined.tran_date, combined.balance, combined.balance_q,combined.balance_before_1_day,combined.balance_before_1_day_q,combined.balance_before_2_day,combined.balance_before_2_day_q,combined.balance_before_3_day,combined.balance_before_3_day_q,
(case when 
ifnull(combined.balance,0)=ifnull(combined.balance_q,0) then 'pass' else 'fail' end)as balance_status,
(case when
ifnull(combined.balance_before_1_day,0)=ifnull(combined.balance_before_1_day_q,0) then 'pass' else 'fail' end)as balance_before_1_day_status,
(case when ifnull(combined.balance_before_2_day,0)=ifnull(combined.balance_before_2_day_q,0) then 'pass' else 'fail' end)as balance_before_2_day_status,
(case when ifnull(combined.balance_before_3_day,0)=ifnull(combined.balance_before_3_day_q,0) then 'pass' else 'fail' end)as balance_before_3_day_status
from
(select * from fc_facts.fc_balance as table1
 inner join 
(select tran_date as tran_date_q, account_number as account_number_q, lcy_amount as balance_q ,lag(lcy_amount,1) over(partition by account_number order by tran_date) as balance_before_1_day_q, lag(lcy_amount,2) over(partition by account_number order by tran_date) as balance_before_2_day_q,lag(lcy_amount,3) over(partition by account_number order by tran_date) as balance_before_3_day_q from client_rw.fc_balance_summary) as table2
on (table1.tran_date=table2.tran_date_q and table1.account_number=table2.account_number_q) 
 )as combined;
END //

DELIMITER ;

call 	qa.validate_qa;

