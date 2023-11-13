create database rk2;

\c rk2;

create table if not exists "Животное"
(
	id integer primary key,
	"Вид" varchar(255),
	"Порода" varchar(255),
	"Кличка" varchar(255)
);

create table if not exists "Болезнь"
(
	id integer primary key,
	"Назвнаие болезни" varchar(255),
	"Симптом" varchar(255),
	"Анализ" varchar(255)
);

create table if not exists "Хозяин"
(
	id integer primary key,
	"ФИО" varchar(255),
	"Адрес" varchar(255),
	"Телефон" varchar(255)
);

create table if not exists Ownedby
(
	idanimal integer references "Животное"(id),
	idowner integer references "Хозяин"(id)
);

create table if not exists Sick
(
	idanimal integer references "Животное"(id),
	idillness integer references "Болезнь"(id)
);

insert into "Животное"
values (1, 'Пони', 'Розовый', 'Желтоглазик');

insert into "Животное"
values (2, 'Пони', 'Белый', 'Единорожечек');

insert into "Животное"
values (3, 'Кот', 'Британец', 'Дымок');

insert into "Животное"
values (4, 'Собака', 'Той терьер', 'Кантемир');

insert into "Животное"
values (5, 'Собака', 'Русский той терьер', 'Кантемир Вальтерович');

insert into "Животное"
values (6, 'Собака', 'Пудель', 'Молли');

insert into "Животное"
values (7, 'Кот', 'Мейкун', 'Аид');

insert into "Животное"
values (8, 'Медведь', 'Русский', 'Мизаил Потапович');

insert into "Животное"
values (9, 'Медведь', 'Русский', 'Настасья Потаповна');

insert into "Животное"
values (10, 'Медведь', 'Русский', 'Мишутка');

insert into "Болезнь"
values (1, 'Чумка', 'Пониженный гемглобин', 'ОАК');

insert into "Болезнь"
values (2, 'Рак почки', 'Слюноотделение', 'Наблюдение');

insert into "Болезнь"
values (3, 'Рак поджелудочной', 'Скуление', 'Биопсия');

insert into "Болезнь"
values (4, 'Рак печени', 'Скуление', 'Биопсия');

insert into "Болезнь"
values (5, 'Инсульт', 'Скуление', 'Наблюдение');

insert into "Болезнь"
values (6, 'Чумка волшебная', 'Понос', 'Наблюдение');

insert into "Болезнь"
values (7, 'что-то', 'ЛОл', 'Наблюдение');

insert into "Болезнь"
values (8, 'чт', 'ЛОл', 'Наблюдение');

insert into "Болезнь"
values (9, 'Понос', 'Понос', 'ОК');

insert into "Болезнь"
values (10, 'Ротовирус', 'Понос и рвота', 'ОАК');

insert into "Хозяин"
values (1, 'Митрофанов Михаил Максимович', 'г. Москва, Басманная', '89267621801');

insert into "Хозяин"
values (2, 'Митрофанова Валентина Петровна', 'г. Москва, Чертаново', '89267621802');

insert into "Хозяин"
values (3, 'Ежов Михаил Максимович', 'г. Москва, Тверская', '89267621803');

insert into "Хозяин"
values (4, 'Куров Михаил Максимович', 'г. Москва, Тверская', '89267621804');

insert into "Хозяин"
values (5, 'Куров Андрей Максимович', 'г. Москва, Болатниовская 5в', '89267621805');

insert into "Хозяин"
values (6, 'Куров Андрей Владимирович', 'г. Москва, Болатниовская 5г', '89267621806');

insert into "Хозяин"
values (7, 'Кострицкий Андрей Владимирович', 'г. Москва, Россошанская 5г', '89267621807');

insert into "Хозяин"
values (8, 'Кострицкий Александр Владимирович', 'г. Москва, улица 1905 года 5г', '89267621808');

insert into "Хозяин"
values (9, 'Кострицкий Александр Сергеевич', 'г. Москва, Патриашие 5г', '89267621809');

insert into "Хозяин"
values (10, 'Кострицкий Александр Сергеевич', 'г. Москва, Патриашие 5г', '89267621010');

insert into ownedby
values (5, 7);

insert into ownedby
values (3, 3);

insert into ownedby
values (9, 4);

insert into ownedby
values (10, 4);

insert into ownedby
values (10, 10);

insert into ownedby
values (2, 2);

insert into ownedby
values (2, 7);

insert into Sick
values(1, 2);

insert into Sick
values(3, 4);

insert into Sick
values(5, 6);

insert into Sick
values(7, 8);

insert into Sick
values(9, 10);

insert into Sick
values(8, 9);

insert into Sick
values(6, 7);

insert into Sick
values(4, 5);

insert into Sick
values(2, 3);

insert into Sick
values(10, 1);

insert into Sick
values(10, 7);

select * from information_schema.tables as i_s
where i_s.table_catalog  = 'rk2';

select column_name  from information_schema.columns as c
where c.table_name = 'Хозяин';



create or replace procedure get_indexes(db_name text, table_n text)
as $$
declare 
	val record;
begin
	for val in select *
	from information_schema.columns t join pg_catalog.pg_indexes p on t.table_name = p.tablename
	where t.table_catalog = 'rk2' and t.table_name = 'Хозяин'
	loop 
		raise notice '%', val.column_name;
	end loop;
end
$$
language plpgsql;

call get_indexes('rk2', 'Хозяин'); 

create table if not exists TableNamePony
(
	lalal text
);

create table if not exists PonyTableNamePony
(
	lalal text
);

create or replace procedure delete_tablename()
as 
$$
declare
	table_n record;
	command text;
begin
	for table_n in select table_name from information_schema.tables t
					where t.table_name like 'tablename%'
	loop 
		command := 'drop table ' || table_n.table_name;  
		execute(command);
	end loop;
end
$$
language plpgsql;

select * from information_schema.tables t
where t.table_name like '%tablename%';

call delete_tablename();

create view new_view_owner as
select "ФИО" 
from "Хозяин";

select t.view_definition 
from information_schema.views t
where t.table_schema = 'public';

drop procedure delete_views();


create or replace procedure delete_views(out new_res integer)
as $$
declare 
	rc record;
	command text;
	res integer;
begin
	res := 0;
	for rc in select t.table_name 
	from information_schema.views t
	where t.table_schema = 'public'
	loop 
		command := 'drop view ' || rc.table_name;
		execute(command);
		res := res + 1;
	end loop;
	new_res := res;
end;
$$
language plpgsql;

call delete_views(null);




