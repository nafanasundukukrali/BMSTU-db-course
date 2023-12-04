drop table Employee;

create table Employee
(
	id integer,
	FIO VARCHAR(255),
	status text,
	date_of_status date
);

alter table Employee
add check (status = 'Работа offline' or status = 'Удаленная работа' 
	or status = 'Больничный' or status = 'Отпуск');

insert into Employee
values (1, 'Иванов Иван Иванович', 'Работа offline', date('12-12-2022'));
	
insert into Employee
values (1, 'Иванов Иван Иванович', 'Работа offline', date('12-13-2022'));

insert into Employee
values (1, 'Иванов Иван Иванович', 'Больничный', date('12-14-2022'));

insert into Employee
values (1, 'Иванов Иван Иванович', 'Больничный', date('12-15-2022'));

insert into Employee
values (1, 'Иванов Иван Иванович', 'Удаленная работа', date('12-16-2022'));

insert into Employee
values (2, 'Петров Петр Петрович', 'Работа offline', date('12-12-2022'));

insert into Employee
values (2, 'Петров Петр Петрович', 'Работа offline', date('12-13-2022'));

insert into Employee
values (2, 'Петров Петр Петрович', 'Удаленная работа', date('12-14-2022'));

insert into Employee
values (2, 'Петров Петр Петрович', 'Удаленная работа', date('12-15-2022'));

insert into Employee
values (2, 'Петров Петр Петрович', 'Удаленная работа', date('12-16-2022'));

insert into Employee
values (2, 'Петров Петр Петрович', 'Удаленная работа', date('12-17-2022'));

insert into Employee
values (2, 'Петров Петр Петрович', 'Работа offline', date('12-18-2022'));

select * from Employee;


select *,
lag(status) over (partition by id order by date_of_status) as pre_status,
lead(status) over (partition by id order by date_of_status) as post_status
from employee;

with tb as (
		select *,
		lag(status) over (partition by id order by date_of_status) as pre_status,
		lead(status) over (partition by id order by date_of_status) as post_status
		from employee
), t1 as (
	select * from tb where status != pre_status or pre_status is null
), t2 as (
	select * from tb where status != post_status or (post_status is null and pre_status != status)
), t3 as (
	select t1.id, t1.fio,t1.date_of_status as date_from , t2.date_of_status as date_to, t1.status
	from t1 join t2
	on t1.id = t2.id and t1.status = t2.status and t1.date_of_status <= t2.date_of_status
), t4 as (
	select *, row_number() over (partition by id, date_from) as d
	from t3
)

select id, fio, date_from, date_to, status
from t4 
where d = 1;
