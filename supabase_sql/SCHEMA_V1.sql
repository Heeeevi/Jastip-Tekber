-- App schema setup for JasTip (public schema)
-- Safe to run after WIPE_OUT.sql or on a clean database

-- 0) Extensions (optional)
-- CREATE EXTENSION IF NOT EXISTS pgcrypto;  -- for gen_random_uuid()

-- 1) Profiles
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  email text,
  full_name text,
  phone text,
  dom_block text,
  room_number text,
  avatar_url text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- 2) Sellers (1:1 to profiles)
CREATE TABLE IF NOT EXISTS public.sellers (
  id uuid PRIMARY KEY REFERENCES public.profiles (id) ON DELETE CASCADE,
  display_name text NOT NULL,
  block text,
  description text,
  delivery_time text,
  is_online boolean NOT NULL DEFAULT true,
  delivery_fee numeric(10,2) NOT NULL DEFAULT 0,
  rating numeric(3,2) NOT NULL DEFAULT 0,
  total_orders integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- 3) Products
CREATE TABLE IF NOT EXISTS public.products (
  id bigserial PRIMARY KEY,
  seller_id uuid NOT NULL REFERENCES public.sellers (id) ON DELETE CASCADE,
  name text NOT NULL,
  price numeric(10,2) NOT NULL,
  description text,
  category text,
  image_url text,
  keywords text,
  is_available boolean NOT NULL DEFAULT true,
  status text NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- 4) Conversations
CREATE TABLE IF NOT EXISTS public.conversations (
  id bigserial PRIMARY KEY,
  participant_1_id uuid NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  participant_2_id uuid NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  last_message text,
  last_message_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- 5) Messages
CREATE TABLE IF NOT EXISTS public.messages (
  id bigserial PRIMARY KEY,
  conversation_id bigint NOT NULL REFERENCES public.conversations (id) ON DELETE CASCADE,
  sender_id uuid NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  recipient_id uuid NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  content text NOT NULL,
  message_type text NOT NULL DEFAULT 'text',
  order_id bigint,
  image_url text,
  is_read boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- 6) Orders
CREATE TABLE IF NOT EXISTS public.orders (
  id bigserial PRIMARY KEY,
  buyer_id uuid NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  seller_id uuid NOT NULL REFERENCES public.sellers (id) ON DELETE CASCADE,
  total_price numeric(10,2) NOT NULL,
  delivery_fee numeric(10,2) NOT NULL DEFAULT 0,
  delivery_address text,
  delivery_time text,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending','confirmed','preparing','ready','delivering','completed','cancelled'
  )),
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- 7) Order Items
CREATE TABLE IF NOT EXISTS public.order_items (
  id bigserial PRIMARY KEY,
  order_id bigint NOT NULL REFERENCES public.orders (id) ON DELETE CASCADE,
  product_id bigint REFERENCES public.products (id) ON DELETE SET NULL,
  quantity integer NOT NULL CHECK (quantity > 0),
  price numeric(10,2) NOT NULL
);

-- 8) Favorites
CREATE TABLE IF NOT EXISTS public.favorites (
  id bigserial PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  seller_id uuid NOT NULL REFERENCES public.sellers (id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, seller_id)
);

-- 9) Notifications
CREATE TABLE IF NOT EXISTS public.notifications (
  id bigserial PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  title text NOT NULL,
  body text,
  is_read boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- 10) Typing Indicators
CREATE TABLE IF NOT EXISTS public.typing_indicators (
  id bigserial PRIMARY KEY,
  conversation_id bigint NOT NULL REFERENCES public.conversations (id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  is_typing boolean NOT NULL DEFAULT true,
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_products_seller ON public.products (seller_id);
CREATE INDEX IF NOT EXISTS idx_conversations_p1 ON public.conversations (participant_1_id);
CREATE INDEX IF NOT EXISTS idx_conversations_p2 ON public.conversations (participant_2_id);
CREATE INDEX IF NOT EXISTS idx_messages_conv ON public.messages (conversation_id, created_at);
CREATE INDEX IF NOT EXISTS idx_orders_buyer ON public.orders (buyer_id);
CREATE INDEX IF NOT EXISTS idx_orders_seller ON public.orders (seller_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders (status);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications (user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user ON public.favorites (user_id);
CREATE INDEX IF NOT EXISTS idx_typing_conv ON public.typing_indicators (conversation_id);

-- Helper function: auto-update updated_at
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_profiles_updated_at'
  ) THEN
    CREATE TRIGGER trg_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_sellers_updated_at'
  ) THEN
    CREATE TRIGGER trg_sellers_updated_at
    BEFORE UPDATE ON public.sellers
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_products_updated_at'
  ) THEN
    CREATE TRIGGER trg_products_updated_at
    BEFORE UPDATE ON public.products
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_orders_updated_at'
  ) THEN
    CREATE TRIGGER trg_orders_updated_at
    BEFORE UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- Profile bootstrap on new auth user
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
  v_full_name text;
  v_phone text;
  v_dom_block text;
  v_room_number text;
BEGIN
  v_full_name := COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1));
  v_phone := NEW.raw_user_meta_data->>'phone';
  v_dom_block := NEW.raw_user_meta_data->>'dom_block';
  v_room_number := NEW.raw_user_meta_data->>'room_number';

  INSERT INTO public.profiles (id, email, full_name, phone, dom_block, room_number, avatar_url)
  VALUES (NEW.id, NEW.email, v_full_name, v_phone, v_dom_block, v_room_number, NULL)
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Helper: ensure a profile exists for current auth user (for legacy accounts created before trigger)
CREATE OR REPLACE FUNCTION public.ensure_profile()
RETURNS void
SECURITY DEFINER SET search_path = public AS $$
DECLARE
  uid uuid := auth.uid();
  uemail text;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = uid) THEN
    SELECT email INTO uemail FROM auth.users WHERE id = uid;
    INSERT INTO public.profiles (id, email, full_name)
    VALUES (uid, uemail, COALESCE(split_part(uemail,'@',1),'User'));
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sellers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.typing_indicators ENABLE ROW LEVEL SECURITY;

-- RLS policies (drop-then-create to be re-runnable)
-- Profiles
DROP POLICY IF EXISTS profiles_read ON public.profiles;
CREATE POLICY profiles_read ON public.profiles FOR SELECT USING (true);
DROP POLICY IF EXISTS profiles_update ON public.profiles;
CREATE POLICY profiles_update ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Sellers
DROP POLICY IF EXISTS sellers_read ON public.sellers;
CREATE POLICY sellers_read ON public.sellers FOR SELECT USING (true);
DROP POLICY IF EXISTS sellers_ins ON public.sellers;
CREATE POLICY sellers_ins ON public.sellers FOR INSERT WITH CHECK (auth.uid() = id);
DROP POLICY IF EXISTS sellers_upd ON public.sellers;
CREATE POLICY sellers_upd ON public.sellers FOR UPDATE USING (auth.uid() = id);
DROP POLICY IF EXISTS sellers_del ON public.sellers;
CREATE POLICY sellers_del ON public.sellers FOR DELETE USING (auth.uid() = id);

-- Products
DROP POLICY IF EXISTS products_read ON public.products;
CREATE POLICY products_read ON public.products FOR SELECT USING (true);
DROP POLICY IF EXISTS products_ins ON public.products;
CREATE POLICY products_ins ON public.products FOR INSERT WITH CHECK (auth.uid() = seller_id);
DROP POLICY IF EXISTS products_upd ON public.products;
CREATE POLICY products_upd ON public.products FOR UPDATE USING (auth.uid() = seller_id);
DROP POLICY IF EXISTS products_del ON public.products;
CREATE POLICY products_del ON public.products FOR DELETE USING (auth.uid() = seller_id);

-- Conversations
DROP POLICY IF EXISTS conv_read ON public.conversations;
CREATE POLICY conv_read ON public.conversations FOR SELECT USING (
  auth.uid() = participant_1_id OR auth.uid() = participant_2_id
);
DROP POLICY IF EXISTS conv_ins ON public.conversations;
CREATE POLICY conv_ins ON public.conversations FOR INSERT WITH CHECK (
  auth.uid() = participant_1_id OR auth.uid() = participant_2_id
);

-- Messages
DROP POLICY IF EXISTS msg_read ON public.messages;
CREATE POLICY msg_read ON public.messages FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.conversations c
    WHERE c.id = conversation_id AND (auth.uid() = c.participant_1_id OR auth.uid() = c.participant_2_id)
  )
);
DROP POLICY IF EXISTS msg_ins ON public.messages;
CREATE POLICY msg_ins ON public.messages FOR INSERT WITH CHECK (
  auth.uid() = sender_id AND EXISTS (
    SELECT 1 FROM public.conversations c
    WHERE c.id = conversation_id AND (auth.uid() = c.participant_1_id OR auth.uid() = c.participant_2_id)
  )
);
DROP POLICY IF EXISTS msg_upd_read ON public.messages;
CREATE POLICY msg_upd_read ON public.messages FOR UPDATE USING (auth.uid() = recipient_id);

-- Orders
DROP POLICY IF EXISTS orders_read ON public.orders;
CREATE POLICY orders_read ON public.orders FOR SELECT USING (
  auth.uid() = buyer_id OR auth.uid() = seller_id
);
DROP POLICY IF EXISTS orders_ins ON public.orders;
CREATE POLICY orders_ins ON public.orders FOR INSERT WITH CHECK (auth.uid() = buyer_id);
DROP POLICY IF EXISTS orders_upd_buyer ON public.orders;
CREATE POLICY orders_upd_buyer ON public.orders FOR UPDATE USING (auth.uid() = buyer_id);
DROP POLICY IF EXISTS orders_upd_seller ON public.orders;
CREATE POLICY orders_upd_seller ON public.orders FOR UPDATE USING (auth.uid() = seller_id);

-- Order Items
DROP POLICY IF EXISTS order_items_read ON public.order_items;
CREATE POLICY order_items_read ON public.order_items FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.orders o
    WHERE o.id = order_id AND (auth.uid() = o.buyer_id OR auth.uid() = o.seller_id)
  )
);
DROP POLICY IF EXISTS order_items_ins ON public.order_items;
CREATE POLICY order_items_ins ON public.order_items FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.orders o
    WHERE o.id = order_id AND auth.uid() = o.buyer_id
  )
);

-- Favorites
DROP POLICY IF EXISTS fav_read ON public.favorites;
CREATE POLICY fav_read ON public.favorites FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS fav_ins ON public.favorites;
CREATE POLICY fav_ins ON public.favorites FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS fav_del ON public.favorites;
CREATE POLICY fav_del ON public.favorites FOR DELETE USING (auth.uid() = user_id);

-- Notifications
DROP POLICY IF EXISTS notif_read ON public.notifications;
CREATE POLICY notif_read ON public.notifications FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS notif_upd ON public.notifications;
CREATE POLICY notif_upd ON public.notifications FOR UPDATE USING (auth.uid() = user_id);
DROP POLICY IF EXISTS notif_ins ON public.notifications;
CREATE POLICY notif_ins ON public.notifications FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Typing indicators
DROP POLICY IF EXISTS typing_read ON public.typing_indicators;
CREATE POLICY typing_read ON public.typing_indicators FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.conversations c
    WHERE c.id = conversation_id AND (auth.uid() = c.participant_1_id OR auth.uid() = c.participant_2_id)
  )
);
DROP POLICY IF EXISTS typing_ins ON public.typing_indicators;
CREATE POLICY typing_ins ON public.typing_indicators FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.conversations c
    WHERE c.id = conversation_id AND (auth.uid() = c.participant_1_id OR auth.uid() = c.participant_2_id)
  )
);

-- Optional dev: mark all existing users as confirmed (run once if needed)
-- UPDATE auth.users SET email_confirmed_at = now() WHERE email_confirmed_at IS NULL;

-- ============================
-- NOTES & OPTIONAL DEMO SEED
-- ============================
-- Many tables reference auth.users via FK. You cannot create auth users inside this SQL.
-- Flow:
--   1) Run WIPE_OUT.sql
--   2) Run this SCHEMA_V1.sql
--   3) Create users in Supabase Auth (buyer@example.com, seller@example.com)
--   4) Run SEED_DATA.sql (it looks up auth.users IDs by email) OR import CSVs mapping UUIDs.
--
-- Demo seed (commented). Remove leading -- to enable AFTER creating users in Auth.
-- -- INSERT INTO public.profiles (id, email, full_name)
-- -- SELECT u.id, u.email, 'Buyer One' FROM auth.users u WHERE u.email = 'buyer@example.com'
-- -- ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name;
-- -- INSERT INTO public.profiles (id, email, full_name)
-- -- SELECT u.id, u.email, 'Seller Two' FROM auth.users u WHERE u.email = 'seller@example.com'
-- -- ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name;
-- -- INSERT INTO public.sellers (id, display_name, block, description, delivery_time, is_online, rating, total_orders)
-- -- SELECT u.id, 'Bakso Keputih', 'B', 'Bakso enak', '18:00 - 19:00', true, 4.8, 15 FROM auth.users u WHERE u.email = 'seller@example.com'
-- -- ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, block = EXCLUDED.block;
