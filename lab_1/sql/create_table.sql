CREATE DATABASE cars;
\c cars;
CREATE SCHEMA car_items;


CREATE TABLE IF NOT EXISTS car_items.DL (
    DLID CHAR(11) PRIMARY KEY,
    DateBirth DATE,
    Name VARCHAR(255),
    DateIssued DATE,
    DateExpired DATE,
    Category CHAR(1)
);

CREATE DOMAIN car_items.car_class AS TEXT
CHECK(
   VALUE ~ '^(?:(A|B|C|D|E|F|S|M|j))$'
);

CREATE DOMAIN car_items.fuel_type AS TEXT
CHECK(
   VALUE ~ '^(?:(АИ-92|АИ-95|D))$'
);

CREATE DOMAIN car_items.transmission_type AS TEXT
CHECK(
   VALUE ~ '^(?:(АКПП|МКПП|РКПП|БКПП))$'
);


CREATE TABLE IF NOT EXISTS car_items.Model (
    ModelID VARCHAR(255) PRIMARY KEY,
    EcoClass INTEGER,
    Country VARCHAR(255),
    Mark VARCHAR(255),
    Name VARCHAR(255),
    StartYear INTEGER,
    CarClass car_items.car_class,
    Color VARCHAR(255),
    Fuel car_items.fuel_type,
    Transmission car_items.transmission_type,
    WheelSide BOOLEAN
);

CREATE TABLE IF NOT EXISTS car_items.Car (
    VIN VARCHAR(255) PRIMARY KEY,
    CarYear INTEGER,
    Run INTEGER,
    CarCategory CHAR(1),
    dateLastTW DATE,
    model VARCHAR(255),
    FOREIGN KEY (model)  REFERENCES car_items.Model (ModelID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS car_items.CR (
    IDCR VARCHAR(255) PRIMARY KEY,
    GBDDId VARCHAR(255),
    GoverNum VARCHAR(255),
    DateReg DATE,
    idDriver CHAR(11),
    idCar VARCHAR(255),
    FOREIGN KEY (idDriver)  REFERENCES car_items.DL (DLID) ON DELETE CASCADE,
    FOREIGN KEY (idCar) REFERENCES car_items.Car (VIN) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS car_items.Passport (
    IdPassport VARCHAR(255) PRIMARY KEY,
    MaxT INTEGER,
    IdBody VARCHAR(255),
    IdChassis VARCHAR(255),
    DateClosed DATE,
    IdCar VARCHAR(255),
    EPower INTEGER,
    FOREIGN KEY (IdCar) REFERENCES car_items.Car (VIN) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS car_items.OwnedBy (
    Id VARCHAR(255) PRIMARY KEY,
    CustomRestr BOOLEAN,
    idPassport VARCHAR(255),
    idDriver CHAR(11),
    FOREIGN KEY (idDriver)  REFERENCES car_items.DL (DLID) ON DELETE CASCADE,
    FOREIGN KEY (idPassport) REFERENCES car_items.Passport (IdPassport) ON DELETE CASCADE
);

CREATE DOMAIN car_items.insurance_type AS TEXT
CHECK(
   VALUE ~ '^(?:(ОСАГО|КАСКО))$'
);

CREATE TABLE IF NOT EXISTS car_items.Insurance (
    InsuranceId VARCHAR(255) PRIMARY KEY,
    InsuranceType VARCHAR(255),
    DateInsured DATE,
    DateExpired DATE,
    Price INTEGER,
    VINCar VARCHAR(255),
    FOREIGN KEY (VINCar) REFERENCES car_items.Car (VIN) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS car_items.Insured (
    Id VARCHAR(255) PRIMARY KEY,
    Summa INTEGER,
    idInsurance VARCHAR(255),
    idDriver CHAR(11),
    FOREIGN KEY (idInsurance)  REFERENCES car_items.Insurance (InsuranceId) ON DELETE CASCADE,
    FOREIGN KEY (idDriver)  REFERENCES car_items.DL (DLID) ON DELETE CASCADE
);
