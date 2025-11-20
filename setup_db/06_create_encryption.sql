-- Расширение для шифрования
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Таблица с токенами
CREATE TABLE IF NOT EXISTS public.refresh_tokens(
    token_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    encrypted_token BYTEA NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_expires ON public.refresh_tokens(user_id, expires_at);

-- Заполнение таблицы токенов
DO $$
DECLARE
    key text:= encode(digest('n0_c0ding_plz','sha512'),'hex');
BEGIN
    DELETE FROM public.refresh_tokens;

    INSERT INTO public.refresh_tokens(user_id, encrypted_token, expires_at)
    VALUES
    (1, pgp_sym_encrypt('token_user_1_refresh_abc123xyz', key),'2025-12-01 10:00:00+00'),
    (2, pgp_sym_encrypt('token_user_2_refresh_def456uvw', key),'2025-12-02 10:00:00+00'),
    (3, pgp_sym_encrypt('token_user_3_refresh_ghi789rst', key),'2025-12-03 10:00:00+00'),
    (4, pgp_sym_encrypt('token_user_4_refresh_jkl012opq', key),'2025-12-04 10:00:00+00'),
    (5, pgp_sym_encrypt('token_user_5_refresh_mno345lmn', key),'2025-12-05 10:00:00+00'),
    (6, pgp_sym_encrypt('token_user_6_refresh_pqr678ijk', key),'2025-12-06 10:00:00+00'),
    (7, pgp_sym_encrypt('token_user_7_refresh_stu901fgh', key),'2025-12-07 10:00:00+00'),
    (8, pgp_sym_encrypt('token_user_8_refresh_vwx234efg', key),'2025-12-08 10:00:00+00');
END
$$ LANGUAGE plpgsql;