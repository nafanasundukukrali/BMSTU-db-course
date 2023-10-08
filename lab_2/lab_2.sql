-- 1. Машины, у которых владельцы автомобиля вписаны в страховку

select dl.dlid, dl.dateissued, cr.idcar, insured.idinsurance
from insured 
join cr on insured.iddriver = cr.iddriver 
join dl on cr.iddriver  = dl.dlid 
where extract ( year from current_date) - extract( year from dl.datebirth) < 40
order by dl.dateissued;

-- 2. Водители от 25 до 30

select dl.dlid, dl.datebirth, dl.dateissued
from dl
where extract ( year from current_date) - extract( year from dl.datebirth) between 25 AND 30
order by dl.datebirth desc;

-- 3. Водители Марии

select dl.name,  dl.dlid
from dl
where dl.name like '%Мария%';

--- 4. Водители, у которых нет осаго на машину

select distinct cr.iddriver, cr.idcar
from cr
where cr.idcar in (select insurance.vincar from insurance where insurancetype <> 'ОСАГО');

--- 5. Водители, которые являются собственниками хотя бы одной машины
select distinct dl.dlid 
from dl
where exists (
	select cr.iddriver from cr where cr.iddriver = dl.dlid
);

--- 6. Модели, выпущенные раньше самого молодого водителя

select model."name", model.startyear 
from model 
where model.startyear > all(select extract(year from (dl.datebirth)) from dl);

--- 7. Количество машин соотвествующих моделей

select car.model, count(car.vin) 
from car
group by car.model;

-- 8. Модели с указанием максимальной мощности двигателя, прописанной в паспорте, среди всех машин

select m.name, 
	(select max(passport.epower) 
	 from passport join car on passport.idcar = car.vin 
	 where m.modelid = car.model) as max_epower
from model as m
where exists 
			(select car.vin
			from car 
			where car.model = m.modelid);

--- 9. Отечестенные и импортные модели

select model.name, model.country,
	case model.country 
		when 'Россия' then 'Отчественная'
		else 'Импортная'
	end as status
from model;

--- 10. Можно ли заезжать в зоны с экологическими ограничениями

select model.name, model.ecoclass,
	case
		when model.ecoclass < 5 AND model.ecoclass > 2 then 'В России есть ограничения'
		when model.ecoclass <= 2 then 'Можно из дома даже не выезжать'
		else 'Можно'
	end as status
from model;

--- 11. Полпулярные (купленные больше 1 раза) модели с дизелем

select model.name, count(car.vin)
into temp table DPopular
from model join car on model.modelid = car.model
where model.fuel = 'D'and (
	select count(car.vin) from car 
	where car.model = modelid
	) > 1
group by model.name;

select * from DPopular;
	
drop table DPopular;

--- 12. Машины и водители, вписанные в их страховки

select car.vin, drivers.dlid
from car join (select dl.dlid, insurance.vincar 
				from dl join insured on dl.dlid = insured.iddriver 
				join insurance on insurance.insuranceid = insured.idinsurance) as drivers on drivers.vincar = car.vin
order by car.vin;

--- 13. Все модели машин, которые есть у водителей

select distinct dl.dlid, models."name" 
from dl join (select model."name", cr.iddriver
			  from model join (
			  					select car.model, car.vin 
			  					from car
			  					where caryear > all(select extract (year from dl.datebirth) from dl)
			  				  ) as fcars on fcars.model = model.modelid 
			  				  join cr on fcars.vin = cr.idcar
				) as models on models.iddriver = dl.dlid
order by dl.dlid;


--- 14. Страховки с количеством водетелей, прогоном и стоимостью

select insurance.insuranceid as "Страховка", count(dl.dlid) as "Кол-во застрахованных лиц", car.run as "Прогон", insurance.price as "Цена"
from insurance join insured on insurance.insuranceid = insured.idinsurance
join dl on dl.dlid = insured.iddriver 
join car on car.vin = insurance.vincar
group by "Страховка", "Прогон", "Цена";


--- 15. Страховки, где количество застрахованных лиц больше 2

select insurance.insuranceid as "Страховка", count(dl.dlid) as "Кол-во застрахованных лиц"
from insurance join insured on insurance.insuranceid = insured.idinsurance
join dl on dl.dlid = insured.iddriver 
group by "Страховка"
having count(dl.dlid) > 2;


--- 16. Новый водитель

insert into dl (dlid, datebirth, dateissued, dateexpired, category, name)
values ('1', '2003-09-06', '2022-04-24', '2032-04-024', 'B', 'Мишкин Михаил Потапович');


--- 17. Добавление рестайлинга моделей до 80

insert into model (modelid, ecoclass, country, mark, name, 
					startyear, carclass, color, fuel, transmission)
select modelid || '-2', 6, country, mark, name || 'Restailing', 
		2023, carclass, color, fuel, transmission
from model
where startyear < 1980;

select * from model
where startyear = 2023 AND name like '%Restailing%';

--- 18. Пробег ввсех машинок + 30, везде, где он от 10000 до 20000

update car
set run = run  + 30
where run between 10000 and 20000;

--- 19. Умножение цен на среднюю цену

update insurance as i
set price = price * (select avg(price) from insurance);


--- 20. Удаление всех машин с прогоном больше 1000000

delete from car where caryear < 1900;

--- 21. Удаление всех водителей без машинок (

delete from dl
where (select count(dl.dlid) from dl 
		join cr on dl.dlid = cr.iddriver) = 0;

--- 22. Водители  и их  страховки, водите  и их машины
with "Водители и их страховки" ("Удостоверение водительское", "Страховой номер") as
    (select dl.dlid, insurance.insuranceid
    from insurance 
    join insured on insurance.insuranceid = insured.idinsurance 
	join dl on dl.dlid = insured.iddriver)

SELECT * FROM "Водители и их страховки";

--- 23. Вывести все машинки, принадлежащие водителю 74251410678

select ownedby.iddriver, ownedby.idpassport, passport.idcar
into temp passport_users
from ownedby join passport on ownedby.idpassport = passport.idpassport;

with recursive r (iddriver, idpassport, idcar) as 
(
	select iddriver, idpassport, idcar
	from passport_users
	where iddriver = '74251410678'
	
	union
	
	select passport_users.iddriver, passport_users.idpassport , passport_users.idcar
	from passport_users join r on passport_users.iddriver = r.iddriver
)

select * from r;


--- 24. Водители, оличество машинок, средний максимальный и минимальный прогон
	
with DriversAndCars (dlid, name, run) as
    (select dl.dlid, car.vin, car.run
    from insurance 
    join insured on insurance.insuranceid = insured.idinsurance
    join car on insurance.vincar = car.vin 
	join dl on dl.dlid = insured.iddriver)
	
select distinct dlid, 
	count(name) OVER(partition by dlid) cars_count,
	AVG(run) OVER(partition by dlid) as avg_run,
	MAX(run) OVER(partition by dlid) as max_run,
	MIN(run) OVER(partition by dlid) as min_run
from DriversAndCars;

--- 25. Удаление дублей

with DriversAndCars (dlid, name, run) as
    (select dl.dlid, car.vin, car.run
    from insurance 
    join insured on insurance.insuranceid = insured.idinsurance
    join car on insurance.vincar = car.vin 
	join dl on dl.dlid = insured.iddriver)
	

select dlid, 
count(name) OVER(partition by dlid) cars_count,
AVG(run) OVER(partition by dlid) as avg_run,
MAX(run) OVER(partition by dlid) as max_run,
MIN(run) OVER(partition by dlid) as min_run,
row_number() over(partition by dlid order by dlid) as num
into temp table NotDoubles
from DriversAndCars;

select * from NotDoubles;

DELETE FROM NotDoubles
WHERE num > 1;

select * from NotDoubles;
