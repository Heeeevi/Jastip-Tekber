-- Seed minimal realistic data for testing
-- Assumes SCHEMA_V1.sql has been applied

-- 1) Create two users in auth first (via app Sign Up or Supabase Auth UI/API).
-- This seed will LOOK UP their IDs from auth.users by email to avoid FK errors.
-- If you had legacy users before adding handle_new_user trigger, run:
--   SELECT auth.uid(); -- ensure logged in via client
-- And from client call RPC ensure_profile() for each logged-in user missing a profile.
-- (Implemented in SupabaseService._ensureProfileExists())

-- Diagnostics: show whether the two users exist in auth.users
SELECT email, id FROM auth.users WHERE email IN ('buyer@example.com', 'seller@example.com');
-- If this returns 0 rows, create users first; the subsequent inserts will be no-ops.

-- 2) Ensure profiles exist (trigger usually creates them). Upsert to be safe.
INSERT INTO public.profiles (id, email, full_name, phone, dom_block, room_number)
SELECT u.id, u.email, 'Buyer One', NULL, 'A', '101'
FROM auth.users u
WHERE u.email = 'buyer@example.com'
ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name;

INSERT INTO public.profiles (id, email, full_name, phone, dom_block, room_number)
SELECT u.id, u.email, 'Seller Two', NULL, 'B', '202'
FROM auth.users u
WHERE u.email = 'seller@example.com'
ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name;

-- Diagnostics: verify profiles created/upserted
SELECT id, email, full_name FROM public.profiles WHERE email IN ('buyer@example.com', 'seller@example.com');

-- 3) Create seller tied to seller profile
INSERT INTO public.sellers (id, display_name, block, description, delivery_time, is_online, rating, total_orders)
SELECT u.id, 'Bakso Keputih', 'B', 'Bakso enak', '18:00 - 19:00', true, 4.8, 15
FROM auth.users u
WHERE u.email = 'seller@example.com'
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, block = EXCLUDED.block;

-- Diagnostics: verify seller row
SELECT id, display_name, block FROM public.sellers WHERE id IN (SELECT id FROM auth.users WHERE email = 'seller@example.com');

-- 4) Create products for the seller
INSERT INTO public.products (seller_id, name, price, description, category, image_url, keywords, is_available, status)
SELECT u.id, 'Bakso Urat', 20000, 'Bakso urat ukuran besar', 'Fast Food', NULL, 'bakso;urat', true, 'active'
FROM auth.users u WHERE u.email = 'seller@example.com';

INSERT INTO public.products (seller_id, name, price, description, category, image_url, keywords, is_available, status)
SELECT u.id, 'Es Teh', 5000, 'Es teh manis', 'Drinks', NULL, 'es;teh', true, 'active'
FROM auth.users u WHERE u.email = 'seller@example.com';

-- Diagnostics: verify products
SELECT name, price FROM public.products WHERE seller_id IN (SELECT id FROM auth.users WHERE email = 'seller@example.com');

-- 5) Create a favorites link (buyer favoriting seller)
INSERT INTO public.favorites (user_id, seller_id)
SELECT buyer.id, seller.id
FROM auth.users buyer, auth.users seller
WHERE buyer.email = 'buyer@example.com' AND seller.email = 'seller@example.com'
ON CONFLICT DO NOTHING;

-- Diagnostics: verify favorites
SELECT user_id, seller_id FROM public.favorites WHERE user_id IN (SELECT id FROM auth.users WHERE email = 'buyer@example.com');

-- 6) Create a conversation between buyer and seller
WITH ids AS (
  SELECT buyer.id AS buyer_id, seller.id AS seller_id
  FROM auth.users buyer, auth.users seller
  WHERE buyer.email = 'buyer@example.com' AND seller.email = 'seller@example.com'
)
INSERT INTO public.conversations (participant_1_id, participant_2_id, last_message, last_message_at)
SELECT buyer_id, seller_id, 'Halo kak, pesan bakso ya', now() FROM ids
RETURNING id;

-- Diagnostics: verify conversation
SELECT id, participant_1_id, participant_2_id, last_message FROM public.conversations
WHERE participant_1_id IN (SELECT id FROM auth.users WHERE email = 'buyer@example.com')
   OR participant_2_id IN (SELECT id FROM auth.users WHERE email = 'buyer@example.com')
ORDER BY id DESC LIMIT 5;

-- 7) Add messages in that conversation (use actual conversation id returned above if needed)
-- Insert messages using looked-up IDs and last inserted conversation
WITH ids AS (
  SELECT buyer.id AS buyer_id, seller.id AS seller_id
  FROM auth.users buyer, auth.users seller
  WHERE buyer.email = 'buyer@example.com' AND seller.email = 'seller@example.com'
), conv AS (
  SELECT c.id AS conversation_id
  FROM public.conversations c
  JOIN ids ON (c.participant_1_id = ids.buyer_id AND c.participant_2_id = ids.seller_id)
     OR (c.participant_1_id = ids.seller_id AND c.participant_2_id = ids.buyer_id)
  ORDER BY c.id DESC LIMIT 1
)
INSERT INTO public.messages (conversation_id, sender_id, recipient_id, content, message_type, is_read)
SELECT conv.conversation_id, ids.buyer_id, ids.seller_id, 'Halo kak, pesan bakso ya', 'text', false FROM ids, conv;

WITH ids AS (
  SELECT buyer.id AS buyer_id, seller.id AS seller_id
  FROM auth.users buyer, auth.users seller
  WHERE buyer.email = 'buyer@example.com' AND seller.email = 'seller@example.com'
), conv AS (
  SELECT c.id AS conversation_id
  FROM public.conversations c
  JOIN ids ON (c.participant_1_id = ids.buyer_id AND c.participant_2_id = ids.seller_id)
     OR (c.participant_1_id = ids.seller_id AND c.participant_2_id = ids.buyer_id)
  ORDER BY c.id DESC LIMIT 1
)
INSERT INTO public.messages (conversation_id, sender_id, recipient_id, content, message_type, is_read)
SELECT conv.conversation_id, ids.seller_id, ids.buyer_id, 'Siap, berapa porsi?', 'text', false FROM ids, conv;

-- Diagnostics: verify messages
SELECT conversation_id, sender_id, recipient_id, content FROM public.messages
WHERE conversation_id IN (
  SELECT c.id FROM public.conversations c
  WHERE c.participant_1_id IN (SELECT id FROM auth.users WHERE email = 'buyer@example.com')
     OR c.participant_2_id IN (SELECT id FROM auth.users WHERE email = 'buyer@example.com')
)
ORDER BY id DESC LIMIT 5;

-- 8) Create an order and items for buyer with the seller
-- First, get the product IDs created above (e.g., Bakso Urat id = 1, Es Teh id = 2)
WITH ids AS (
  SELECT buyer.id AS buyer_id, seller.id AS seller_id
  FROM auth.users buyer, auth.users seller
  WHERE buyer.email = 'buyer@example.com' AND seller.email = 'seller@example.com'
)
INSERT INTO public.orders (buyer_id, seller_id, total_price, delivery_fee, delivery_address, status, notes)
SELECT ids.buyer_id, ids.seller_id, 25000, 0, 'Kost A-101', 'pending', 'Tanpa sambal'
FROM ids
RETURNING id;

-- Diagnostics: verify orders
SELECT id, buyer_id, seller_id, total_price, status FROM public.orders
WHERE buyer_id IN (SELECT id FROM auth.users WHERE email = 'buyer@example.com')
ORDER BY id DESC LIMIT 5;

-- Insert order items using looked-up product IDs and last inserted order
WITH prods AS (
  SELECT p.id AS bakso_id
  FROM public.products p
  JOIN auth.users u ON p.seller_id = u.id
  WHERE u.email = 'seller@example.com' AND p.name = 'Bakso Urat'
), prods2 AS (
  SELECT p.id AS esteh_id
  FROM public.products p
  JOIN auth.users u ON p.seller_id = u.id
  WHERE u.email = 'seller@example.com' AND p.name = 'Es Teh'
), ord AS (
  SELECT o.id AS order_id
  FROM public.orders o
  JOIN auth.users buyer ON o.buyer_id = buyer.id
  JOIN auth.users seller ON o.seller_id = seller.id
  WHERE buyer.email = 'buyer@example.com' AND seller.email = 'seller@example.com'
  ORDER BY o.id DESC LIMIT 1
)
INSERT INTO public.order_items (order_id, product_id, quantity, price)
SELECT ord.order_id, prods.bakso_id, 1, 20000 FROM ord, prods;

WITH prods AS (
  SELECT p.id AS esteh_id
  FROM public.products p
  JOIN auth.users u ON p.seller_id = u.id
  WHERE u.email = 'seller@example.com' AND p.name = 'Es Teh'
), ord AS (
  SELECT o.id AS order_id
  FROM public.orders o
  JOIN auth.users buyer ON o.buyer_id = buyer.id
  JOIN auth.users seller ON o.seller_id = seller.id
  WHERE buyer.email = 'buyer@example.com' AND seller.email = 'seller@example.com'
  ORDER BY o.id DESC LIMIT 1
)
INSERT INTO public.order_items (order_id, product_id, quantity, price)
SELECT ord.order_id, prods.esteh_id, 1, 5000 FROM ord, prods;

-- Diagnostics: verify order items
SELECT order_id, product_id, quantity, price FROM public.order_items
WHERE order_id IN (
  SELECT o.id FROM public.orders o
  WHERE o.buyer_id IN (SELECT id FROM auth.users WHERE email = 'buyer@example.com')
)
ORDER BY id DESC LIMIT 10;

-- 9) Notifications example
-- Insert notification for buyer by looking up profile/user ID
INSERT INTO public.notifications (user_id, title, body)
SELECT p.id, 'Order confirmed', 'Pesanan bakso Anda telah dikonfirmasi'
FROM public.profiles p
JOIN auth.users u ON u.id = p.id
WHERE u.email = 'buyer@example.com';

-- Diagnostics: verify notifications
SELECT user_id, title, body, is_read FROM public.notifications
WHERE user_id IN (SELECT id FROM auth.users WHERE email = 'buyer@example.com')
ORDER BY id DESC LIMIT 5;

-- 10) Add more sellers and products for testing
-- Create additional test seller (seller3@example.com) if user exists
INSERT INTO public.profiles (id, email, full_name, phone, dom_block, room_number)
SELECT u.id, u.email, 'Seller Three', NULL, 'C', '303'
FROM auth.users u
WHERE u.email = 'seller3@example.com'
ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name;

INSERT INTO public.sellers (id, display_name, block, description, delivery_time, is_online, rating, total_orders)
SELECT u.id, 'Nasi Goreng Pak Joko', 'C', 'Nasi goreng spesial', '19:00 - 21:00', true, 4.5, 25
FROM auth.users u
WHERE u.email = 'seller3@example.com'
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, block = EXCLUDED.block;

-- Products for seller3
INSERT INTO public.products (seller_id, name, price, description, category, image_url, keywords, is_available, status)
SELECT u.id, 'Nasi Goreng Special', 18000, 'Nasi goreng dengan telur dan ayam', 'Fast Food', NULL, 'nasi;goreng', true, 'active'
FROM auth.users u WHERE u.email = 'seller3@example.com';

INSERT INTO public.products (seller_id, name, price, description, category, image_url, keywords, is_available, status)
SELECT u.id, 'Mie Goreng', 15000, 'Mie goreng pedas', 'Noodles', NULL, 'mie;goreng;pedas', true, 'active'
FROM auth.users u WHERE u.email = 'seller3@example.com';

INSERT INTO public.products (seller_id, name, price, description, category, image_url, keywords, is_available, status)
SELECT u.id, 'Es Jeruk', 7000, 'Es jeruk segar', 'Drinks', NULL, 'es;jeruk;fresh', true, 'active'
FROM auth.users u WHERE u.email = 'seller3@example.com';

-- Create additional test seller (seller4@example.com) if user exists
INSERT INTO public.profiles (id, email, full_name, phone, dom_block, room_number)
SELECT u.id, u.email, 'Seller Four', NULL, 'D', '404'
FROM auth.users u
WHERE u.email = 'seller4@example.com'
ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name;

INSERT INTO public.sellers (id, display_name, block, description, delivery_time, is_online, rating, total_orders)
SELECT u.id, 'Dessert Paradise', 'D', 'Aneka dessert enak', '15:00 - 22:00', true, 4.9, 30
FROM auth.users u
WHERE u.email = 'seller4@example.com'
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, block = EXCLUDED.block;

-- Products for seller4
INSERT INTO public.products (seller_id, name, price, description, category, image_url, keywords, is_available, status)
SELECT u.id, 'Brownies Coklat', 12000, 'Brownies coklat lembut', 'Desserts', NULL, 'brownies;chocolate', true, 'active'
FROM auth.users u WHERE u.email = 'seller4@example.com';

INSERT INTO public.products (seller_id, name, price, description, category, image_url, keywords, is_available, status)
SELECT u.id, 'Es Krim Vanilla', 10000, 'Es krim vanilla premium', 'Desserts', NULL, 'ice;cream;vanilla', true, 'active'
FROM auth.users u WHERE u.email = 'seller4@example.com';

INSERT INTO public.products (seller_id, name, price, description, category, image_url, keywords, is_available, status)
SELECT u.id, 'Pudding Coklat', 8000, 'Pudding coklat lembut', 'Desserts', NULL, 'pudding;chocolate', true, 'active'
FROM auth.users u WHERE u.email = 'seller4@example.com';

-- Final diagnostic: show all sellers and product counts
SELECT 
  s.display_name, 
  s.block, 
  s.rating,
  s.is_online,
  COUNT(p.id) as product_count
FROM public.sellers s
LEFT JOIN public.products p ON s.id = p.seller_id
GROUP BY s.id, s.display_name, s.block, s.rating, s.is_online
ORDER BY s.display_name;
