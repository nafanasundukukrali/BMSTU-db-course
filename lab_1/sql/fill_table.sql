COPY car_items.DL(DLID, DateBirth, Name, DateIssued, DateExpired, Category) 
	FROM '/tmp/laba_postgr_data/dl.csv' 
	DELIMITER ';';
SELECT * FROM car_items.DL;

COPY car_items.Model(ModelID, EcoClass, Country, Mark, Name, StartYear, CarClass, Color, Fuel, Transmission, WheelSide)
	FROM '/tmp/laba_postgr_data/model.csv' 
	DELIMITER ';';
SELECT * FROM car_items.Model;

COPY car_items.Car(VIN, CarYear, Run, CarCategory, dateLastTW, model)
	FROM '/tmp/laba_postgr_data/cars.csv' 
	DELIMITER ';';
SELECT * FROM car_items.Car;

COPY car_items.CR(IDCR, GBDDId, GoverNum, DateReg, idDriver, idCar)
	FROM '/tmp/laba_postgr_data/CR.csv' 
	DELIMITER ';';
SELECT * FROM car_items.CR;

COPY car_items.Passport(IdPassport, MaxT, IdBody, IdChassis, DateClosed, IdCar, EPower)
	FROM '/tmp/laba_postgr_data/passports.csv' 
	DELIMITER ';';
SELECT * FROM car_items.Passport;

COPY car_items.OwnedBy(Id, CustomRestr, idPassport, idDriver)
	FROM '/tmp/laba_postgr_data/owned_by.csv' 
	DELIMITER ';';
SELECT * FROM car_items.OwnedBy;

COPY car_items.Insurance (InsuranceId, InsuranceType, DateInsured, DateExpired, Price, VINCar)
	FROM '/tmp/laba_postgr_data/insurance.csv' 
	DELIMITER ';';
SELECT * FROM car_items.Insurance;

COPY car_items.Insured (Id, Summa, idInsurance, idDriver)
	FROM '/tmp/laba_postgr_data/insured.csv' 
	DELIMITER ';';
SELECT * FROM car_items.Insured;