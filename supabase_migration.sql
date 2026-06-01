-- ============================================================
-- Balligh App - Supabase Migration SQL
-- Run this in the Supabase SQL Editor (Dashboard → SQL Editor)
-- ============================================================

-- 1. Users table (extends auth.users)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  reputation_score INTEGER NOT NULL DEFAULT 0,
  reports_count INTEGER NOT NULL DEFAULT 0,
  confirmed_count INTEGER NOT NULL DEFAULT 0
);

-- 2. Reports table
CREATE TABLE IF NOT EXISTS public.reports (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  category TEXT NOT NULL,
  description TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  address TEXT,
  photo_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  status TEXT NOT NULL DEFAULT 'pending',
  confirm_count INTEGER NOT NULL DEFAULT 0,
  deny_count INTEGER NOT NULL DEFAULT 0
);

-- 3. Votes table
CREATE TABLE IF NOT EXISTS public.votes (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  report_id BIGINT NOT NULL REFERENCES public.reports(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  vote_type TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(report_id, user_id)
);

-- 4. Notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  report_id BIGINT REFERENCES public.reports(id) ON DELETE SET NULL,
  message TEXT NOT NULL,
  is_read INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- Enable Row Level Security (RLS)
-- ============================================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- RLS Policies
-- ============================================================

-- Users: authenticated users can read all; users can insert/update their own row
CREATE POLICY "Users are viewable by everyone"
  ON public.users FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Users can insert their own row"
  ON public.users FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own row"
  ON public.users FOR UPDATE
  USING (auth.uid() = id);

-- Reports: anyone authenticated can read; authenticated users can insert;
-- only the creator can update/delete
CREATE POLICY "Reports are viewable by all authenticated users"
  ON public.reports FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Users can insert own reports"
  ON public.reports FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Creators can update own reports" ON public.reports;
CREATE POLICY "Creators can update own reports"
  ON public.reports FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins can update any report" ON public.reports;
CREATE POLICY "Admins can update any report"
  ON public.reports FOR UPDATE
  USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = true))
  WITH CHECK (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = true));

CREATE POLICY "Creators can delete own reports"
  ON public.reports FOR DELETE
  USING (auth.uid() = user_id);

-- Votes: anyone authenticated can read; authenticated users can insert;
-- can update/delete own votes
CREATE POLICY "Votes are viewable by all authenticated users"
  ON public.votes FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can vote"
  ON public.votes FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update own votes"
  ON public.votes FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own votes"
  ON public.votes FOR DELETE
  USING (auth.uid() = user_id);

-- Notifications: users see only their own; only system can insert
CREATE POLICY "Users view own notifications"
  ON public.notifications FOR SELECT
  USING (auth.uid() = user_id);

-- Allow the service_role (server-side) to insert notifications
-- For client-side, we'll make a function

-- ============================================================
-- Functions for notification creation (runs with SECURITY DEFINER)
-- ============================================================
CREATE OR REPLACE FUNCTION public.create_notification(
  p_user_id UUID,
  p_report_id BIGINT,
  p_message TEXT
) RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  v_id BIGINT;
BEGIN
  INSERT INTO public.notifications (user_id, report_id, message, created_at)
  VALUES (p_user_id, p_report_id, p_message, now())
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;

-- Allow authenticated users to call the function
GRANT EXECUTE ON FUNCTION public.create_notification TO authenticated;

-- ============================================================
-- Add photo_url column to existing reports tables (if missing)
-- ============================================================
ALTER TABLE public.reports ADD COLUMN IF NOT EXISTS photo_url TEXT;

-- ============================================================
-- Admin support
-- ============================================================
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS is_admin BOOLEAN NOT NULL DEFAULT false;

-- Allow admins to update any report
CREATE POLICY "Admins can update any report"
  ON public.reports FOR UPDATE
  USING (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = true));

-- Allow admins to delete any report
CREATE POLICY "Admins can delete any report"
  ON public.reports FOR DELETE
  USING (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = true));

-- Allow admins to view all users
CREATE POLICY "Admins can view all users"
  ON public.users FOR SELECT
  USING (
    auth.uid() IN (SELECT id FROM public.users WHERE is_admin = true)
    OR auth.uid() = id
  );

-- Allow admins to view all notifications
CREATE POLICY "Admins can view all notifications"
  ON public.notifications FOR SELECT
  USING (
    auth.uid() IN (SELECT id FROM public.users WHERE is_admin = true)
    OR auth.uid() = user_id
  );

-- To set a user as admin, run:
-- UPDATE public.users SET is_admin = true WHERE email = 'admin@example.com';

-- ============================================================
-- Storage: "reports" bucket for photo uploads
-- ============================================================

-- Insert the bucket (idempotent — skips if exists)
INSERT INTO storage.buckets (id, name, public)
VALUES ('reports', 'reports', true)
ON CONFLICT (id) DO NOTHING;

-- Allow authenticated users to upload files to the reports bucket
CREATE POLICY "Authenticated users can upload report photos"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'reports'
    AND auth.role() = 'authenticated'
  );

-- Allow public access to view/download report photos
CREATE POLICY "Anyone can view report photos"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'reports');

-- Allow uploaders to delete their own photos
CREATE POLICY "Uploaders can delete own photos"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'reports'
    AND auth.uid() = owner
  );

-- ============================================================
-- 6. Messages table (in-app chat)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.messages (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  report_id BIGINT NOT NULL REFERENCES public.reports(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Users can read messages they sent or received
CREATE POLICY "Users can read their own messages"
  ON public.messages FOR SELECT
  USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- Authenticated users can send messages
CREATE POLICY "Authenticated users can insert messages"
  ON public.messages FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Users can mark messages they received as read
CREATE POLICY "Receivers can update messages"
  ON public.messages FOR UPDATE
  USING (auth.uid() = receiver_id)
  WITH CHECK (auth.uid() = receiver_id);

-- ============================================================
-- 7. RPC: Update vote counts (bypasses RLS so any user can vote)
-- ============================================================
CREATE OR REPLACE FUNCTION public.update_vote_counts(
  p_report_id BIGINT,
  p_confirm_count INT,
  p_deny_count INT
) RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
  UPDATE public.reports
  SET confirm_count = p_confirm_count,
      deny_count = p_deny_count
  WHERE id = p_report_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.update_vote_counts TO authenticated;

-- Fix the votes INSERT RLS policy: ensure user_id matches the authenticated user
DROP POLICY IF EXISTS "Authenticated users can vote" ON public.votes;
CREATE POLICY "Users can insert own votes"
  ON public.votes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- Seed data (create after running auth user creation)
-- ============================================================
-- Since we can't pre-seed auth.users UUIDs, seed data is now
-- created dynamically when a user registers.
-- For development, register users manually or via the app UI.
