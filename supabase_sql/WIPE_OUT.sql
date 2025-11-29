-- DANGER: This will drop your app tables, policies, triggers, and helper functions in the public schema.
-- It will NOT touch auth.*, storage.*, or realtime.* objects.
-- Run in Supabase SQL Editor for your project. Irreversible.

-- 1) Drop triggers on auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 2) Drop table-level triggers that depend on public.set_updated_at
DROP TRIGGER IF EXISTS trg_profiles_updated_at ON public.profiles;
DROP TRIGGER IF EXISTS trg_sellers_updated_at ON public.sellers;
DROP TRIGGER IF EXISTS trg_products_updated_at ON public.products;
DROP TRIGGER IF EXISTS trg_orders_updated_at ON public.orders;

-- 3) Drop all app tables (order chosen bottom-up; CASCADE handles deps)
DROP TABLE IF EXISTS public.typing_indicators CASCADE;
DROP TABLE IF EXISTS public.notifications CASCADE;
DROP TABLE IF EXISTS public.favorites CASCADE;
DROP TABLE IF EXISTS public.order_items CASCADE;
DROP TABLE IF EXISTS public.orders CASCADE;
DROP TABLE IF EXISTS public.messages CASCADE;
DROP TABLE IF EXISTS public.conversations CASCADE;
DROP TABLE IF EXISTS public.products CASCADE;
DROP TABLE IF EXISTS public.sellers CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- 4) Drop helper/trigger functions (now that dependent triggers/tables are gone)
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP FUNCTION IF EXISTS public.set_updated_at();

-- Optional: confirm cleanup
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
