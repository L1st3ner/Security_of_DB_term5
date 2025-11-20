# app.py

from flask import Flask, render_template, request, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
# Импортируем Flask-Login
from flask_login import LoginManager, login_user, login_required, logout_user, current_user

# Импортируем Base и AppUser из models.py
from models import Base, AppUser

app = Flask(__name__)

# --- Настройки приложения ---
# Устанавливаем SECRET_KEY (важно для Flask-приложений, Flask-Login и т.д.)
# ЗАМЕНИ НА СЛУЧАЙНЫЙ КЛЮЧ В ПРОДАКШЕНЕ!
app.config['SECRET_KEY'] = 'a_very_secret_key_that_should_be_random_and_long_for_production_use'

AVAILABLE_VIEWS = {
    'admin': {
        # Для админа можно перечислить все основные таблицы
        # или просто все модели из models.py, если нужно
        # Пока добавим только представления из ЛР2 для примера
        # Импортируем модели в начале app.py, если ещё не импортированы
        "Анализ продаж по блюдам": "SalesByDishView",
        "Загрузка персонала": "StaffWorkloadView",
        "Популярность блюд": "DishPopularityByCategoryView",
        "Финансовый отчёт": "FinancialSummaryView",
        "Затраты по поставщикам": "IngredientCostsBySupplierView",
        # ... можно добавить и таблицы, например:
        # "Рестораны": "Restaurant",
        # "Сотрудники": "Employee",
        # и т.д.
    },
    'manager': {
        "Анализ продаж по блюдам": "SalesByDishView",
        "Загрузка персонала": "StaffWorkloadView",
        "Популярность блюд": "DishPopularityByCategoryView",
    },
    'accountant': {
        "Финансовый отчёт": "FinancialSummaryView",
        "Затраты по поставщикам": "IngredientCostsBySupplierView",
    }
}

# Устанавливаем строку подключения к БД restaurant_network
# Замени 'postgres' на имя пользователя и пароль к БД, если они отличаются
# Формат: 'postgresql+psycopg2://username:password@host:port/database_name'
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql+psycopg2://postgres:postgres@localhost/restaurant_network'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False # Отключаем отслеживание изменений для производительности

# --- Инициализация расширения SQLAlchemy ---
# Создаём объект db, который будет использоваться для работы с БД
db = SQLAlchemy(app)

# --- Инициализация Flask-Login ---
login_manager = LoginManager()
login_manager.init_app(app)
# Указываем маршрут для перенаправления неавторизованных пользователей
login_manager.login_view = 'login'

# --- Загрузчик пользователя для Flask-Login ---
@login_manager.user_loader
def load_user(user_id):
    # Загружаем пользователя из БД по ID
    # БЫЛО: return AppUser.query.get(int(user_id))
    return db.session.query(AppUser).get(int(user_id)) # <-- ИСПРАВЛЕНО


# app.py
# ... (все импорты, настройки, аутентификация)

# Словарь, сопоставляющий роли с доступными представлениями/таблицами
# Ключ - имя роли, значение - словарь {отображаемое_имя: модель_ORM}
AVAILABLE_VIEWS = {
    'admin': {
        # Для админа можно перечислить все основные таблицы
        # или просто все модели из models.py, если нужно
        # Пока добавим только представления из ЛР2 для примера
        # Импортируем модели в начале app.py, если ещё не импортированы
        "Анализ продаж по блюдам": "SalesByDishView",
        "Загрузка персонала": "StaffWorkloadView",
        "Популярность блюд": "DishPopularityByCategoryView",
        "Финансовый отчёт": "FinancialSummaryView",
        "Затраты по поставщикам": "IngredientCostsBySupplierView",
        # ... можно добавить и таблицы, например:
        # "Рестораны": "Restaurant",
        # "Сотрудники": "Employee",
        # и т.д.
    },
    'manager': {
        "Анализ продаж по блюдам": "SalesByDishView",
        "Загрузка персонала": "StaffWorkloadView",
        "Популярность блюд": "DishPopularityByCategoryView",
    },
    'accountant': {
        "Финансовый отчёт": "FinancialSummaryView",
        "Затраты по поставщикам": "IngredientCostsBySupplierView",
    }
}


@app.route('/', methods=['GET', 'POST'])
@login_required # Защищаем главную страницу
def index():
    user_role = current_user.role
    username = current_user.username

    # Получаем доступные представления для роли пользователя
    available_views = AVAILABLE_VIEWS.get(user_role, {})

    # Проверяем, был ли отправлен POST-запрос (пользователь выбрал представление/сортировку)
    selected_view_name = request.form.get('view_select') # Имя, выбранное в выпадающем списке
    sort_by = request.form.get('sort_by') # Имя столбца для сортировки
    order = request.form.get('order', 'asc') # Порядок: asc (по возрастанию) или desc (по убыванию)

    # Инициализируем переменные для передачи в шаблон
    results = None
    results_as_dicts = [] # Список словарей для передачи в шаблон
    view_columns = [] # Список имён столбцов для отображения в форме сортировки
    selected_view_display_name = None # Отображаемое имя выбранного представления

    if selected_view_name:
        # Проверяем, есть ли выбранное представление в списке доступных для роли
        if selected_view_name in available_views.values():
            # Получаем ORM-модель по её имени
            # Это немного хитрый способ получить класс из модуля по строке имени
            # Импортируем модуль models
            import models
            ModelClass = getattr(models, selected_view_name, None)

            if ModelClass: # Если модель найдена
                selected_view_display_name = [k for k, v in available_views.items() if v == selected_view_name][0]
                # Формируем запрос
                query = db.session.query(ModelClass)

                # Применяем сортировку, если указана
                if sort_by:
                    # Получаем атрибут (столбец) модели для сортировки
                    column_attr = getattr(ModelClass, sort_by, None)
                    if column_attr:
                        if order == 'desc':
                            query = query.order_by(column_attr.desc())
                        else: # order == 'asc' (или по умолчанию)
                            query = query.order_by(column_attr.asc())
                    else:
                        # Обработка ошибки: столбец сортировки не найден
                        flash(f'Столбец сортировки "{sort_by}" не найден в представлении "{selected_view_display_name}".', 'error')
                        # Можно вернуться к отображению формы выбора
                        sort_by = None # Сбросим сортировку
                        query = db.session.query(ModelClass) # Новый запрос без сортировки

                # Выполняем запрос
                results = query.all()

                # --- НОВЫЙ КОД: Преобразование объектов ORM в словари ---
                if results:
                    # Получаем имена столбцов из самой модели
                    view_columns = list(ModelClass.__table__.columns.keys())
                    # Преобразуем каждый объект в словарь
                    results_as_dicts = []
                    for row in results:
                        row_dict = {}
                        for col in view_columns:
                            row_dict[col] = getattr(row, col)
                        results_as_dicts.append(row_dict)
                # --- КОНЕЦ НОВОГО КОДА ---

            else:
                # Обработка ошибки: модель не найдена
                flash(f'Модель для представления "{selected_view_name}" не найдена.', 'error')
        else:
            # Обработка ошибки: представление не доступно для роли
            flash(f'Представление "{selected_view_name}" не доступно для вашей роли.', 'error')

    # Передаём данные в шаблон
    # Передаём results_as_dicts вместо results
    return render_template('index.html',
                           username=username,
                           user_role=user_role,
                           available_views=available_views,
                           selected_view_name=selected_view_name,
                           selected_view_display_name=selected_view_display_name,
                           results=results_as_dicts, # <-- ПЕРЕДАЁМ СЛОВАРИ
                           view_columns=view_columns,
                           sort_by=sort_by,
                           order=order
                           )



@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        # Ищем пользователя в БД по имени
        user = db.session.query(AppUser).filter_by(username=username).first()

        # Проверяем, существует ли пользователь и совпадает ли пароль
        if user and user.check_password(password): # используем метод из models.py
            login_user(user) # Логиним пользователя через Flask-Login
            flash('Успешный вход!', 'success')
            # После успешного входа перенаправляем на главную страницу
            return redirect(url_for('index'))
        else:
            flash('Неверное имя пользователя или пароль.', 'error')
            # Возвращаем шаблон login.html с сообщением об ошибке
            return render_template('login.html')

    # Если GET-запрос, отображаем форму входа из шаблона
    return render_template('login.html')

@app.route('/logout')
@login_required # Можно выйти только если вошёл
def logout():
    logout_user() # Выходим через Flask-Login
    # flash('Вы вышли из системы.', 'info') # Опционально
    return redirect(url_for('login')) # Перенаправляем на страницу входа


if __name__ == '__main__':
    # Создаём контекст приложения
    with app.app_context():
        # Инициализируем Base с db.engine (необязательно, но явно)
        Base.metadata.bind = db.engine
        # Создаём все таблицы, определённые в Base (из models.py), если они не существуют
        # Это включает AppUser, так как она определена в models.py и наследуется от Base
        Base.metadata.create_all(bind=db.engine)
        print("Таблицы из models.py (включая app_users) проверены/созданы.")

        # --- Создание тестовых пользователей приложения ---
        # Проверим, существуют ли уже пользователи
        # БЫЛО: if not AppUser.query.first():
        if not db.session.query(AppUser).first(): # <-- ИСПРАВЛЕНО
            print("Создаю тестовых пользователей приложения...")

            # Создаём пользователя-менеджера
            manager_user = AppUser(username='manager_user', role='manager')
            manager_user.set_password('manager_password') # set_password определена в models.py

            # Создаём пользователя-бухгалтера
            accountant_user = AppUser(username='accountant_user', role='accountant')
            accountant_user.set_password('accountant_password') # set_password определена в models.py

            # Создаём пользователя-администратора
            admin_user = AppUser(username='admin_user', role='admin')
            admin_user.set_password('admin_password') # set_password определена в models.py

            db.session.add(manager_user)
            db.session.add(accountant_user)
            db.session.add(admin_user)
            db.session.commit()
            print("Тестовые пользователи созданы: manager_user (pass: manager_password), accountant_user (pass: accountant_password), admin_user (pass: admin_password)")
        else:
            print("Пользователи приложения уже существуют.")

    app.run(debug=True)
