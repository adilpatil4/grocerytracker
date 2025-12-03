-- Location: supabase/migrations/20251006183004_grocerease_with_auth.sql
-- Schema Analysis: Fresh project with no existing schema
-- Integration Type: Complete new schema implementation
-- Dependencies: None (fresh start)

-- 1. Custom Types
CREATE TYPE public.user_role AS ENUM ('admin', 'user');
CREATE TYPE public.item_category AS ENUM ('produce', 'dairy', 'meat', 'pantry', 'frozen', 'beverages', 'snacks', 'household', 'other');
CREATE TYPE public.storage_location AS ENUM ('refrigerator', 'freezer', 'pantry', 'cabinet', 'counter');
CREATE TYPE public.notification_type AS ENUM ('expiring_soon', 'expired', 'low_stock', 'shopping_reminder');

-- 2. Core User Table (Critical intermediary for PostgREST compatibility)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'user'::public.user_role,
    preferences JSONB DEFAULT '{
        "notification_days_before": 3,
        "email_notifications": true,
        "default_storage_location": "refrigerator"
    }'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Grocery Inventory Management
CREATE TABLE public.grocery_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    category public.item_category DEFAULT 'other'::public.item_category,
    brand TEXT,
    barcode TEXT,
    quantity INTEGER DEFAULT 1,
    unit TEXT DEFAULT 'pieces',
    purchase_date DATE DEFAULT CURRENT_DATE,
    expiration_date DATE,
    storage_location public.storage_location DEFAULT 'pantry'::public.storage_location,
    notes TEXT,
    purchase_price DECIMAL(10,2),
    store_name TEXT,
    is_consumed BOOLEAN DEFAULT false,
    consumed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Shopping Lists
CREATE TABLE public.shopping_lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL DEFAULT 'My Shopping List',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.shopping_list_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shopping_list_id UUID REFERENCES public.shopping_lists(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    quantity INTEGER DEFAULT 1,
    unit TEXT DEFAULT 'pieces',
    category public.item_category DEFAULT 'other'::public.item_category,
    is_purchased BOOLEAN DEFAULT false,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Receipt Processing Records
CREATE TABLE public.receipt_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    store_name TEXT,
    receipt_date DATE DEFAULT CURRENT_DATE,
    total_amount DECIMAL(10,2),
    veryfi_document_id TEXT,
    processed_data JSONB,
    items_added_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 6. Notification System
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    grocery_item_id UUID REFERENCES public.grocery_items(id) ON DELETE CASCADE,
    type public.notification_type NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    is_email_sent BOOLEAN DEFAULT false,
    scheduled_for TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 7. Essential Indexes for Performance
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_grocery_items_user_id ON public.grocery_items(user_id);
CREATE INDEX idx_grocery_items_expiration ON public.grocery_items(expiration_date) WHERE expiration_date IS NOT NULL;
CREATE INDEX idx_grocery_items_category ON public.grocery_items(category);
CREATE INDEX idx_grocery_items_storage ON public.grocery_items(storage_location);
CREATE INDEX idx_shopping_lists_user_id ON public.shopping_lists(user_id);
CREATE INDEX idx_shopping_list_items_list_id ON public.shopping_list_items(shopping_list_id);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_scheduled ON public.notifications(scheduled_for) WHERE scheduled_for IS NOT NULL;
CREATE INDEX idx_receipt_records_user_id ON public.receipt_records(user_id);

-- 8. Update Timestamp Trigger Function
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 9. Apply Update Triggers
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_grocery_items_updated_at BEFORE UPDATE ON public.grocery_items FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_shopping_lists_updated_at BEFORE UPDATE ON public.shopping_lists FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_shopping_list_items_updated_at BEFORE UPDATE ON public.shopping_list_items FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 10. Helper Functions for Notifications
CREATE OR REPLACE FUNCTION public.get_expiring_items(days_ahead INTEGER DEFAULT 3)
RETURNS TABLE(
    item_id UUID,
    user_id UUID,
    item_name TEXT,
    expiration_date DATE,
    days_until_expiration INTEGER
) 
LANGUAGE sql STABLE SECURITY DEFINER AS $$
SELECT 
    gi.id,
    gi.user_id,
    gi.name,
    gi.expiration_date,
    (gi.expiration_date - CURRENT_DATE)::INTEGER as days_until_expiration
FROM public.grocery_items gi
WHERE gi.expiration_date IS NOT NULL 
    AND gi.is_consumed = false
    AND gi.expiration_date <= CURRENT_DATE + INTERVAL '1 day' * days_ahead
    AND gi.expiration_date >= CURRENT_DATE
ORDER BY gi.expiration_date ASC;
$$;

-- 11. Enable Row Level Security
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.grocery_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shopping_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shopping_list_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.receipt_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 12. RLS Policies (Following Pattern 1 for core user table, Pattern 2 for others)

-- Pattern 1: Core User Table - Simple ownership
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple User Ownership for all other tables
CREATE POLICY "users_manage_own_grocery_items"
ON public.grocery_items
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_shopping_lists"
ON public.shopping_lists
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_shopping_list_items"
ON public.shopping_list_items
FOR ALL
TO authenticated
USING (
    shopping_list_id IN (
        SELECT id FROM public.shopping_lists WHERE user_id = auth.uid()
    )
)
WITH CHECK (
    shopping_list_id IN (
        SELECT id FROM public.shopping_lists WHERE user_id = auth.uid()
    )
);

CREATE POLICY "users_manage_own_receipt_records"
ON public.receipt_records
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_notifications"
ON public.notifications
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 13. Auto-create user profile trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, role)
    VALUES (
        NEW.id, 
        NEW.email, 
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'role', 'user')::public.user_role
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 14. Mock Data for Testing
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    user_uuid UUID := gen_random_uuid();
    shopping_list_id UUID := gen_random_uuid();
BEGIN
    -- Create auth users for testing
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@grocerease.com', crypt('grocer123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Grocery Admin", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'user@grocerease.com', crypt('grocer123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Grocery User"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create sample grocery items
    INSERT INTO public.grocery_items (user_id, name, category, brand, quantity, unit, purchase_date, expiration_date, storage_location, purchase_price, store_name) VALUES
        (user_uuid, 'Organic Milk', 'dairy', 'Whole Foods', 1, 'gallon', CURRENT_DATE - INTERVAL '2 days', CURRENT_DATE + INTERVAL '5 days', 'refrigerator', 4.99, 'Whole Foods Market'),
        (user_uuid, 'Bananas', 'produce', 'Dole', 6, 'pieces', CURRENT_DATE - INTERVAL '1 day', CURRENT_DATE + INTERVAL '3 days', 'counter', 2.49, 'Whole Foods Market'),
        (user_uuid, 'Chicken Breast', 'meat', 'Perdue', 2, 'lbs', CURRENT_DATE - INTERVAL '1 day', CURRENT_DATE + INTERVAL '2 days', 'refrigerator', 8.99, 'Whole Foods Market'),
        (user_uuid, 'Bread', 'pantry', 'Wonder', 1, 'loaf', CURRENT_DATE, CURRENT_DATE + INTERVAL '7 days', 'pantry', 3.49, 'Safeway'),
        (user_uuid, 'Frozen Pizza', 'frozen', 'DiGiorno', 2, 'pieces', CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days', 'freezer', 5.99, 'Safeway');

    -- Create shopping list
    INSERT INTO public.shopping_lists (id, user_id, name) VALUES
        (shopping_list_id, user_uuid, 'Weekly Groceries');

    -- Add items to shopping list
    INSERT INTO public.shopping_list_items (shopping_list_id, name, quantity, unit, category) VALUES
        (shopping_list_id, 'Greek Yogurt', 2, 'containers', 'dairy'),
        (shopping_list_id, 'Apples', 8, 'pieces', 'produce'),
        (shopping_list_id, 'Ground Turkey', 1, 'lb', 'meat'),
        (shopping_list_id, 'Pasta', 2, 'boxes', 'pantry');

    -- Create sample notifications
    INSERT INTO public.notifications (user_id, type, title, message, scheduled_for) VALUES
        (user_uuid, 'expiring_soon', 'Items Expiring Soon', 'You have 3 items expiring in the next 3 days', CURRENT_TIMESTAMP + INTERVAL '1 hour'),
        (user_uuid, 'shopping_reminder', 'Shopping Reminder', 'Don''t forget your shopping list for this week!', CURRENT_TIMESTAMP + INTERVAL '1 day');

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Some test data already exists, skipping...';
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating test data: %', SQLERRM;
END $$;