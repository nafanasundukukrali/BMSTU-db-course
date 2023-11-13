--- Скалярная функция, возвращающая год начала выпуска модели (надо было для ограничений)
create or replace function car_items.get_model_year(_model varchar(255)) 
returns integer 
as 'select StartYear from car_items.Model where ModelID = _model'
language sql;

select vin
from car_items.car
where car_items.get_model_year(model) > 2000;

--- Табличная функция, Возвращает таблицу с атрибутами машинка - страховка - тип страховки - количество вписанных лиц

create or replace function car_items.get_car_insurance_info()
returns table (vin varchar(255), insuranceid varchar(255), insurancetype  varchar(255), dlid varchar(255))
as $$
select vin, insuranceid, insurancetype, count(dlid)
	from car_items.car join car_items.insurance on vin = vincar 
	join car_items.insured on idinsurance = insuranceid 
	join car_items.dl on dlid = iddriver
	group by vin, insuranceid
$$
language sql;

select * from car_items.get_car_insurance_info();


--- Многооператорная табличная функция, возвращает водителей и машинки, причём госомера содержат букву А, а водитли старше своей модели машинки

create or replace function car_items.get_drivers_older_model()
returns table (dlid varchar(255), dlyear integer, vin varchar(255), model varchar(255), modelyear integer)
as $$
begin
	create temp table if not exists drivers_and_cars 
	(
		dlid varchar(255), 
		dlyear integer,
		vin varchar(255),
		model varchar(255)
	);
	
	insert into drivers_and_cars 
	select car_items.dl.dlid, extract(year from car_items.dl.datebirth) as dlyear, car_items.car.vin, car_items.car.model
	from car_items.car join car_items.cr on car_items.car.vin = car_items.cr.idcar 
	join car_items.dl on car_items.cr.iddriver = car_items.dl.dlid
	where governum like '%С%';
	
	return query (select *, car_items.get_model_year(drivers_and_cars.model) as modelyear
	from drivers_and_cars
	where drivers_and_cars.dlyear > car_items.get_model_year(drivers_and_cars.model));
end
$$
language plpgsql;

select * from car_items.get_drivers_older_model();


--- Функция с рекурсивным ОТВ, возвращает водители, которые вписаны в паспорт, но не являются владельцем ни одной машины

--- Сначала табличка с атрибутами собственник - вписанный в паспорт владелец - машина

drop function car_items.get_cr_owner_and_passport_owner;

create or replace function car_items.get_cr_owner_and_passport_owner()
returns table(dlid char(11), iddriver char(11), vin varchar(255))
as $$
begin
	return query (
		select dl.dlid, ownedby.iddriver, car.vin
		from car_items.dl 
		join car_items.cr on car_items.dl.dlid = car_items.cr.iddriver 
		join car_items.car on car_items.cr.idcar = car_items.car.vin
		join car_items.passport on car_items.passport.idcar = car_items.car.vin
		join car_items.ownedby on car_items.ownedby.idpassport = car_items.passport.idpassport);
end
$$
language plpgsql;


create or replace function car_items.get_not_owning_drivers()
returns table(dlid char(11), iddriver char(11), vin varchar(255))
as 
$$
begin
	return query
	with recursive r (dlid, iddriver, vin) AS (
	   select base.dlid, base.iddriver, base.vin
	   from car_items.get_cr_owner_and_passport_owner() as base
	   where base.dlid <> base.iddriver
	
	   union
	
	   select base.dlid, base.iddriver, base.vin
	   from car_items.get_cr_owner_and_passport_owner() as base
	   right join r on r.iddriver <> base.dlid
	   where r.iddriver is null
	)
	
	select * from r;
end
$$
language plpgsql;

select * from car_items.get_not_owning_drivers();

--- Процедура с параметрами, повышение цены заданной страховки на заданное число процентов
create or replace procedure car_items.update_insurance_price(_id varchar(255), _percent decimal)
as $$
begin
	update car_items.insurance
    set price = floor(price * (1 + _percent / 100))
    where insuranceid = _id;
end
$$
language plpgsql;

call car_items.update_insurance_price('6d211496-ea7a-4c14-b5e2-0a7370142f95', 10.0);

select * from car_items.insurance
where insuranceid = '6d211496-ea7a-4c14-b5e2-0a7370142f95';

--- Рекурсивная процедура, вывод "цепочек" владельцев машин

create or replace procedure find_all_owners(num int default 0, val varchar(255) default null)
as 
$$
declare
	num_1 int;
	buffer record;
	str varchar(255);
	all_data varchar (255);
begin
	if num = 0 then
		all_data := 'select * from car_items.get_cr_owner_and_passport_owner()';
	else
		all_data := 'select * from car_items.get_cr_owner_and_passport_owner() 
    		         where dlid = ''' || val || '''';
   	end if;
	
	
  	if num < 5 then
	    for buffer in execute all_data
	    loop
		   num_1:= num + 1;
		   str := repeat('  ', num_1) || num_1 || ' ' ||  buffer.iddriver;
		   raise notice '%', str;
		   call find_all_owners(num_1, buffer.iddriver);
	    end loop;
	end if;
end
$$
language plpgsql;

call find_all_owners();


--- Процедура с курсором, уменьшающая год на 1, если год модели чётный

create or replace procedure car_items.clear_even_years()
as 
$$
declare
	rec record;
	cur cursor for select * from car_items.model;
begin
	open cur;
	loop
		fetch cur into rec;
		if not found then exit;
		end if;
		if bool_and((rec.startyear % 2)  = 1) then
			update car_items.model 
			set startyear = startyear - 1 
			where current of cur;
		end if;
	end loop;
	close cur;
end
$$
language plpgsql;

call car_items.clear_even_years();


--- Триггер на добавление водителя в insured by (псевдонорм пересчёт коэффициентов страховки)

create or replace function car_items.update_price_after_add() 
returns trigger
as $$
declare
	category decimal;
	driver_year integer;
begin 
	driver_year := extract (year from current_date) - extract(year from (select dateissued 
																		  from car_items.dl 
																		  where new.iddriver = dl.dlid));
																		 
	if driver_year < 2 then
		category := 1;
	elseif driver_year < 7 then
		category := 0.6;
	else
		category := 0.2;
	end if;

	update car_items.insured 
	set summa = floor(new.summa * ( 1 + category))
	where car_items.insured.id = new.id;

	return new;
end
$$
language plpgsql;

create trigger t_update_price_after_add
after insert on car_items.insured 
for each row
execute procedure car_items.update_price_after_add();

insert into car_items.insured 
values('1', 15000, '5fcc4f46-0598-4981-8417-6846186312c3', '44822504453');

delete from car_items.insured 
where id  = '1';


--- Хранимая процедура доступа к метаданным, подсчёт строк в таблице

create temp table info (
	name text,
	cnt int
);


create or replace procedure car_items.table_count_strings()
as $$
declare 
		row_data record;
		sql_str text;
		table_cnt int;
begin
	for row_data in select table_schema || '.' || table_name as name
	from information_schema.tables
	where table_schema = 'car_items'
	loop
		sql_str := 'select count(*) from ' || row_data.name;
		execute sql_str
		into table_cnt;
		execute 'insert into info values ('''|| row_data.name || ''', ' || table_cnt || ');';
	end loop;
end
$$
language plpgsql;

call car_items.table_count_strings();

select * from info;


--- Триггер на добавление водительского удостоверение человека с той же датой рождения и фио (аки поменял права)

create or replace function car_items.checking_if_driver_exists()
returns trigger
as $$
begin 
	if exists (select * from car_items.drivers 
				where datebirth = new.datebirth and name = new.name) then
				
		update car_items.drivers 
		set dateissued = new.dateissued, dateexpired = new.dateexpired
		where datebirth = new.datebirth and name = new.name;
	else
		insert into car_items.dl values(substr(md5(random()::text), 0, 11), new.datebirth, new.name, new.dateissued, new.dateexpired, 'B');
	end if;

	return new;
end
$$
language plpgsql;

drop view car_items.drivers;

create view car_items.drivers as
	select name, datebirth, dateissued, dateexpired
	from car_items.dl;

create trigger t_change_dl
instead of insert on car_items.drivers
for row execute procedure car_items.checking_if_driver_exists();

alter table car_items.dl
alter column dlid set default substr(md5(random()::text), 0, 11);

insert into car_items.drivers
values('Аверкий Федосеевич Сергеев', '1955-12-11', '2021-04-24', '2031-04-24');

delete from car_items.drivers
where name = 'Михайличенко Даниил Максимович';

select * from car_items.drivers where name = 'Михайличенко Даниил Максимович';



create or replace function car_items.get_price_and_fio(car_ varchar(255))
returns table(fio varchar(255), price int4)
as $$
begin
return query (
select d."name", i.price 
from car_items.car c 
join car_items.insurance i on c.vin = i.vincar 
join car_items.insured ins on i.insuranceid = ins.idinsurance 
join car_items.dl as d on d.dlid = ins.iddriver 
join car_items.cr as cr on cr.iddriver = d.dlid
where c.vin = car_);
end
$$
language plpgsql;


select * from car_items.get_price_and_fio('E5Y7K5HF2K62Y7K69');