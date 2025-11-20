-- Создание представлений
-- Представление 1. «Анализ продаж по блюдам»
CREATE OR REPLACE VIEW sales_by_dish AS
SELECT
    d.name AS dish_name,
    dc.name AS category_name,
    SUM(oc.quantity) AS total_orders,
    SUM(oc.quantity * d.price) AS total_revenue,
    ROUND(AVG(d.price), 2) AS avg_price_per_order
FROM Dishes d
JOIN DishCategories dc ON d.category_id= dc.category_id
JOIN Order_Composition oc ON d.dish_id= oc.dish_id
JOIN Orders o ON oc.order_id= o.order_id
WHERE o.status='paid'
GROUP BY d.dish_id, d.name, dc.name;

-- Представление 2. «Загрузка персонала по времени»
CREATE OR REPLACE VIEW staff_workload AS
SELECT
    e.last_name || ' ' || e.first_name || ' ' || COALESCE(e.middle_name,'') AS full_name,
    e.position,
    r.name AS restaurant_name,
    o.order_time,
    o.order_time+ INTERVAL'1 minute'* SUM(d.cooking_time_minutes) AS estimated_end_time,
    COUNT(o.order_id) OVER(PARTITION BY e.employee_id) AS total_orders_handled
FROM Employees e
JOIN Restaurants r ON e.restaurant_id= r.restaurant_id
JOIN Orders o ON e.employee_id= o.waiter_id
JOIN Order_Composition oc ON o.order_id= oc.order_id
JOIN Dishes d ON oc.dish_id= d.dish_id
WHERE o.status IN('paid','served')
GROUP BY e.employee_id, e.last_name, e.first_name, e.middle_name, e.position, r.name, o.order_id, o.order_time
ORDER BY o.order_time;

-- Представление 3. «Популярность блюд по категориям»
CREATE OR REPLACE VIEW dish_popularity_by_category AS
SELECT
    dc.name AS category_name,
    d.name AS dish_name,
    SUM(oc.quantity) AS total_quantity,
    ROUND(
    100.0* SUM(oc.quantity)/ NULLIF(SUM(SUM(oc.quantity)) OVER(), 0),
    2
    ) AS percentage_of_total
FROM DishCategories dc
JOIN Dishes d ON dc.category_id= d.category_id
JOIN Order_Composition oc ON d.dish_id= oc.dish_id
JOIN Orders o ON oc.order_id= o.order_id
WHERE o.status='paid'
GROUP BY dc.category_id, dc.name, d.dish_id, d.name
ORDER BY dc.name, total_quantity DESC;

-- Представление 1. «Финансовые показатели по ресторанам»
CREATE OR REPLACE VIEW financial_summary AS
SELECT
    r.name AS restaurant_name,
    COALESCE(SUM(o.total_amount), 0) AS total_revenue,
    COALESCE(
    SUM(rcp.quantity_required* ing.cost_per_unit* oc.quantity),
    0
    ) AS total_ingredient_cost,
    COALESCE(
    (SELECT SUM(e.salary) FROM Employees e WHERE e.restaurant_id= r.restaurant_id AND e.is_active), 0
    ) AS total_salary,
    COALESCE(SUM(o.total_amount), 0)-
    COALESCE(SUM(rcp.quantity_required* ing.cost_per_unit* oc.quantity), 0)
    - COALESCE((SELECT SUM(e.salary) FROM Employees e WHERE e.restaurant_id= r.restaurant_id AND e.is_active), 0) AS net_profit
FROM Restaurants r
LEFT JOIN Orders o ON r.restaurant_id= o.restaurant_id AND o.status='paid'
LEFT JOIN Order_Composition oc ON o.order_id= oc.order_id
LEFT JOIN Recipes rcp ON oc.dish_id= rcp.dish_id
LEFT JOIN Ingredients ing ON rcp.ingredient_id= ing.ingredient_id
GROUP BY r.restaurant_id, r.name;

-- Представление 2. «Затраты на ингредиенты по поставщикам»
CREATE OR REPLACE VIEW ingredient_costs_by_supplier AS
SELECT
    s.company_name AS supplier_name,
    i.name AS ingredient_name,
    SUM(rcp.quantity_required* oc.quantity) AS total_used,
    i.cost_per_unit,
    ROUND(SUM(rcp.quantity_required* oc.quantity* i.cost_per_unit), 2) AS total_cost
FROM Suppliers s
JOIN Ingredients i ON s.supplier_id= i.supplier_id
JOIN Recipes rcp ON i.ingredient_id= rcp.ingredient_id
JOIN Order_Composition oc ON rcp.dish_id= oc.dish_id
JOIN Orders o ON oc.order_id= o.order_id AND o.status='paid'
GROUP BY s.supplier_id, s.company_name, i.ingredient_id, i.name, i.cost_per_unit
ORDER BY total_cost DESC;