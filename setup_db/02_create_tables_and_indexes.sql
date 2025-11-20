-- Справочники
CREATE TABLE IF NOT EXISTS Restaurants (
    restaurant_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL UNIQUE,
    phone VARCHAR(20),
    opening_hours VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS DishCategories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Suppliers (
    supplier_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    contract_start DATE
);

CREATE TABLE IF NOT EXISTS Ingredients (
    ingredient_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    unit VARCHAR(20) NOT NULL,
    storage_condition TEXT,
    cost_per_unit NUMERIC(10,2) NOT NULL CHECK (cost_per_unit >= 0),
    supplier_id INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS Dishes (
    dish_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    category_id INTEGER NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    cooking_time_minutes INTEGER CHECK (cooking_time_minutes >= 0),
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Employees (
    employee_id SERIAL PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    phone VARCHAR(20),
    email VARCHAR(100),
    salary NUMERIC(10,2) CHECK (salary >= 0),
    restaurant_id INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS Orders (
    order_id SERIAL PRIMARY KEY,
    restaurant_id INTEGER NOT NULL,
    waiter_id INTEGER NOT NULL,
    order_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    table_number INTEGER,
    order_type VARCHAR(20) NOT NULL CHECK (order_type IN ('dine-in', 'takeaway', 'delivery')),
    total_amount NUMERIC(10,2) DEFAULT 0 CHECK (total_amount >= 0),
    status VARCHAR(20) NOT NULL CHECK (status IN ('accepted', 'preparing', 'served', 'paid', 'cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Связи многие-ко-многим
CREATE TABLE IF NOT EXISTS Order_Composition (
    order_id INTEGER NOT NULL,
    dish_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (order_id, dish_id)
);

CREATE TABLE IF NOT EXISTS Recipes (
    dish_id INTEGER NOT NULL,
    ingredient_id INTEGER NOT NULL,
    quantity_required NUMERIC(10,3) NOT NULL CHECK (quantity_required > 0),
    is_optional BOOLEAN DEFAULT false,
    PRIMARY KEY (dish_id, ingredient_id)
);

-- Dishes → DishCategories
ALTER TABLE IF EXISTS Dishes
ADD CONSTRAINT fk_dish_category
FOREIGN KEY (category_id) REFERENCES DishCategories(category_id) ON DELETE RESTRICT;

-- Ingredients → Suppliers
ALTER TABLE IF EXISTS Ingredients
ADD CONSTRAINT fk_ingredient_supplier
FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id) ON DELETE RESTRICT;

-- Employees → Restaurants
ALTER TABLE IF EXISTS Employees
ADD CONSTRAINT fk_employee_restaurant
FOREIGN KEY (restaurant_id) REFERENCES Restaurants(restaurant_id) ON DELETE CASCADE;

-- Orders → Restaurants
ALTER TABLE IF EXISTS Orders
ADD CONSTRAINT fk_order_restaurant
FOREIGN KEY (restaurant_id) REFERENCES Restaurants(restaurant_id) ON DELETE CASCADE;

-- Orders → Employees (waiter)
ALTER TABLE IF EXISTS Orders
ADD CONSTRAINT fk_order_waiter
FOREIGN KEY (waiter_id) REFERENCES Employees(employee_id) ON DELETE RESTRICT;

-- Order_Composition → Orders & Dishes
ALTER TABLE IF EXISTS Order_Composition
ADD CONSTRAINT fk_ordercomp_order
FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE;

ALTER TABLE IF EXISTS Order_Composition
ADD CONSTRAINT fk_ordercomp_dish
FOREIGN KEY (dish_id) REFERENCES Dishes(dish_id) ON DELETE RESTRICT;

-- Recipes → Dishes & Ingredients
ALTER TABLE IF EXISTS Recipes
ADD CONSTRAINT fk_recipe_dish
FOREIGN KEY (dish_id) REFERENCES Dishes(dish_id) ON DELETE CASCADE;

ALTER TABLE IF EXISTS Recipes
ADD CONSTRAINT fk_recipe_ingredient
FOREIGN KEY (ingredient_id) REFERENCES Ingredients(ingredient_id) ON DELETE RESTRICT;

CREATE INDEX IF NOT EXISTS idx_orders_time_restaurant ON Orders (order_time, restaurant_id);
CREATE INDEX IF NOT EXISTS idx_ordercomp_dish ON Order_Composition (dish_id);
CREATE INDEX IF NOT EXISTS idx_recipes_ingredient ON Recipes (ingredient_id);
CREATE INDEX IF NOT EXISTS idx_dishes_available ON Dishes (is_available);
CREATE INDEX IF NOT EXISTS idx_employees_restaurant ON Employees (restaurant_id);