import datetime
import random
from faker import Faker
import requests
from dateutil.relativedelta import relativedelta
from datetime import date
import os
#
# PATH_TO_FILES = "/tmp/laba_postgr_data"
PATH_TO_FILES = "../csvs"
COUNT = 1000

response = requests.get("https://cars-base.ru/api/cars?full=1")
data = response.json()

modelsID = []
driversID = []
cars = []
passportIDs = []
insurancesIDS = []


def get_random_mark_info():
    return data[random.randint(0, len(data) - 1)]


def generate_models(faker):
    f = open(PATH_TO_FILES+'/model.csv', 'w')
    car_classes = ['A', 'B', 'C', 'D', 'E', 'F', 'S', 'M', 'j']
    fuel_types = ['АИ-92', 'АИ-95', 'D']
    transmission_types = ['АКПП', 'МКПП', 'РКПП', 'БКПП']

    for i in range(COUNT):
        markInfo = get_random_mark_info()

        id = faker.unique.uuid4()
        ecoClass = random.randint(0, 6)
        country = markInfo['country']
        brand = markInfo['name']
        name = random.choice(markInfo['models'])['name']
        start_year = faker.year()
        car_class = random.choice(car_classes)
        color = faker.color_name()
        fuel = random.choice(fuel_types)
        transmission = random.choice(transmission_types)
        wheel_side = random.choice([True, False])

        line = "{0};{1};{2};{3};{4};{5};{6};{7};{8};{9};{10}\n".format(
            id,
            ecoClass,
            country,
            brand,
            name,
            start_year,
            car_class,
            color,
            fuel,
            transmission,
            wheel_side
                              )
        f.write(line)
        modelsID.append([id, start_year])

    f.close()


def generate_dl(faker: Faker):
    f = open(PATH_TO_FILES+'/dl.csv', 'w')

    categories = ['A', 'A1', 'B1', 'C', 'C1', 'D', 'D1', 'BE', 'DE', 'CE', 'C1E', 'D1E', 'M', 'Tb', 'Tm']

    for i in range(COUNT):
        dlid = str(faker.unique.random_int(min=10000000000, max=99999999999))
        name = faker.name()
        date_issued = faker.date_time_between(date.today() - relativedelta(years=9), date.today())
        date_birth = faker.date_time_between(date_issued - relativedelta(years=70), date_issued - relativedelta(years=19))
        date_expired = date_issued + relativedelta(years=+10)
        # category = '{' + ','.join(['B'] + random.choices(categories, k=random.randint(0, len(categories)))) + '}'
        category = 'B'

        line = "{0};{1};{2};{3};{4};{5}\n".format(
            dlid,
            date_birth,
            name,
            date_issued,
            date_expired,
            category,
        )
        f.write(line)
        driversID.append(dlid)

    f.close()


def generate_cars(faker: Faker):
    f = open(PATH_TO_FILES+'/cars.csv', 'w')

    for i in range(COUNT):
        m = random.choice(modelsID)
        vin = faker.unique.vin()
        CarYear = random.randint(int(m[1]), date.today().year)
        run = random.randint(0, 1000000)
        carCategory = 'B'
        start_date = date.today().replace(day=1, month=1).toordinal()
        end_date = date.today().toordinal()
        dateLastTW = date.fromordinal(random.randint(start_date, end_date))
        model = m[0]

        line = "{0};{1};{2};{3};{4};{5}\n".format(
            vin,
            CarYear,
            run,
            carCategory,
            dateLastTW,
            model
        )

        f.write(line)
        cars.append([vin, datetime.date(int(CarYear), 1, 1), dateLastTW])

    f.close()


def generate_certificate_of_registration(faker: Faker):
    f = open(PATH_TO_FILES+'/CR.csv', 'w')

    for i in range(COUNT):
        idCR = faker.unique.uuid4()
        maxT = random.randint(2, 15)
        GBDDId = str(random.randint(1000000, 99999999))
        GoverNum = faker.license_plate()
        DateReg = faker.date_time_between(cars[i][1], cars[i][2])

        idDriver = random.choice(driversID)
        idCar = cars[i][0]

        line = "{0};{1};{2};{3};{4};{5}\n".format(
            idCR,
            GBDDId,
            GoverNum,
            DateReg,
            idDriver,
            idCar
        )

        f.write(line)
        cars[i].append(DateReg)

    f.close()


def generate_passports(faker: Faker):
    f = open(PATH_TO_FILES+'/passports.csv', 'w')

    for i in range(COUNT):
        IdPassword = faker.unique.uuid4()
        maxT = random.randint(2, 15)
        IDBody = cars[i][0]
        IDChassis = cars[i][0]
        IdCar = cars[i][0]
        DateClosed = faker.date_time_between(cars[i][1], cars[i][3])
        EPower = random.randint(100, 500)

        line = "{0};{1};{2};{3};{4};{5};{6}\n".format(
            IdPassword,
            maxT,
            IDBody,
            IDChassis,
            DateClosed,
            IdCar,
            EPower
        )

        f.write(line)
        passportIDs.append(IdPassword)

    f.close()


def generate_owned_by(faker):
    f = open(PATH_TO_FILES+'/owned_by.csv', 'w')

    for i in range(COUNT):
        id = faker.unique.uuid4()
        id_passport = passportIDs[i]
        id_dl = random.choice(driversID)
        CustomRestr = random.choice([True, False])

        line = "{0};{1};{2};{3}\n".format(
            id,
            CustomRestr,
            id_passport,
            id_dl
        )

        f.write(line)

    f.close()


def generate_insurance(faker: Faker):
    f = open(PATH_TO_FILES+'/insurance.csv', 'w')

    Types = ['ОСАГО', 'КАСКО']

    for i in range(COUNT):
        InsuranceId = faker.unique.uuid4()
        DateInsured = faker.date_time_between(cars[i][3], date.today())
        DateExpired = DateInsured + relativedelta(years=+1)
        InsuranceType = random.choice(Types)
        VINCare = cars[i][0]
        Price = random.randint(10000, 15000)

        line = "{0};{1};{2};{3};{4};{5}\n".format(
            InsuranceId,
            InsuranceType,
            DateInsured,
            DateExpired,
            Price,
            VINCare
        )

        insurancesIDS.append(InsuranceId)

        f.write(line)

    f.close()


def generate_insured(faker):
    f = open(PATH_TO_FILES+'/insured.csv', 'w')

    for i in range(COUNT):
        id = faker.unique.uuid4()
        id_insurance = random.choice(insurancesIDS)
        id_dl = random.choice(driversID)
        Summa = random.randint(15000, 100000)

        line = "{0};{1};{2};{3}\n".format(
            id,
            Summa,
            id_insurance,
            id_dl
        )

        f.write(line)

    f.close()


if not os.path.isdir(PATH_TO_FILES):
    os.makedirs(PATH_TO_FILES)

faker = Faker('ru_RU')
generate_models(faker)
generate_dl(faker)
generate_cars(faker)
generate_certificate_of_registration(faker)
generate_passports(faker)
generate_owned_by(faker)
generate_insurance(faker)
generate_insured(faker)