import psycopg2 as psql
from prettytable import PrettyTable
import config
import random

class CarItems:
    def __init__(self):
        try:
            self._connection = psql.connect(
                               dbname=config.DBNAME,
                               user=config.USER,
                               password=config.PASSWORD,
                                host='localhost',
                               options="-c search_path=car_items")
            self._cursor = self._connection.cursor()
            self._res = None
        except:
            print('Can`t establish connect to database')
            exit(1)

        self._table_created = False

    def result(self):
        return self._res

    def __del__(self):
        if self._connection:
            query = """
                    drop table fine
                    """

            try:
                self._cursor.execute(query)
            except:
                pass

            self._cursor.close()
            self._connection.close()

    def _save(self):
        return self._cursor.fetchall()

    # Выполнить скалярный запрос
    def get_cars_count(self):
        query = """
                select count(vin)
                from car
                """

        self._cursor.execute(query)

        self._res = PrettyTable()

        self._res.field_names = ["Count"]
        self._res.add_row([self._save()[0][0]])

    # Выполнить запрос с несколькими соединениями(JOIN)
    def get_drivers_and_theme_cars(self):
        query = """
                 select ca.vin, d.dlid 
                 from car_items.car ca 
                 join car_items.cr c on c.idcar = ca.vin 
                 join car_items.dl d on d.dlid = c.iddriver 
                 """

        self._cursor.execute(query)

        self._res = PrettyTable()
        self._res.field_names = ["vin", "driver id"]
        buffer_res = self._save()

        for value in buffer_res:
            self._res.add_row([value[0], value[1]])

    # Выполнить запрос с ОТВ(CTE) и оконными функциями
    def get_drivers_dl_older_theme_cars(self):
        query = """
                with driver_cars as (select ca.vin, d.dlid, d.dateissued,  ca.caryear 
                from car_items.car ca 
                join car_items.cr c on c.idcar = ca.vin 
                join car_items.dl d on d.dlid = c.iddriver)
            
                select dlid, count(vin) 
                from  driver_cars
                where caryear > extract(year from dateissued)
                group by dlid;
                 """

        self._cursor.execute(query)

        self._res = PrettyTable()
        self._res.field_names = ["driver id", "cars count"]
        buffer_res = self._save()

        for value in buffer_res:
            self._res.add_row([value[0], value[1]])

    # Выполнить запрос к метаданным
    def get_tables_names(self):
        query = """
                select tablename, tableowner 
                from pg_catalog.pg_tables 
                where schemaname = 'car_items';
                 """

        self._cursor.execute(query)

        self._res = PrettyTable()
        self._res.field_names = ["table name", "table owner"]
        buffer_res = self._save()

        for value in buffer_res:
            self._res.add_row([value[0], value[1]])

    # Вызвать скалярную функцию
    def get_car_model_start_year(self, model):
        query = f'select * from model where modelid = \'{model}\''

        self._cursor.execute(query)
        buffer_res = self._save()

        if buffer_res == []:
            print("Некорректный был введён идентификатор модели.")
            return False

        query = f'select * from get_model_year(\'{model}\')'

        self._cursor.execute(query)

        self._res = PrettyTable()
        self._res.field_names = ["start year"]
        buffer_res = self._save()

        self._res.add_row([buffer_res[0][0]])

        return True

    # Вызвать многооператорную или табличную функци
    def get_insurances_info_for_cars(self):
        query = 'select * from get_car_insurance_info()'

        self._cursor.execute(query)

        self._res = PrettyTable()
        self._res.field_names = ["vin", "insurance id", "insurance type", "drivers count"]

        buffer_res = self._save()

        for value in buffer_res:
            self._res.add_row([value[0], value[1], value[2], value[3]])

    # Вызвать хранимую процедуру
    def clear_even_years(self):
        query = 'call clear_even_years()'

        self._cursor.execute(query)

    # Вызвать системную функцию или процедуру
    def get_current_user(self):
        query = 'select current_role'

        self._cursor.execute(query)

        self._res = PrettyTable()
        self._res.field_names = ["user"]

        buffer_res = self._save()

        self._res.add_row([buffer_res[0][0]])

    # Создать таблицу в базе данных
    def create_table(self):
        if self._table_created:
            print("Таблица уже была создана")
            return

        query = '''
            create table if not exists fine
            (
                vin varchar(255),
                summa integer
            )
        '''

        self._cursor.execute(query)
        self._connection.commit()

        self._table_created = True

    # Выполнить вставку данных в созданную таблицу
    def insert_values(self, car, sum):
        if not self._table_created:
            print("Таблица не создана.")
            return False

        query = f'select * from car where car.vin = \'{car}\''
        self._cursor.execute(query)
        buffer_res = self._save()

        if buffer_res == [] or sum <= 0:
            print("Номер машины не обнаружен.")
            return False

        query = f'insert into fine values(\'{car}\', \'{sum}\')'
        self._cursor.execute(query)

        query = f'select * from fine'
        self._cursor.execute(query)

        self._res = PrettyTable()
        self._res.field_names = ["car vin", "sum"]
        buffer_res = self._save()

        for value in buffer_res:
            self._res.add_row([value[0], value[1]])

        return True

    def get_some_models(self):
        query = """
                 select "name", modelid
                 from model
                 """

        self._cursor.execute(query)

        self._res = PrettyTable()
        self._res.field_names = ["model name", "model id"]
        buffer_res = self._save()

        for _ in range(10):
            self._res.add_row([buffer_res[random.randint(0, len(buffer_res))][0],
                               buffer_res[random.randint(0, len(buffer_res))][1]])

    def get_some_cars(self):
        query = """
                 select vin
                 from car
                 """

        self._cursor.execute(query)

        self._res = PrettyTable()
        self._res.field_names = ["vin"]
        buffer_res = self._save()

        for _ in range(10):
            self._res.add_row([buffer_res[random.randint(0, len(buffer_res))][0]])



cars = CarItems()

while True:
    print("""
        Выберете 1 пункт из меню:
        1. Получить полное количество машин (Выполнить скалярный запрос)
        2. Получить информацию о машинах и их владельцах (Выполнить запрос с несколькими соединениями(JOIN))
        3. Получить машины, год выпуска которых младше года выдачи прав (Выполнить запрос с ОТВ(CTE) и оконными функциями)
        4. Получить список таблиц в схеме (Выполнить запрос к метаданным)
        5. Получить год начала выпуска модели по её названию (Вызвать скалярную функцию) 
        6. Получить информацию по страховкам по машинам (Вызвать многооператорную или табличную функцию)
        7. Уменьшить год на 1 моделей, которые начали выпускать в чётном году (Вызвать хранимую процедуру)
        8. Вывести текущего пользователя БД (Вызвать системную функцию или процедуру)
        9. Создать таблицу штрафов (Создать таблицу в базе данных)
        10. Вставить строку в таблицу штрафов (Выполнить вставку данных в созданную таблицу)
        11. Выход
    """)
    com = input()

    try:
        val = int(com)

        if val < 1 or val > 11:
            print("Неверная команда.")
            continue

        if val == 11:
            break
        elif val == 1:
            cars.get_cars_count()
            print(cars.result())
        elif val == 2:
            cars.get_drivers_and_theme_cars()
            print(cars.result())
        elif val == 3:
            cars.get_drivers_and_theme_cars()
            print(cars.result())
        elif val == 4:
            cars.get_drivers_dl_older_theme_cars()
            print(cars.result())
        elif val == 5:
            print("Некоторые модели:")
            cars.get_some_models()
            print(cars.result())
            print("Введите id модели:")
            model = input()
            res = cars.get_car_model_start_year(model)

            if res:
                print(cars.result())
        elif val == 6:
            cars.get_insurances_info_for_cars()
            print(cars.result())
        elif val == 7:
            cars.clear_even_years()
            print(cars.result())
        elif val == 8:
            cars.get_current_user()
            print(cars.result())
        elif val == 9:
            cars.create_table()
        elif val == 10:
            print("Некоторые идентификаторы машин:")
            cars.get_some_cars()
            print(cars.result())
            print("Введите номер машины")
            vin = input()
            print("Введите сумму штрафа:")

            try:
                sum = int(input())
            except:
                print("Некорректная сумма!")
                continue

            res = cars.insert_values(vin, sum)

            if res:
                print(cars.result())

    except:
        print("Неверная команда.")


