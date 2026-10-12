import re
from bs4 import BeautifulSoup

def clean_sql_str(val):
    if val is None or val == '':
        return "NULL"
    # Escape single quotes for SQL
    escaped = str(val).replace("'", "''")
    return f"'{escaped}'"

def extract_specials(html_path):
    with open(html_path, 'r', encoding='utf-8') as f:
        soup = BeautifulSoup(f.read(), 'html.parser')
    
    specials = []
    grid = soup.find('div', class_='menu-grid')
    if not grid:
        return specials
    
    items = grid.find_all('div', class_='menu-item')
    for idx, item in enumerate(items, 1):
        h4 = item.find('h4')
        name = h4.get_text(strip=True) if h4 else ''
        
        price_el = item.find('span', class_='price')
        price_text = price_el.get_text(strip=True) if price_el else '0'
        p_match = re.search(r'(\d+)', price_text)
        price = float(p_match.group(1)) if p_match else 0.0
        
        desc_el = item.find('p', class_='dish-desc')
        desc = desc_el.get_text(strip=True) if desc_el else ''
        
        img = item.find('img', class_='menu-img')
        img_url = img['src'] if img and img.has_attr('src') else ''
        
        classes = item.get('class', [])
        is_new = 'premium-item' in classes
        
        specials.append({
            'name': name,
            'price': price,
            'description': desc,
            'image_url': img_url,
            'is_new': is_new,
            'sort_order': idx
        })
    return specials

def extract_menu_items_and_liquor(html_path):
    with open(html_path, 'r', encoding='utf-8') as f:
        soup = BeautifulSoup(f.read(), 'html.parser')
    
    menu_items = []
    sort_order = 0
    sections = soup.find_all('section', class_='menu-section')
    
    for sec in sections:
        cat_id = sec.get('id', '')
        curr_subcat = ''
        
        # Traverse elements in order so Beer, Dessert, Wine, etc. are properly captured
        for el in sec.find_all(['h3', 'div']):
            if el.name == 'h3' and 'menu-group-title' in el.get('class', []):
                curr_subcat = el.get_text(strip=True)
            elif el.name == 'div' and 'menu-list-item' in el.get('class', []):
                sort_order += 1
                name_el = el.find(class_='item-name')
                name = name_el.get_text(strip=True) if name_el else ''
                
                is_new = bool(el.find('span', class_='inline-new-badge'))
                
                price_el = el.find('div', class_='item-price')
                price_text = price_el.get_text(strip=True) if price_el else '0'
                p_match = re.search(r'(\d+)', price_text)
                price = float(p_match.group(1)) if p_match else 0.0
                
                menu_items.append({
                    'category': cat_id,
                    'sub_category': curr_subcat,
                    'name': name,
                    'price': price,
                    'is_new': is_new,
                    'sort_order': sort_order
                })
                
    liquor_items = []
    table = soup.find('table', class_='liquor-table')
    if table:
        tbody = table.find('tbody') or table
        rows = tbody.find_all('tr')
        idx = 0
        for tr in rows:
            tds = tr.find_all('td')
            if len(tds) >= 5:
                idx += 1
                brand = tds[0].get_text(strip=True)
                def parse_price(td):
                    m = re.search(r'(\d+)', td.get_text(strip=True))
                    return float(m.group(1)) if m else None
                liquor_items.append({
                    'brand': brand,
                    'ml_60': parse_price(tds[1]),
                    'qtr': parse_price(tds[2]),
                    'half': parse_price(tds[3]),
                    'full': parse_price(tds[4]),
                    'sort_order': idx
                })
                
    return menu_items, liquor_items

def generate_sql(specials, menu_items, liquor_items, output_path):
    sql_lines = []
    
    # Header
    sql_lines.append("-- ============================================================")
    sql_lines.append("-- Treat Up Restaurant & Bar - Supabase Schema & Seed Script")
    sql_lines.append("-- Generated automatically by extract_menu_to_sql.py")
    sql_lines.append("-- ============================================================\n")
    
    # Extensions
    sql_lines.append("CREATE EXTENSION IF NOT EXISTS \"pgcrypto\";\n")
    
    # 1. Specials Table
    sql_lines.append("-- 1. Specials Table")
    sql_lines.append("CREATE TABLE IF NOT EXISTS public.specials (")
    sql_lines.append("    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),")
    sql_lines.append("    name TEXT NOT NULL,")
    sql_lines.append("    price NUMERIC NOT NULL,")
    sql_lines.append("    description TEXT,")
    sql_lines.append("    image_url TEXT,")
    sql_lines.append("    is_new BOOLEAN DEFAULT false,")
    sql_lines.append("    sort_order INT DEFAULT 0,")
    sql_lines.append("    is_active BOOLEAN DEFAULT true,")
    sql_lines.append("    created_at TIMESTAMPTZ DEFAULT now()")
    sql_lines.append(");\n")
    
    # 2. Menu Items Table
    sql_lines.append("-- 2. Regular Menu Items Table")
    sql_lines.append("CREATE TABLE IF NOT EXISTS public.menu_items (")
    sql_lines.append("    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),")
    sql_lines.append("    category TEXT NOT NULL,")
    sql_lines.append("    sub_category TEXT,")
    sql_lines.append("    name TEXT NOT NULL,")
    sql_lines.append("    price NUMERIC NOT NULL,")
    sql_lines.append("    is_new BOOLEAN DEFAULT false,")
    sql_lines.append("    sort_order INT DEFAULT 0,")
    sql_lines.append("    is_active BOOLEAN DEFAULT true,")
    sql_lines.append("    created_at TIMESTAMPTZ DEFAULT now()")
    sql_lines.append(");\n")
    
    # 3. Liquor Items Table
    sql_lines.append("-- 3. Domestic Liquor Table")
    sql_lines.append("CREATE TABLE IF NOT EXISTS public.liquor_items (")
    sql_lines.append("    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),")
    sql_lines.append("    brand TEXT NOT NULL,")
    sql_lines.append("    ml_60 NUMERIC,")
    sql_lines.append("    qtr NUMERIC,")
    sql_lines.append("    half NUMERIC,")
    sql_lines.append("    full NUMERIC,")
    sql_lines.append("    sort_order INT DEFAULT 0,")
    sql_lines.append("    is_active BOOLEAN DEFAULT true,")
    sql_lines.append("    created_at TIMESTAMPTZ DEFAULT now()")
    sql_lines.append(");\n")
    
    # Row Level Security
    sql_lines.append("-- ============================================================")
    sql_lines.append("-- Row Level Security (RLS) Configuration")
    sql_lines.append("-- ============================================================")
    sql_lines.append("ALTER TABLE public.specials ENABLE ROW LEVEL SECURITY;")
    sql_lines.append("ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;")
    sql_lines.append("ALTER TABLE public.liquor_items ENABLE ROW LEVEL SECURITY;\n")
    
    sql_lines.append("-- Drop existing policies if re-running")
    sql_lines.append("DROP POLICY IF EXISTS \"Allow public read access on specials\" ON public.specials;")
    sql_lines.append("DROP POLICY IF EXISTS \"Allow authenticated insert on specials\" ON public.specials;")
    sql_lines.append("DROP POLICY IF EXISTS \"Allow authenticated update on specials\" ON public.specials;")
    sql_lines.append("DROP POLICY IF EXISTS \"Allow authenticated delete on specials\" ON public.specials;\n")
    
    sql_lines.append("CREATE POLICY \"Allow public read access on specials\" ON public.specials FOR SELECT USING (true);")
    sql_lines.append("CREATE POLICY \"Allow authenticated insert on specials\" ON public.specials FOR INSERT TO authenticated WITH CHECK (true);")
    sql_lines.append("CREATE POLICY \"Allow authenticated update on specials\" ON public.specials FOR UPDATE TO authenticated USING (true);")
    sql_lines.append("CREATE POLICY \"Allow authenticated delete on specials\" ON public.specials FOR DELETE TO authenticated USING (true);\n")
    
    sql_lines.append("DROP POLICY IF EXISTS \"Allow public read access on menu_items\" ON public.menu_items;")
    sql_lines.append("DROP POLICY IF EXISTS \"Allow authenticated insert on menu_items\" ON public.menu_items;")
    sql_lines.append("DROP POLICY IF EXISTS \"Allow authenticated update on menu_items\" ON public.menu_items;")
    sql_lines.append("DROP POLICY IF EXISTS \"Allow authenticated delete on menu_items\" ON public.menu_items;\n")
    
    sql_lines.append("CREATE POLICY \"Allow public read access on menu_items\" ON public.menu_items FOR SELECT USING (true);")
    sql_lines.append("CREATE POLICY \"Allow authenticated insert on menu_items\" ON public.menu_items FOR INSERT TO authenticated WITH CHECK (true);")
    sql_lines.append("CREATE POLICY \"Allow authenticated update on menu_items\" ON public.menu_items FOR UPDATE TO authenticated USING (true);")
    sql_lines.append("CREATE POLICY \"Allow authenticated delete on menu_items\" ON public.menu_items FOR DELETE TO authenticated USING (true);\n")
    
    sql_lines.append("DROP POLICY IF EXISTS \"Allow public read access on liquor_items\" ON public.liquor_items;")
    sql_lines.append("DROP POLICY IF EXISTS \"Allow authenticated insert on liquor_items\" ON public.liquor_items;")
    sql_lines.append("DROP POLICY IF EXISTS \"Allow authenticated update on liquor_items\" ON public.liquor_items;")
    sql_lines.append("DROP POLICY IF EXISTS \"Allow authenticated delete on liquor_items\" ON public.liquor_items;\n")
    
    sql_lines.append("CREATE POLICY \"Allow public read access on liquor_items\" ON public.liquor_items FOR SELECT USING (true);")
    sql_lines.append("CREATE POLICY \"Allow authenticated insert on liquor_items\" ON public.liquor_items FOR INSERT TO authenticated WITH CHECK (true);")
    sql_lines.append("CREATE POLICY \"Allow authenticated update on liquor_items\" ON public.liquor_items FOR UPDATE TO authenticated USING (true);")
    sql_lines.append("CREATE POLICY \"Allow authenticated delete on liquor_items\" ON public.liquor_items FOR DELETE TO authenticated USING (true);\n")
    
    # Storage Configuration
    sql_lines.append("-- ============================================================")
    sql_lines.append("-- Storage Bucket: specials-images")
    sql_lines.append("-- ============================================================")
    sql_lines.append("INSERT INTO storage.buckets (id, name, public)")
    sql_lines.append("VALUES ('specials-images', 'specials-images', true)")
    sql_lines.append("ON CONFLICT (id) DO UPDATE SET public = true;\n")
    
    sql_lines.append("DROP POLICY IF EXISTS \"Public read access for specials-images\" ON storage.objects;")
    sql_lines.append("DROP POLICY IF EXISTS \"Authenticated upload for specials-images\" ON storage.objects;\n")
    
    sql_lines.append("CREATE POLICY \"Public read access for specials-images\" ON storage.objects")
    sql_lines.append("    FOR SELECT USING (bucket_id = 'specials-images');\n")
    sql_lines.append("CREATE POLICY \"Authenticated upload for specials-images\" ON storage.objects")
    sql_lines.append("    FOR INSERT TO authenticated WITH CHECK (bucket_id = 'specials-images');\n")
    
    # Seed Data - Clear existing rows for idempotent seeding
    sql_lines.append("-- ============================================================")
    sql_lines.append("-- Seed Data")
    sql_lines.append("-- ============================================================")
    sql_lines.append("TRUNCATE TABLE public.specials CASCADE;")
    sql_lines.append("TRUNCATE TABLE public.menu_items CASCADE;")
    sql_lines.append("TRUNCATE TABLE public.liquor_items CASCADE;\n")
    
    # Insert specials
    sql_lines.append("-- 1. Insert Home Page Specials")
    sql_lines.append("INSERT INTO public.specials (name, price, description, image_url, is_new, sort_order) VALUES")
    specials_vals = []
    for s in specials:
        v = f"({clean_sql_str(s['name'])}, {s['price']}, {clean_sql_str(s['description'])}, {clean_sql_str(s['image_url'])}, {'true' if s['is_new'] else 'false'}, {s['sort_order']})"
        specials_vals.append(v)
    sql_lines.append(",\n".join(specials_vals) + ";\n")
    
    # Insert menu_items
    sql_lines.append("-- 2. Insert Regular Menu Items")
    sql_lines.append("INSERT INTO public.menu_items (category, sub_category, name, price, is_new, sort_order) VALUES")
    menu_vals = []
    for m in menu_items:
        v = f"({clean_sql_str(m['category'])}, {clean_sql_str(m['sub_category'])}, {clean_sql_str(m['name'])}, {m['price']}, {'true' if m['is_new'] else 'false'}, {m['sort_order']})"
        menu_vals.append(v)
    sql_lines.append(",\n".join(menu_vals) + ";\n")
    
    # Insert liquor_items
    sql_lines.append("-- 3. Insert Domestic Liquor Items")
    sql_lines.append("INSERT INTO public.liquor_items (brand, ml_60, qtr, half, full, sort_order) VALUES")
    liq_vals = []
    for l in liquor_items:
        ml_60 = l['ml_60'] if l['ml_60'] is not None else "NULL"
        qtr = l['qtr'] if l['qtr'] is not None else "NULL"
        half = l['half'] if l['half'] is not None else "NULL"
        full = l['full'] if l['full'] is not None else "NULL"
        v = f"({clean_sql_str(l['brand'])}, {ml_60}, {qtr}, {half}, {full}, {l['sort_order']})"
        liq_vals.append(v)
    sql_lines.append(",\n".join(liq_vals) + ";\n")
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("\n".join(sql_lines))

if __name__ == "__main__":
    specials = extract_specials("index.html")
    menu_items, liquor_items = extract_menu_items_and_liquor("menu.html")
    
    print(f"Extracted {len(specials)} specials from index.html")
    print(f"Extracted {len(menu_items)} menu items from menu.html")
    print(f"Extracted {len(liquor_items)} liquor items from menu.html")
    
    generate_sql(specials, menu_items, liquor_items, "schema_and_seed.sql")
    print("Successfully generated schema_and_seed.sql")
