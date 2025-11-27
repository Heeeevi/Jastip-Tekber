-- ============================================
-- CONFIRM ALL EXISTING USERS
-- Run this in Supabase SQL Editor
-- ============================================

-- Confirm all users yang belum di-confirm
UPDATE auth.users 
SET 
  email_confirmed_at = COALESCE(email_confirmed_at, now()),
  confirmed_at = COALESCE(confirmed_at, now())
WHERE email_confirmed_at IS NULL OR confirmed_at IS NULL;

-- Verify: Check all users now confirmed
SELECT 
  id,
  email,
  email_confirmed_at,
  confirmed_at,
  created_at
FROM auth.users
ORDER BY created_at DESC;

-- ============================================
-- SUCCESS! All users can now login immediately
-- ============================================
