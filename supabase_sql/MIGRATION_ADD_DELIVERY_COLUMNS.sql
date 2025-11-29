-- Migration script: Add delivery-related columns to existing tables
-- Run this if you already have a database and need to add the new columns

-- 1. Add delivery_fee and rating to sellers table (if not exists)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'sellers' 
    AND column_name = 'delivery_fee'
  ) THEN
    ALTER TABLE public.sellers ADD COLUMN delivery_fee numeric(10,2) NOT NULL DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'sellers' 
    AND column_name = 'rating'
  ) THEN
    ALTER TABLE public.sellers ADD COLUMN rating numeric(3,2) NOT NULL DEFAULT 0;
  END IF;
END $$;

-- 2. Add delivery_fee, delivery_time, and delivery_address to orders table (if not exists)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'orders' 
    AND column_name = 'delivery_fee'
  ) THEN
    ALTER TABLE public.orders ADD COLUMN delivery_fee numeric(10,2) NOT NULL DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'orders' 
    AND column_name = 'delivery_time'
  ) THEN
    ALTER TABLE public.orders ADD COLUMN delivery_time text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'orders' 
    AND column_name = 'delivery_address'
  ) THEN
    ALTER TABLE public.orders ADD COLUMN delivery_address text;
  END IF;
END $$;

-- 3. Refresh PostgREST schema cache (important!)
-- This ensures PostgREST recognizes the new columns immediately
NOTIFY pgrst, 'reload schema';

-- Verification queries
SELECT 
  table_name,
  column_name,
  data_type,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name IN ('sellers', 'orders')
  AND column_name IN ('delivery_fee', 'rating', 'delivery_time', 'delivery_address')
ORDER BY table_name, column_name;
