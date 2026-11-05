-- ============================================================
-- Treat Up Restaurant & Bar - Supabase Schema & Seed Script
-- Generated automatically by extract_menu_to_sql.py
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Specials Table
CREATE TABLE IF NOT EXISTS public.specials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    price NUMERIC NOT NULL,
    description TEXT,
    image_url TEXT,
    is_new BOOLEAN DEFAULT false,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Regular Menu Items Table
CREATE TABLE IF NOT EXISTS public.menu_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category TEXT NOT NULL,
    sub_category TEXT,
    name TEXT NOT NULL,
    price NUMERIC NOT NULL,
    is_new BOOLEAN DEFAULT false,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Domestic Liquor Table
CREATE TABLE IF NOT EXISTS public.liquor_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand TEXT NOT NULL,
    ml_60 NUMERIC,
    qtr NUMERIC,
    half NUMERIC,
    full NUMERIC,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- Row Level Security (RLS) Configuration
-- ============================================================
ALTER TABLE public.specials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.liquor_items ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if re-running
DROP POLICY IF EXISTS "Allow public read access on specials" ON public.specials;
DROP POLICY IF EXISTS "Allow authenticated insert on specials" ON public.specials;
DROP POLICY IF EXISTS "Allow authenticated update on specials" ON public.specials;
DROP POLICY IF EXISTS "Allow authenticated delete on specials" ON public.specials;

CREATE POLICY "Allow public read access on specials" ON public.specials FOR SELECT USING (true);
CREATE POLICY "Allow authenticated insert on specials" ON public.specials FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update on specials" ON public.specials FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete on specials" ON public.specials FOR DELETE TO authenticated USING (true);

DROP POLICY IF EXISTS "Allow public read access on menu_items" ON public.menu_items;
DROP POLICY IF EXISTS "Allow authenticated insert on menu_items" ON public.menu_items;
DROP POLICY IF EXISTS "Allow authenticated update on menu_items" ON public.menu_items;
DROP POLICY IF EXISTS "Allow authenticated delete on menu_items" ON public.menu_items;

CREATE POLICY "Allow public read access on menu_items" ON public.menu_items FOR SELECT USING (true);
CREATE POLICY "Allow authenticated insert on menu_items" ON public.menu_items FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update on menu_items" ON public.menu_items FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete on menu_items" ON public.menu_items FOR DELETE TO authenticated USING (true);

DROP POLICY IF EXISTS "Allow public read access on liquor_items" ON public.liquor_items;
DROP POLICY IF EXISTS "Allow authenticated insert on liquor_items" ON public.liquor_items;
DROP POLICY IF EXISTS "Allow authenticated update on liquor_items" ON public.liquor_items;
DROP POLICY IF EXISTS "Allow authenticated delete on liquor_items" ON public.liquor_items;

CREATE POLICY "Allow public read access on liquor_items" ON public.liquor_items FOR SELECT USING (true);
CREATE POLICY "Allow authenticated insert on liquor_items" ON public.liquor_items FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update on liquor_items" ON public.liquor_items FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete on liquor_items" ON public.liquor_items FOR DELETE TO authenticated USING (true);

-- ============================================================
-- Storage Bucket: specials-images
-- ============================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('specials-images', 'specials-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

DROP POLICY IF EXISTS "Public read access for specials-images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated upload for specials-images" ON storage.objects;

CREATE POLICY "Public read access for specials-images" ON storage.objects
    FOR SELECT USING (bucket_id = 'specials-images');

CREATE POLICY "Authenticated upload for specials-images" ON storage.objects
    FOR INSERT TO authenticated WITH CHECK (bucket_id = 'specials-images');

-- ============================================================
-- Seed Data
-- ============================================================
TRUNCATE TABLE public.specials CASCADE;
TRUNCATE TABLE public.menu_items CASCADE;
TRUNCATE TABLE public.liquor_items CASCADE;

-- 1. Insert Home Page Specials
INSERT INTO public.specials (name, price, description, image_url, is_new, sort_order) VALUES
('Spinach Pesto Pasta', 350.0, 'Fresh spinach pesto sauce tossed with al dente pasta.', 'food/spanish pesto pasta.webp', true, 1),
('Chicken Steak w/ Mushroom', 450.0, 'Juicy steak topped with rich creamy mushroom sauce.', 'food/chicken steak w mushroom.webp', true, 2),
('Spicy Spaghetti', 350.0, 'A fiery twist on classic spaghetti with bold spices.', 'food/spicy spaghetti.webp', true, 3),
('Chicken Cafreal & Rice', 450.0, 'Goan-style green masala chicken served with aromatic garlic rice.', 'food/chicken cafreal & rice.webp', true, 4),
('Chicken Ramen', 350.0, 'Hearty broth, noodles, and tender chicken.', 'food/chicken ramen.webp', true, 5),
('Keema Rice', 350.0, 'Spiced minced meat served over fluffy rice.', 'food/keema rice.webp', true, 6),
('Chicken Chakli', 280.0, 'Crispy, savory chicken snack perfection.', 'food/chicken chakli.webp', true, 7),
('Pan Grilled Chicken Breast', 300.0, 'Served with fresh grilled tomatoes and herbs.', 'food/pan grilled chicken breast.webp', false, 8),
('Creamy Chicken w/ Garlic Bread', 350.0, 'Rich creamy sauce paired with crispy garlic bread.', 'food/creamy chicken w garlic bread.webp', false, 9),
('Chicken Rice Bowl', 300.0, 'Wholesome bowl with seasoned chicken and rice.', 'food/chicken rice bowl.webp', false, 10),
('Paneer Rice Bowl', 300.0, 'Cottage cheese cubes tossed in spices served over rice.', 'food/paneer rice bowl.webp', false, 11),
('Keema Noodles', 280.0, 'Minced chicken tossed with noodles and savory spices.', 'food/keema noodles chicken.webp', false, 12),
('Chicken Steak w/ Butter Rice', 350.0, 'Juicy chicken steak served with aromatic butter rice.', 'food/chicken steak with butter rice.webp', false, 13);

-- 2. Insert Regular Menu Items
INSERT INTO public.menu_items (category, sub_category, name, price, is_new, sort_order) VALUES
('starters', 'Veg. Starters', 'Mix Veg. Pakoda', 150.0, false, 1),
('starters', 'Veg. Starters', 'Potato Bites', 150.0, false, 2),
('starters', 'Veg. Starters', 'Veg. Wai Wai Sadheko', 150.0, false, 3),
('starters', 'Veg. Starters', 'Peanuts Sadheko', 220.0, false, 4),
('starters', 'Veg. Starters', 'Crispy Fried Mushroom', 350.0, false, 5),
('starters', 'Veg. Starters', 'Paneer Chilly', 350.0, false, 6),
('starters', 'Veg. Starters', 'Mushroom Chilly', 350.0, false, 7),
('starters', 'Veg. Starters', 'Paneer Pakoda', 350.0, false, 8),
('starters', 'Veg. Starters', 'Chips Chilly', 280.0, false, 9),
('starters', 'Veg. Starters', 'Dry Papad', 50.0, false, 10),
('starters', 'Veg. Starters', 'Butter Hot Corn', 180.0, false, 11),
('starters', 'Veg. Starters', 'Hariyo Pariyo Nepali Salad', 150.0, false, 12),
('starters', 'Non Veg. Starters', 'Chicken Wai-Wai Sadheko', 200.0, false, 13),
('starters', 'Non Veg. Starters', 'Chicken Fried Sausage', 200.0, false, 14),
('starters', 'Non Veg. Starters', 'Chicken Sadheko', 300.0, false, 15),
('starters', 'Non Veg. Starters', 'Chicken Popcorn', 300.0, false, 16),
('starters', 'Non Veg. Starters', 'Lovely Chicken Wings', 300.0, false, 17),
('starters', 'Non Veg. Starters', 'Chicken Chilly', 300.0, false, 18),
('starters', 'Non Veg. Starters', 'Chicken Roast', 300.0, false, 19),
('starters', 'Non Veg. Starters', 'Spicy Korean Fry Chicken', 350.0, false, 20),
('starters', 'Non Veg. Starters', 'Chicken Dragon', 300.0, false, 21),
('starters', 'Non Veg. Starters', 'Rosemary Chicken', 350.0, false, 22),
('starters', 'Non Veg. Starters', 'Crispy Chicken Finger with Cheese', 350.0, false, 23),
('starters', 'Non Veg. Starters', 'Crispy Lemon Chicken Things', 300.0, false, 24),
('soups', NULL, 'Mix. Veg. Clear Soup', 180.0, false, 25),
('soups', NULL, 'Chicken Clear Soup', 200.0, false, 26),
('soups', NULL, 'Mushroom Soup', 280.0, false, 27),
('soups', NULL, 'Chicken Creamy Soup', 280.0, false, 28),
('momo', 'Veg. MoMo', 'Steam', 130.0, false, 29),
('momo', 'Veg. MoMo', 'Fried', 150.0, false, 30),
('momo', 'Veg. MoMo', 'Chilly', 200.0, false, 31),
('momo', 'Veg. MoMo', 'Jhol', 200.0, false, 32),
('momo', 'Chicken MoMo', 'Steam', 200.0, false, 33),
('momo', 'Chicken MoMo', 'Fried', 220.0, false, 34),
('momo', 'Chicken MoMo', 'Chilly', 250.0, false, 35),
('momo', 'Chicken MoMo', 'Jhol', 250.0, false, 36),
('burgers', 'Burgers', 'Chicken Patty Burger', 300.0, false, 37),
('burgers', 'Burgers', 'Crispy Chicken Burger', 300.0, false, 38),
('burgers', 'Burgers', 'Veg. Patty Burger', 250.0, false, 39),
('burgers', 'Burgers', 'Juicy-lucy Burger', 350.0, false, 40),
('burgers', 'Burger Combo', 'Chicken Patty Burgers Combo', 400.0, false, 41),
('burgers', 'Burger Combo', 'Crispy Chicken Burgers Combo', 400.0, false, 42),
('burgers', 'Burger Combo', 'Veg. Patty Burgers Combo', 350.0, false, 43),
('burgers', 'Burger Combo', 'Juicy Lucy Burgers Combo', 500.0, false, 44),
('majors', 'Treat Up Special', 'Spinach Pesto Pasta', 350.0, true, 45),
('majors', 'Treat Up Special', 'Chicken Steak w/ Mushroom', 450.0, true, 46),
('majors', 'Treat Up Special', 'Spicy Spaghetti', 350.0, true, 47),
('majors', 'Treat Up Special', 'Chicken Cafreal & Rice', 450.0, true, 48),
('majors', 'Treat Up Special', 'Chicken Ramen', 350.0, true, 49),
('majors', 'Treat Up Special', 'Keema Rice', 350.0, true, 50),
('majors', 'Treat Up Special', 'Chicken Chakli', 280.0, true, 51),
('majors', 'Treat Up Special', 'Pan Grilled Chicken Breast with Grill Tomato', 300.0, false, 52),
('majors', 'Treat Up Special', 'Creamy Chicken with Garlic Bread', 350.0, false, 53),
('majors', 'Treat Up Special', 'Chicken Rice Bowl', 300.0, false, 54),
('majors', 'Treat Up Special', 'Paneer Rice Bowl', 300.0, false, 55),
('majors', 'Treat Up Special', 'Keema Noodles Chicken', 300.0, false, 56),
('majors', 'Treat Up Special', 'Chicken Steak with Butter Rice', 350.0, false, 57),
('majors', 'Chowmein', 'Veg.', 180.0, false, 58),
('majors', 'Chowmein', 'Egg', 250.0, false, 59),
('majors', 'Chowmein', 'Chicken', 250.0, false, 60),
('majors', 'Chowmein', 'Mix. Chowmein', 280.0, false, 61),
('majors', 'Fry Rice', 'Veg.', 180.0, false, 62),
('majors', 'Fry Rice', 'Egg', 250.0, false, 63),
('majors', 'Fry Rice', 'Chicken', 250.0, false, 64),
('majors', 'Fry Rice', 'Mix. Fry Rice', 280.0, false, 65),
('pasta', NULL, 'Red Sauce Pasta', 300.0, false, 66),
('pasta', NULL, 'White Sauce Pasta', 300.0, false, 67),
('pasta', NULL, 'Mixed Sauce Pasta', 350.0, false, 68),
('drinks', 'Hot Drinks', 'Milk Tea', 50.0, false, 69),
('drinks', 'Hot Drinks', 'Lemon Tea', 50.0, false, 70),
('drinks', 'Hot Drinks', 'Black Tea', 40.0, false, 71),
('drinks', 'Hot Drinks', 'Milk Coffee', 120.0, false, 72),
('drinks', 'Hot Drinks', 'Black Coffee', 100.0, false, 73),
('drinks', 'Hot Drinks', 'Ginger Hot Lemon with Honey', 100.0, false, 74),
('drinks', 'Soft/Cold Drinks', 'Milk Banana Shake', 150.0, false, 75),
('drinks', 'Soft/Cold Drinks', 'Banana Lassi', 200.0, false, 76),
('drinks', 'Soft/Cold Drinks', 'Sweet Lassi', 160.0, false, 77),
('drinks', 'Soft/Cold Drinks', 'Vanilla Shake', 200.0, false, 78),
('drinks', 'Soft/Cold Drinks', 'Lemonade', 150.0, false, 79),
('drinks', 'Soft/Cold Drinks', 'Cold Coffee', 200.0, false, 80),
('drinks', 'Soft/Cold Drinks', 'Coke/Fanta/Sprite', 90.0, false, 81),
('drinks', 'Soft/Cold Drinks', 'Can Juice', 150.0, false, 82),
('drinks', 'Soft/Cold Drinks', 'Mineral Water', 30.0, false, 83),
('drinks', 'Soft/Cold Drinks', 'Red Bull', 250.0, false, 84),
('drinks', 'Soft/Cold Drinks', 'Apple Cider', 280.0, false, 85),
('drinks', 'Beer', 'Tuborg', 600.0, false, 86),
('drinks', 'Beer', 'Gorkha (Strong)', 500.0, false, 87),
('drinks', 'Dessert', 'Hot Chocolate Brownie with Vanilla Ice Cream', 220.0, false, 88),
('liquor', 'Wine', 'Divine (Red) Full', 1300.0, false, 89),
('liquor', 'Wine', 'Big Master (Red) Full', 1400.0, false, 90),
('liquor', 'Wine', 'Robertser Full', 2200.0, false, 91),
('liquor', 'Sisha (Hookah)', 'Hookah', 400.0, false, 92),
('liquor', 'Cigarette', 'Surya', 30.0, false, 93),
('liquor', 'Cigarette', 'Shikhar Ice Rush', 25.0, false, 94);

-- 3. Insert Domestic Liquor Items
INSERT INTO public.liquor_items (brand, ml_60, qtr, half, full, sort_order) VALUES
('Royal Stag', 350.0, 730.0, 1300.0, 2500.0, 1),
('Ruslan', 350.0, 730.0, 1300.0, 2500.0, 2),
('Khukri Rum', 400.0, 800.0, 1450.0, 2750.0, 3),
('8848', 390.0, 780.0, 1400.0, 2700.0, 4),
('Signature (Red)', 410.0, 880.0, 1750.0, 3300.0, 5),
('Old Durbar (Red)', 470.0, 1050.0, 2000.0, 3800.0, 6),
('Old Durbar (Black)', 550.0, 1250.0, 2450.0, 4600.0, 7);
