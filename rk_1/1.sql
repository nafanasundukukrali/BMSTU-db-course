create database rk1;

create table if not exists "Отдел"
(
	id integer primary key,
	"Название отдела" text,
	"Телефон" text
);

create table if not exists "Сотрудник"
(
	id integer primary key,
	"Должность" text,
	"ФИО" text,
	"Зарплата" integer
);

alter table "Отдел"
add column "Заведующий" integer references "Сотрудник"(id);

alter table "Сотрудник"
add column "Отдел" integer references "Отдел"(id);

create table if not exists "Медикамент"
(
	id integer primary key,
	"Название" text,
	"Инструкция" text,
	"Стоимость" integer
);

create table if not exists drink
(
	iduser integer references "Сотрудник"(id),
	idmed  integer references "Медикамент"(id)
);

delete from "Сотрудник"
where id = 1;

insert into "Сотрудник"
values (1, 'Заведующий', 'Мишкин Михаил Потапович', 100);

insert into "Сотрудник"
values (2, 'Зам Заведующего', 'Мишкин Петр Потапович', 90);

insert into "Сотрудник"
values (3, 'Зам зама заведующего', 'Петров Петр Потапович', 80);

insert into "Сотрудник"
values (4, 'Тимлид', 'Петров Петр Петрович', 300);

insert into "Сотрудник"
values (5, 'Страший специалист', 'Хомячков Хомяк Хомякович', 50);

insert into "Сотрудник"
values (6, 'Специалист', 'Губкин Василий Васильевич', 100);

insert into "Сотрудник"
values (7, 'Заведующий', 'Алексеев Алексей Алексеевич', 40);

insert into "Сотрудник"
values (8, 'Младший программист', 'Мишкин Михаил Потапович', 10);

insert into "Сотрудник"
values (9, 'Стражёр', 'Мишкин Михаил Потапович', 3);

insert into "Сотрудник"
values (10, 'Хохмач', 'Мишкин Михаил Потапович', 500);

insert into "Отдел"
values (1, 'ДКС','892676428801');

insert into "Отдел"
values (2, 'ДИТ','892676428801');

insert into "Отдел"
values (3, 'АХД','892676428803');

insert into "Отдел"
values (4, 'HR','892676428804');

insert into "Отдел"
values (5, 'Бухгалтерия','892676428804');

insert into "Отдел"
values (6, 'Юристы','892676428805');

insert into "Отдел"
values (7, 'ДВП','892676428807');

insert into "Отдел"
values (8, 'ВЛС','892676428808');

insert into "Отдел"
values (9, 'Аудит','892676428809');

insert into "Отдел"
values (10, 'Продблок','892676428810');

insert into "Медикамент"
values (1, 'Сиропчит от кашля','Принимать ораьно', 1000);

insert into "Медикамент"
values (2, 'Найс','Принимать ораьно', 146);

insert into "Медикамент"
values (3, 'Нурафен','Принимать ораьно', 200);

insert into "Медикамент"
values (4, 'Арбидол','Принимать ораьно', 500);

insert into "Медикамент"
values (5, 'Ингаверин','Принимать ораьно', 800);

insert into "Медикамент"
values (6, 'Спазмагол','Принимать ораьно', 7289);

insert into "Медикамент"
values (7, 'Зодак','Принимать ораьно', 200);

insert into "Медикамент"
values (8, 'Грипферон','Принимать ораьно', 300);

insert into "Медикамент"
values (9, 'Энтерасгель','Принимать ораьно', 1500);

insert into "Медикамент"
values (10, 'Смекта','Принимать ораьно', 100);

insert into drink
values (1, 2);

insert into drink
values (1, 3);

insert into drink
values (1, 3);

insert into drink
values (2, 2);

insert into drink
values (7, 10);

insert into drink
values (6, 5);

insert into drink
values (3, 8);

insert into drink
values (9, 1);

insert into drink
values (8, 10);

insert into drink
values (3, 5);

update "Отдел"
set "Заведующий" = 1;

update "Отдел"
set "Заведующий" = 7
where id = 3;

update "Сотрудник"
set "Отдел" = 1
where id = 1;

update "Сотрудник"
set "Отдел" = 2
where id = 2;

update "Сотрудник"
set "Отдел" = 3
where id = 3;

update "Сотрудник"
set "Отдел" = 4
where id = 4;

update "Сотрудник"
set "Отдел" = 5
where id = 5;

update "Сотрудник"
set "Отдел" = 6
where id = 6;

update "Сотрудник"
set "Отдел" = 7
where id = 7;

update "Сотрудник"
set "Отдел" = 8
where id = 8;

update "Сотрудник"
set "Отдел" = 9
where id = 9;

update "Сотрудник"
set "Отдел" = 10
where id = 10;

