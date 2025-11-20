# models.py
from sqlalchemy import Column, Integer, String, Numeric, Boolean, DateTime, Date, ForeignKey, Text, LargeBinary
from sqlalchemy.orm import declarative_base, relationship
from flask_login import UserMixin # Импортируем UserMixin для модели пользователя Flask-Login

Base = declarative_base()

# --- Модель пользователя приложения для Flask-Login ---
# Эта таблица будет хранить логины, хэши паролей и роли для *нашего* веб-приложения
class AppUser(Base, UserMixin):
    __tablename__ = 'app_users' # Имя таблицы в БД для пользователей приложения

    id = Column(Integer, primary_key=True)
    username = Column(String(80), unique=True, nullable=False)
    password_hash = Column(String(120), nullable=False)
    role = Column(String(80), nullable=False) # 'admin', 'manager', 'accountant'

    def set_password(self, password):
        """Хеширует пароль и сохраняет хэш."""
        # Используем простой хэш для примера.
        import hashlib
        self.password_hash = hashlib.sha256(password.encode()).hexdigest()

    def check_password(self, password):
        """Проверяет, совпадает ли введённый пароль с хэшем."""
        import hashlib
        return self.password_hash == hashlib.sha256(password.encode()).hexdigest()

# --- Модели для таблиц и представлений из БД restaurant_network ---
# Эти модели описывают структуру существующих таблиц/представлений из ЛР2/ЛР3

# Модель для таблицы Restaurants
class Restaurant(Base):
    __tablename__ = 'restaurants'

    restaurant_id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    address = Column(Text, nullable=False) # TEXT в БД соответствует Text в SQLAlchemy
    phone = Column(String(20))
    opening_hours = Column(String(100))
    created_at = Column(DateTime)

    # Связи
    # employees = relationship("Employee", back_populates="restaurant") 


# Модель для таблицы DishCategories
class DishCategory(Base):
    __tablename__ = 'dishcategories'

    category_id = Column(Integer, primary_key=True)
    name = Column(String(50), nullable=False)
    description = Column(Text)
    created_at = Column(DateTime)


# Модель для таблицы Dishes
class Dish(Base):
    __tablename__ = 'dishes'

    dish_id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    category_id = Column(Integer, ForeignKey('dishcategories.category_id'), nullable=False)
    price = Column(Numeric(10, 2), nullable=False)
    cooking_time_minutes = Column(Integer)
    is_available = Column(Boolean, default=True)
    created_at = Column(DateTime)

    # Связи
    # category = relationship("DishCategory", back_populates="dishes") 
    # recipes = relationship("Recipe", back_populates="dish") 
    # order_compositions = relationship("OrderComposition", back_populates="dish") 


# Модель для таблицы Suppliers
class Supplier(Base):
    __tablename__ = 'suppliers'

    supplier_id = Column(Integer, primary_key=True)
    company_name = Column(String(100), nullable=False)
    contact_person = Column(String(100))
    phone = Column(String(20))
    email = Column(String(100))
    contract_start = Column(Date)


# Модель для таблицы Ingredients
class Ingredient(Base):
    __tablename__ = 'ingredients'

    ingredient_id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    unit = Column(String(20), nullable=False)
    storage_condition = Column(Text)
    cost_per_unit = Column(Numeric(10, 2), nullable=False)
    supplier_id = Column(Integer, ForeignKey('suppliers.supplier_id'), nullable=False)

    # Связи
    # recipes = relationship("Recipe", back_populates="ingredient") 


# Модель для таблицы Employees
class Employee(Base):
    __tablename__ = 'employees'

    employee_id = Column(Integer, primary_key=True)
    last_name = Column(String(50), nullable=False)
    first_name = Column(String(50), nullable=False)
    middle_name = Column(String(50))
    position = Column(String(50), nullable=False)
    hire_date = Column(Date, nullable=False)
    is_active = Column(Boolean, default=True)
    phone = Column(String(20))
    email = Column(String(100))
    salary = Column(Numeric(10, 2))
    restaurant_id = Column(Integer, ForeignKey('restaurants.restaurant_id'), nullable=False)

    # Связи
    # restaurant = relationship("Restaurant", back_populates="employees") 
    # orders_taken = relationship("Order", back_populates="waiter")


# Модель для таблицы Orders
class Order(Base):
    __tablename__ = 'orders'

    order_id = Column(Integer, primary_key=True)
    restaurant_id = Column(Integer, ForeignKey('restaurants.restaurant_id'), nullable=False)
    waiter_id = Column(Integer, ForeignKey('employees.employee_id'), nullable=False) # Предполагается, что это ID сотрудника-официанта
    order_time = Column(DateTime, nullable=False)
    table_number = Column(Integer)
    order_type = Column(String(20)) # CHECK ограничение на уровне БД
    total_amount = Column(Numeric(10, 2), default=0)
    status = Column(String(20)) # CHECK ограничение на уровне БД
    created_at = Column(DateTime)

    # Связи
    # waiter = relationship("Employee", back_populates="orders_taken") 
    # restaurant = relationship("Restaurant") 
    # compositions = relationship("OrderComposition", back_populates="order") 


# Модель для таблицы Order_Composition
class OrderComposition(Base):
    __tablename__ = 'order_composition'

    order_id = Column(Integer, ForeignKey('orders.order_id'), primary_key=True, nullable=False)
    dish_id = Column(Integer, ForeignKey('dishes.dish_id'), primary_key=True, nullable=False)
    quantity = Column(Integer, nullable=False) # CHECK(quantity > 0) на уровне БД

    # Связи
    # order = relationship("Order", back_populates="compositions")
    # dish = relationship("Dish", back_populates="order_compositions") 


# Модель для таблицы Recipes
class Recipe(Base):
    __tablename__ = 'recipes'

    dish_id = Column(Integer, ForeignKey('dishes.dish_id'), primary_key=True, nullable=False)
    ingredient_id = Column(Integer, ForeignKey('ingredients.ingredient_id'), primary_key=True, nullable=False)
    quantity_required = Column(Numeric(10, 3), nullable=False) # CHECK(quantity_required > 0) на уровне БД
    is_optional = Column(Boolean, default=False)

    # Связи
    # dish = relationship("Dish", back_populates="recipes") 
    # ingredient = relationship("Ingredient", back_populates="recipes") 


# Модель для таблицы audit_log (из ЛР3)
class AuditLog(Base):
    __tablename__ = 'audit_log'

    log_id = Column(Integer, primary_key=True)
    table_name = Column(String(50), nullable=False)
    operation_type = Column(String(10), nullable=False)
    operation_time = Column(DateTime) # WITH TIME ZONE в БД
    user_role = Column(String, nullable=False) # NAME в БД соответствует String в SQLAlchemy
    row_id = Column(Integer)
    old_values = Column(Text) # JSONB в БД соответствует Text или JSON 
    new_values = Column(Text) # JSONB в БД соответствует Text или JSON


# Модель для таблицы refresh_tokens (из ЛР3)
class RefreshToken(Base):
    __tablename__ = 'refresh_tokens'

    token_id = Column(Integer, primary_key=True)
    user_id = Column(Integer, nullable=False)
    encrypted_token = Column(LargeBinary, nullable=False) # BYTEA в БД соответствует LargeBinary в SQLAlchemy
    expires_at = Column(DateTime) # WITH TIME ZONE в БД
    created_at = Column(DateTime) # WITH TIME ZONE в БД


# --- Модели для представлений из ЛР2 ---
# Указываем, что это VIEW, а не TABLE 
# Первичный ключ нужен для ORM, хотя в VIEW его может не быть. Используем логически значимое поле или комбинацию.

# Модель для представления sales_by_dish
class SalesByDishView(Base):
    __tablename__ = 'sales_by_dish'
    __table_args__ = {'info': {'is_view': True}}

    dish_name = Column(String, primary_key=True) # Первичный ключ для ORM
    category_name = Column(String)
    total_orders = Column(Integer)
    total_revenue = Column(Numeric(10, 2))
    avg_price_per_order = Column(Numeric(10, 2))


# Модель для представления staff_workload
class StaffWorkloadView(Base):
    __tablename__ = 'staff_workload'
    __table_args__ = {'info': {'is_view': True}}

    full_name = Column(String, primary_key=True) # Условный PK
    position = Column(String)
    restaurant_name = Column(String)
    order_time = Column(DateTime)
    estimated_end_time = Column(DateTime)
    total_orders_handled = Column(Integer)


# Модель для представления dish_popularity_by_category
class DishPopularityByCategoryView(Base):
    __tablename__ = 'dish_popularity_by_category'
    __table_args__ = {'info': {'is_view': True}}

    category_name = Column(String, primary_key=True) # Условный PK
    dish_name = Column(String)
    total_quantity = Column(Integer)
    percentage_of_total = Column(Numeric(5, 2)) # Примерный тип для ROUND


# Модель для представления financial_summary
class FinancialSummaryView(Base):
    __tablename__ = 'financial_summary'
    __table_args__ = {'info': {'is_view': True}}

    restaurant_name = Column(String, primary_key=True) # Условный PK
    total_revenue = Column(Numeric(10, 2))
    total_ingredient_cost = Column(Numeric(10, 2))
    total_salary = Column(Numeric(10, 2))
    net_profit = Column(Numeric(10, 2))


# Модель для представления ingredient_costs_by_supplier
class IngredientCostsBySupplierView(Base):
    __tablename__ = 'ingredient_costs_by_supplier'
    __table_args__ = {'info': {'is_view': True}}

    supplier_name = Column(String, primary_key=True) # Условный PK
    ingredient_name = Column(String)
    total_used = Column(Numeric(10, 3))
    cost_per_unit = Column(Numeric(10, 2))
    total_cost = Column(Numeric(10, 2))

