-- Заполнение таблиц данными
-- Restaurants
INSERT INTO Restaurants(name, address, phone, opening_hours) VALUES
('La Trattoria','Nevsky 10, SPb','+78121112233','10:00-23:00'),
('Sushi Palace','Liteyny 25, SPb','+78124445566','11:00-22:00'),
('Burger House','Vasilievsky 5, SPb','+78127778899','09:00-21:00'),
('Pizza Express','Moskovsky 50, SPb','+78122223344','10:00-24:00'),
('Green Garden','Petrogradka 12, SPb','+78125556677','08:00-20:00'),
('Steak& Co','Admiralteyskaya 8, SPb','+78128889900','12:00-23:00'),
('Cafe Bistro','Sadovaya 30, SPb','+78123334455','07:00-19:00'),
('Dessert Lab','Kazanskaya 15, SPb','+78126667788','10:00-22:00');

-- DishCategories
INSERT INTO DishCategories(name, description) VALUES
('Appetizers','Cold and hot starters'),
('Main Courses','Hearty dishes'),
('Desserts','Sweet treats'),
('Drinks','Non-alcoholic and alcoholic beverages'),
('Salads','Fresh vegetable combinations'),
('Soups','Hot soups'),
('Snacks','Light bites'),
('Specials','Chef recommendations');

-- Suppliers
INSERT INTO Suppliers(company_name, contact_person, phone, email, contract_start) VALUES
('FreshVeg Ltd','Ivanov A.','+79001112233','ivanov@freshveg.ru', '2023-01-15'),
('MeatMaster','Petrov B.','+79004445566','petrov@meatmaster.ru', '2023-02-01'),
('BakeryPro','Sidorov C.','+79007778899','sidorov@bakerypro.ru', '2023-03-10'),
('SeaDelight','Kuznetsov D.','+79002223344','kuznetsov@seadelight.ru', '2023-04-05'),
('SpiceWorld','Morozova E.','+79005556677','morozova@spiceworld.ru', '2023-05-20'),
('DairyFarm','Popov F.','+79008889900','popov@dairyfarm.ru', '2023-06-12'),
('Organic Greens','Lebedeva G.','+79003334455', 'lebedeva@organicgreens.ru','2023-07-01'),
('SweetSupply','Volkov H.','+79006667788','volkov@sweetsupply.ru', '2023-08-18');

-- Ingredients(с cost_per_unit)
INSERT INTO Ingredients(name, unit, storage_condition, cost_per_unit, supplier_id) VALUES
('Romaine Lettuce','kg','2-4°C', 200.00, 1),
('Beef Fillet','kg','-18°C', 1200.00, 2),
('Cocoa Powder','kg','dry, 15-20°C', 300.00, 8),
('Green Tea Leaves','g','dry, sealed', 500.00, 5),
('Tomatoes','kg','5-10°C', 100.00, 1),
('Beef Patty','piece','-18°C', 250.00, 2),
('Mango Puree','kg','-5°C', 400.00, 1),
('Garlic','kg','dry, cool', 80.00, 7);

-- Dishes
INSERT INTO Dishes(name, category_id, price, cooking_time_minutes, is_available) VALUES
('Caesar Salad', 5, 350.00, 10, true),
('Beef Steak', 2, 850.00, 25, true),
('Chocolate Cake', 3, 280.00, 15, true),
('Green Tea', 4, 120.00, 2, true),
('Tomato Soup', 6, 220.00, 12, true),
('Cheeseburger', 2, 450.00, 15, true),
('Mango Smoothie', 4, 200.00, 5, true),
('Garlic Bread', 1, 180.00, 8, true);

-- Employees
INSERT INTO Employees(last_name, first_name, middle_name, position, hire_date, is_active, phone, email, salary, restaurant_id) VALUES
('Smirnov','Alexey','Ivanovich','Waiter','2023-01-10', true, '+79111112233','a.smirnov@rest.ru', 60000, 1),
('Kuznetsova','Maria','Petrovna','Chef','2022-11-05', true, '+79114445566','m.kuznetsova@rest.ru', 90000, 2),
('Ivanov','Dmitry','Sergeevich','Bartender','2023-03-12', true, '+79117778899','d.ivanov@rest.ru', 65000, 3),
('Petrova','Anna','Viktorovna','Waiter','2023-02-20', true, '+79112223344','a.petrova@rest.ru', 60000, 4),
('Sokolov','Andrey','Nikolaevich','Manager','2022-09-01', true, '+79115556677','a.sokolov@rest.ru', 120000, 5),
('Vasilieva','Elena','Dmitrievna','Waiter','2023-04-15', true, '+79118889900','e.vasilieva@rest.ru', 60000, 6),
('Popov','Sergey','Alexandrovich','Chef','2022-12-10', true, '+79113334455','s.popov@rest.ru', 90000, 7),
('Lebedev','Oleg','Igorevich','Waiter','2023-05-01', true, '+79116667788','o.lebedev@rest.ru', 60000, 8);

-- Orders
INSERT INTO Orders(restaurant_id, waiter_id, order_time, table_number, order_type, total_amount, status) VALUES
(1, 1,'2025-10-10 18:30:00', 5,'dine-in', 1200.00,'paid'),
(2, 2,'2025-10-10 19:15:00', NULL,'takeaway', 850.00,'paid'),
(3, 3,'2025-10-10 20:00:00', 3,'dine-in', 650.00,'served'),
(4, 4,'2025-10-10 20:30:00', NULL,'delivery', 450.00,'paid'),
(5, 5,'2025-10-10 21:00:00', 7,'dine-in', 500.00,'preparing'),
(6, 6,'2025-10-10 21:15:00', 2,'dine-in', 1100.00,'accepted'),
(7, 7,'2025-10-10 21:30:00', NULL,'takeaway', 280.00,'paid'),
(8, 8,'2025-10-10 21:45:00', 4,'dine-in', 380.00,'served');

-- Order_Composition
INSERT INTO Order_Composition(order_id, dish_id, quantity) VALUES
(1, 1, 2),(1, 4, 2),
(2, 2, 1),
(3, 6, 1),(3, 7, 1),
(4, 6, 1),
(5, 5, 1),(5, 8, 2),
(6, 2, 1),(6, 3, 1),
(7, 3, 1),
(8, 1, 1),(8, 3, 1);

-- Recipes
INSERT INTO Recipes(dish_id, ingredient_id, quantity_required, is_optional)
VALUES
(1, 1, 0.2, false),-- Caesar Salad → Lettuce
(1, 8, 0.01, false),-- Garlic
(2, 2, 0.3, false),-- Beef Steak → Fillet
(3, 3, 0.05, false),-- Chocolate Cake → Cocoa
(4, 4, 0.005, false),-- Green Tea → Leaves
(5, 5, 0.3, false),-- Tomato Soup → Tomatoes
(6, 6, 1, false), -- Cheeseburger → Patty
(6, 1, 0.1, true), -- Optional lettuce
(7, 7, 0.2, false),-- Mango Smoothie → Puree
(8, 8, 0.02, false);-- Garlic Bread → Garlic