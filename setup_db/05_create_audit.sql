-- Таблица для мониторинга
CREATE TABLE IF NOT EXISTS public.audit_log(
    log_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    operation_type VARCHAR(10) NOT NULL,
    operation_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    user_role NAME NOT NULL,
    row_id INTEGER,
    old_values JSONB,
    new_values JSONB
);

CREATE INDEX IF NOT EXISTS idx_audit_log_table_time ON public.audit_log (table_name, operation_time);

-- Функция триггера
CREATE OR REPLACE FUNCTION public.log_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path= public
AS $$
DECLARE
    current_role NAME:= current_user;
    row_id_value INTEGER;
BEGIN
    CASE TG_TABLE_NAME
    WHEN 'restaurants' THEN row_id_value:= COALESCE(NEW.restaurant_id, OLD.restaurant_id);
    WHEN 'dishcategories' THEN row_id_value:= COALESCE(NEW.category_id, OLD.category_id);
    WHEN 'suppliers' THEN row_id_value:= COALESCE(NEW.supplier_id, OLD.supplier_id);
    WHEN 'ingredients' THEN row_id_value:= COALESCE(NEW.ingredient_id, OLD.ingredient_id);
    WHEN 'dishes' THEN row_id_value:= COALESCE(NEW.dish_id, OLD.dish_id);
    WHEN 'employees' THEN row_id_value:= COALESCE(NEW.employee_id, OLD.employee_id);
    WHEN 'orders' THEN row_id_value:= COALESCE(NEW.order_id, OLD.order_id);
    WHEN 'order_composition' THEN row_id_value:= COALESCE(NEW.order_id, OLD.order_id);
    WHEN 'recipes' THEN row_id_value:= COALESCE(NEW.dish_id, OLD.dish_id);
    ELSE row_id_value:= NULL;
    END CASE;

    IF TG_OP='INSERT' THEN
        INSERT INTO public.audit_log(table_name, operation_type, user_role, row_id, new_values)
        VALUES(TG_TABLE_NAME, TG_OP, current_role, row_id_value, to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP='UPDATE' THEN
        INSERT INTO public.audit_log(table_name, operation_type, user_role, row_id, old_values, new_values)
        VALUES(TG_TABLE_NAME, TG_OP, current_role, row_id_value, to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP='DELETE' THEN
        INSERT INTO public.audit_log(table_name, operation_type, user_role, row_id, old_values)
        VALUES(TG_TABLE_NAME, TG_OP, current_role, row_id_value, to_jsonb(OLD));
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

-- Триггеры
CREATE TRIGGER restaurants_audit_trg
AFTER INSERT OR UPDATE OR DELETE ON public.restaurants
FOR EACH ROW EXECUTE FUNCTION log_change();

CREATE TRIGGER dishcategories_audit_trg
AFTER INSERT OR UPDATE OR DELETE ON public.dishcategories
FOR EACH ROW EXECUTE FUNCTION log_change();

CREATE TRIGGER suppliers_audit_trg
AFTER INSERT OR UPDATE OR DELETE ON public.suppliers
FOR EACH ROW EXECUTE FUNCTION log_change();

CREATE TRIGGER ingredients_audit_trg
AFTER INSERT OR UPDATE OR DELETE ON public.ingredients
FOR EACH ROW EXECUTE FUNCTION log_change();

CREATE TRIGGER dishes_audit_trg
AFTER INSERT OR UPDATE OR DELETE ON public.dishes
FOR EACH ROW EXECUTE FUNCTION log_change();

CREATE TRIGGER employees_audit_trg
AFTER INSERT OR UPDATE OR DELETE ON public.employees
FOR EACH ROW EXECUTE FUNCTION log_change();

CREATE TRIGGER orders_audit_trg
AFTER INSERT OR UPDATE OR DELETE ON public.orders
FOR EACH ROW EXECUTE FUNCTION log_change();

CREATE TRIGGER order_composition_audit_trg
AFTER INSERT OR UPDATE OR DELETE ON public.order_composition
FOR EACH ROW EXECUTE FUNCTION log_change();

CREATE TRIGGER recipes_audit_trg
AFTER INSERT OR UPDATE OR DELETE ON public.recipes
FOR EACH ROW EXECUTE FUNCTION log_change();