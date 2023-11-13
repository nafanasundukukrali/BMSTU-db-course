create extension if not exists plpython3u;

--- Скалярная функция
--- Медианная цена страховки
create or replace function median_price()
returns decimal(10,2)
as
$$
from statistics import median
query = """select price 
		from insurance i;
        """
prices = plpy.execute(query) 
return median([list(row.values())[0] for row in prices])
$$
language plpython3u;

select * from median_price(); 

--- агрегатная функция
--- Медианное значение (целые числа)

drop type mediana_state;
create type mediana_state as
(
	arr int[]
);

create or replace function get_sort_arr(state mediana_state, val integer)
returns mediana_state
as $$
begin
	state.arr = array_append(state.arr, val);
	raise notice 'arr: %', state.arr;
	return row(state.arr)::mediana_state;
end
$$
language plpgsql;

CREATE EXTENSION intarray;

create or replace function get_median(state mediana_state)
returns int
as $$ 
declare 
	size_ int;
begin
	state.arr = sort(state.arr);
	if array_length(state.arr, 1) % 2 then
		size_ = array_length(state.arr, 1) / 2 + 1;
	else 
		size_ = array_length(state.arr, 1) / 2;
	end if;

	raise notice '%', size_;

	return state.arr[size_];
end;
$$
language plpgsql;

drop function get_median(state mediana_state) cascade;
create or replace function get_median(state mediana_state)
returns int
as $$ 
arr = sorted(list(state['arr']))
return arr[len(arr) // 2 + len(arr) % 2]
$$
language plpython3u;

create or replace aggregate medium (int)
(
	sfunc = get_sort_arr,
	stype = mediana_state,
    finalfunc = get_median
);

create temp table buffer_table
(vale int);

insert into buffer_table values(3);
insert into buffer_table values(32);
insert into buffer_table values(1);
delete from buffer_table where vale = 1;

select medium(vale) from buffer_table;

--- Пользовательская табличная функция CLR
--- Возращает страховки по id водителя

create or replace function get_cars_insurance(id_ varchar(255))
returns table(id varchar(255))
as
$$
    query = plpy.execute("select i.idinsurance, i.iddriver from car_items.insured i join car_items.insurance i2 on i.idinsurance  = i2.insuranceid")
    res = []
    for value in query:
        if value['iddriver'] == id_:
            res.append(value['idinsurance'])
    return res
$$
language plpython3u;

select * from get_cars_insurance('48177788641');

-- Хранимая процедура CLR
-- Увеличение цены страховок на 10%

create or replace procedure update_price()
as 
$$
    plpy.execute("update car_items.insurance set price = price  * 1.1;")
$$ 
language plpython3u;


select * from car_items.insurance;

CALL update_price();

select * from car_items.insurance;

-- Триггер CLR
-- Триггер на добавление водительского удостоверение человека с той же датой рождения и фио (аки поменял права)

select * from car_items.drivers d 
where datebirth = "1955-12-11";

create or replace function car_items.checking_if_driver_exists()
returns trigger
as 
$$
	query = plpy.execute(f'select * from car_items.drivers where datebirth = \'{TD["new"]["datebirth"]}\' and name = \'{TD["new"]["name"]}\'')
	 
	if len(query) != 0:
		plpy.execute(f'update car_items.drivers set dateissued = \'{TD["new"]["dateissued"]}\', dateexpired = \'{TD["new"]["dateexpired"]}\' where datebirth = \'{TD["new"]["datebirth"]}\' and name = \'{TD["new"]["name"]}\'');
	else:
		plpy.execute(f'insert into car_items.dl values(substr(md5(random()::text), 0, 11), \'{TD["new"]["datebirth"]}\', \'{TD["new"]["name"]}\', \'B\'')
	
	return 
$$
language plpython3u;

drop view car_items.drivers;

create view car_items.drivers as
	select name, datebirth, dateissued, dateexpired
	from car_items.dl;

create or replace trigger t_change_dl
instead of insert on car_items.drivers
for row execute procedure car_items.checking_if_driver_exists();

alter table car_items.dl
alter column dlid set default substr(md5(random()::text), 0, 11);

insert into car_items.drivers
values('Аверкий Федосеевич Сергеев', '1955-12-11', '2022-04-24', '2032-04-24');

select * from car_items.drivers where name = 'Аверкий Федосеевич Сергеев';

--- Определяемый пользователем тип данных CLR
--- Возвращает модел машинки и её год выпуска по ВИН

create type car_items.model_year as (
	model varchar(255),
	year integer
);

create or replace function get_car_model_and_year(id_ varchar(255))
returns car_items.model_year 
as
$$
	query = plpy.execute(f'select * from car_items.car c join car_items.model m on c.model = m.modelid where vin = \'{id_}\'')
	return (query[0]['name'], query[0]['caryear'])
$$
language plpython3u;


select * from get_car_model_and_year('2SY20EH03BV5VPZFA');



