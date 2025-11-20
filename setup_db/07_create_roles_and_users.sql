-- Создание групп
CREATE ROLE group_manager_service
WITH NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT;

CREATE ROLE group_accountant_service
WITH NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT;

-- Создание пользователей
CREATE ROLE user_manager_01
WITH LOGIN PASSWORD'password_for_user_manager_01' NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT;

CREATE ROLE user_accountant_01
WITH LOGIN PASSWORD'password_for_user_accountant_01' NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT;

-- Привязка пользователей к группам
GRANT group_manager_service TO user_manager_01;
GRANT group_accountant_service TO user_accountant_01;

-- Выдача прав группе менеджеров
GRANT USAGE ON SCHEMA public TO group_manager_service;

GRANT SELECT, INSERT, UPDATE, DELETE ON public.restaurants TO group_manager_service;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.dishcategories TO group_manager_service;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.suppliers TO group_manager_service;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.ingredients TO group_manager_service;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.dishes TO group_manager_service;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.employees TO group_manager_service;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.orders TO group_manager_service;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.order_composition TO group_manager_service;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.recipes TO group_manager_service;

GRANT SELECT ON public.sales_by_dish TO group_manager_service;
GRANT SELECT ON public.staff_workload TO group_manager_service;
GRANT SELECT ON public.dish_popularity_by_category TO group_manager_service;

-- Выдача прав группе бухгалтеров
GRANT USAGE ON SCHEMA public TO group_accountant_service;

GRANT SELECT ON public.restaurants TO group_accountant_service;
GRANT SELECT ON public.dishcategories TO group_accountant_service;
GRANT SELECT ON public.suppliers TO group_accountant_service;
GRANT SELECT ON public.ingredients TO group_accountant_service;
GRANT SELECT ON public.dishes TO group_accountant_service;
GRANT SELECT ON public.employees TO group_accountant_service;
GRANT SELECT ON public.orders TO group_accountant_service;
GRANT SELECT ON public.order_composition TO group_accountant_service;
GRANT SELECT ON public.recipes TO group_accountant_service;

GRANT SELECT ON public.financial_summary TO group_accountant_service;
GRANT SELECT ON public.ingredient_costs_by_supplier TO group_accountant_service;