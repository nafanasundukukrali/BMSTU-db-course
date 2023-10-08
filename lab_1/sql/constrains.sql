--На водителя
ALTER TABLE car_items.DL
ADD CHECK (DateBirth + interval '18 years' <= DateIssued AND DateIssued + interval '10 years' =  DateExpired);

-- На модель
ALTER TABLE car_items.Model
ADD CHECK (0 <= EcoClass AND 6 >= EcoClass);


-- На машину
CREATE FUNCTION car_items.get_model_year(_model VARCHAR(255))
RETURNS INTEGER
AS
$$
	SELECT StartYear FROM car_items.Model WHERE ModelID = _model;
$$ LANGUAGE SQL;

ALTER TABLE car_items.Car
ADD CHECK (CarYear >= car_items.get_model_year(model));

-- На свидетельство о регистрации

CREATE FUNCTION car_items.get_car_year(_vin VARCHAR(255))
RETURNS INTEGER
AS
$$
	SELECT CarYear FROM car_items.Car WHERE VIN = _vin;
$$ LANGUAGE SQL;

CREATE FUNCTION car_items.get_DL_expired_date(_dl CHAR(11))
RETURNS DATE
AS
$$
	SELECT DateExpired FROM car_items.DL WHERE DLID = _dl;
$$ LANGUAGE SQL;

ALTER TABLE car_items.CR
ADD CHECK (EXTRACT(YEAR FROM DateReg)::int >= car_items.get_car_year(idCar) AND 
		   DateReg <= car_items.get_DL_expired_date(idDriver));

-- На паспорт
ALTER TABLE car_items.Passport
ADD CHECK (EXTRACT(YEAR FROM DateClosed)::int >= car_items.get_car_year(idCar));

-- На OwnedBy
CREATE FUNCTION car_items.get_passport_date_closed(_passport VARCHAR(255))
RETURNS DATE
AS
$$
	SELECT DateClosed FROM car_items.Passport WHERE IdPassport = _passport;
$$ LANGUAGE SQL;


ALTER TABLE car_items.OwnedBy
ADD CHECK (car_items.get_passport_date_closed(idPassport) <= car_items.get_DL_expired_date(idDriver));

--Страховки
ALTER TABLE car_items.Insurance
ADD CHECK (DateInsured < DateExpired AND EXTRACT(YEAR FROM DateInsured)::int >= car_items.get_car_year(VINCar));



