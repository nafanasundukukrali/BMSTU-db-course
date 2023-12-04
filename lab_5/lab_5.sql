--- 1. Из таблиц базы данных, созданной в первой лабораторной работе, извлечь
--- данные в XML (MSSQL) или JSON(Oracle, Postgres). Для выгрузки в XML
--- проверить все режимы конструкции FOR XML

create or replace function car_items.save_to_json()
returns void
as $$
declare
	tb_name record;
	sql_str text;
begin 
	for tb_name in select table_name as name
					from information_schema."tables"
					where table_schema = 'car_items' and table_type != 'VIEW'
	loop
		execute 'copy (select row_to_json(t) from car_items.' || tb_name.name || ' t ) to ''/tmp/db/' || tb_name.name || '.json''';
	end loop;		
end
$$
language plpgsql;

select car_items.save_to_json();

-- 2. Выполнить загрузку и сохранение XML или JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе.

create temp table json_tab(json_t json);

copy json_tab from '/tmp/db/car.json';

select *
from json_tab;

drop table copy_cars;

create table if not exists copy_cars
(
    VIN varchar(255) primary key,
    CarYear integer,
    Run integer,
    CarCategory char(1),
    dateLastTW date,
    model varchar(255),
    foreign key (model) references car_items.Model 
);

create function car_items.get_model_year_copy(_model varchar(255))
returns integer
as
$$
	select StartYear from car_items.Model where ModelID = _model;
$$ 
language sql;	

alter table car_items.copy_cars
add check (CarYear >= car_items.get_model_year_copy(model));

insert into copy_cars
select j.*
from json_tab cross join lateral json_populate_record(null::copy_cars, json_t) as j

select * from copy_cars;

--- 3. Создать таблицу, в которой будет атрибут(-ы) с типом XML или JSON, или
--  добавить атрибут с типом XML или JSON к уже существующей таблице.
--  Заполнить атрибут правдоподобными данными с помощью команд INSERT
--  или UPDATE. 

create extension if not exists"uuid-ossp";

drop table users;
create table users
(
	id uuid default gen_random_uuid() primary key,
	user_name text,
	info json
)

insert into users
values (default, 'alina', '{"country": "Russia", "city": "Moscow"}'::json);

insert into users
values (default, 'vanya', '{"country": "Russia", "city": "St. Petersburg"}'::json);

insert into users
values (default, 'dima', '{"country": "Russia", "city": "Nalchik"}'::json);

insert into users
values (default, 'lera', '{"country": "Russia", "city": "Moscow"}'::json);


select * from users;

-- 4 Выполнить следующие действия:
-- 1. Извлечь XML/JSON фрагмент из XML/JSON документа

select * from json_tab;

-- 2. Извлечь значения конкретных узлов или атрибутов XML/JSON документа

select json_t->>'vin' as vin,  json_t->>'caryear' as caryear
from json_tab;

-- 3. Выполнить проверку существования узла или атрибута

select json_t->'vin' as vin
from json_tab
where json_t->'vin' is not null;

-- 4. Изменить XML/JSON документ

update json_tab
set json_t = json_t::jsonb || '{"changed by": "alina"}'::jsonb

select *
from json_tab;

-- 5. Разделить XML/JSON документ на несколько строк по узлам 

select jsonb_each_text(json_t::jsonb) 
from json_tab;

