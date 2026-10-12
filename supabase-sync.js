/**
 * Treat Up Restaurant & Bar - Supabase Progressive Hydration Engine
 * Progressively enhances static offline HTML with live database prices & items.
 */

(function () {
    'use strict';

    // Dimension map for specials to guarantee zero CLS
    const SPECIAL_DIMENSIONS = {
        'spanish pesto pasta': { w: 1024, h: 1024 },
        'chicken steak w mushroom': { w: 1024, h: 1536 },
        'spicy spaghetti': { w: 1200, h: 1200 },
        'chicken cafreal & rice': { w: 1024, h: 1536 },
        'chicken ramen': { w: 1024, h: 1536 },
        'keema rice': { w: 1024, h: 1536 },
        'chicken chakli': { w: 1024, h: 1536 },
        'pan grilled chicken breast': { w: 1024, h: 1536 },
        'creamy chicken w garlic bread': { w: 1024, h: 1536 },
        'chicken rice bowl': { w: 1024, h: 1536 },
        'paneer rice bowl': { w: 1024, h: 1024 },
        'keema noodles chicken': { w: 2311, h: 1536 },
        'chicken steak with butter rice': { w: 2816, h: 1536 }
    };

    function getImageDimensions(url) {
        if (!url) return { w: 1024, h: 1024 };
        const clean = url.toLowerCase().replace(/\\/g, '/');
        for (const [key, dim] of Object.entries(SPECIAL_DIMENSIONS)) {
            if (clean.includes(key)) return dim;
        }
        return { w: 1024, h: 1024 };
    }

    // Helper: Normalize string for flexible DOM comparison
    function normalizeText(txt) {
        return (txt || '').toLowerCase().replace(/[^a-z0-9]/g, '');
    }

    // Fallback copy button injector in case script.js hasn't exposed it
    function attachCopyButtons() {
        if (typeof window.injectCopyButtons === 'function') {
            window.injectCopyButtons();
            return;
        }

        const menuItems = document.querySelectorAll('.item-name');
        menuItems.forEach(item => {
            if (item.querySelector('.copy-btn')) return;

            const copyIcon = document.createElement('ion-icon');
            copyIcon.setAttribute('name', 'copy-outline');
            copyIcon.classList.add('copy-btn');
            copyIcon.setAttribute('title', 'Copy to Order');
            item.appendChild(copyIcon);

            copyIcon.addEventListener('click', (e) => {
                e.stopPropagation();
                const text = item.childNodes[0].textContent.trim();
                navigator.clipboard.writeText(text).then(() => {
                    copyIcon.setAttribute('name', 'checkmark-circle');
                    copyIcon.style.color = '#25d366';
                    if (typeof showToast === 'function') {
                        showToast(`Copied: "${text}"`);
                    }
                    setTimeout(() => {
                        copyIcon.setAttribute('name', 'copy-outline');
                        copyIcon.style.color = '';
                    }, 2000);
                }).catch(err => {
                    console.error('Failed to copy', err);
                });
            });
        });
    }

    // Hydrate Index Page Specials
    async function hydrateSpecials(client) {
        const grid = document.querySelector('#menu .menu-grid');
        if (!grid) return;

        try {
            const { data: specials, error } = await client
                .from('specials')
                .select('*')
                .eq('is_active', true)
                .order('sort_order', { ascending: true });

            if (error) {
                console.warn('[TreatUp] Supabase specials fetch error:', error.message);
                return;
            }

            if (!specials || specials.length === 0) return;

            // Rebuild specials grid with live data
            grid.innerHTML = '';
            specials.forEach((item, idx) => {
                const delayClass = idx % 6 === 0 ? '' : `delay-${idx % 6}`;
                const premiumClass = item.is_new ? 'premium-item' : '';
                const dims = getImageDimensions(item.image_url);

                const card = document.createElement('div');
                card.className = `menu-item fade-up visible ${premiumClass} ${delayClass}`.trim();

                card.innerHTML = `
                    <img src="${item.image_url}" alt="${item.name}" class="menu-img" width="${dims.w}" height="${dims.h}" loading="lazy">
                    <div class="dish-info">
                        <div class="dish-header">
                            <h4>${item.name}</h4>
                            <span class="price">Rs. ${item.price}</span>
                        </div>
                        <p class="dish-desc">${item.description || ''}</p>
                    </div>
                `;
                grid.appendChild(card);
            });

            console.info(`[TreatUp] Successfully hydrated ${specials.length} specials from Supabase.`);
        } catch (e) {
            console.warn('[TreatUp] Error during specials hydration:', e);
        }
    }

    // Hydrate Menu Page Regular Items & Liquor Table
    async function hydrateMenuPage(client) {
        const menuContent = document.querySelector('#menu-content');
        if (!menuContent) return;

        try {
            // 1. Hydrate Menu Items
            const { data: menuItems, error: menuErr } = await client
                .from('menu_items')
                .select('*')
                .eq('is_active', true)
                .order('sort_order', { ascending: true });

            if (menuErr) {
                console.warn('[TreatUp] Supabase menu items fetch error:', menuErr.message);
            } else if (menuItems && menuItems.length > 0) {
                const domItems = document.querySelectorAll('.menu-list-item');
                let updatedCount = 0;

                menuItems.forEach(item => {
                    const normItemName = normalizeText(item.name);
                    for (const domItem of domItems) {
                        const nameEl = domItem.querySelector('.item-name');
                        if (!nameEl) continue;

                        if (normalizeText(nameEl.textContent) === normItemName) {
                            // 1. Update Price
                            const priceEl = domItem.querySelector('.item-price');
                            if (priceEl) {
                                if (priceEl.innerHTML.includes('Veg:') && priceEl.innerHTML.includes('Non-Veg:')) {
                                    // Preserve dual Veg/Non-Veg structure
                                    priceEl.innerHTML = `<span>Veg: Rs. ${item.price}/-</span> <span class="ml-2">Non-Veg: Rs. ${item.price}/-</span>`;
                                } else if (priceEl.textContent.includes('(Stick)')) {
                                    priceEl.textContent = `Rs. ${item.price}/- (Stick)`;
                                } else {
                                    priceEl.textContent = `Rs. ${item.price}/-`;
                                }
                            }

                            // 2. Update NEW Badge
                            const existingBadge = domItem.querySelector('.inline-new-badge');
                            if (item.is_new && !existingBadge) {
                                // Add badge
                                const parent = nameEl.parentElement;
                                if (!parent.classList.contains('item-name-group')) {
                                    const group = document.createElement('div');
                                    group.className = 'item-name-group';
                                    parent.insertBefore(group, nameEl);
                                    group.appendChild(nameEl);
                                    const badge = document.createElement('span');
                                    badge.className = 'inline-new-badge';
                                    badge.textContent = 'NEW';
                                    group.appendChild(badge);
                                }
                            } else if (!item.is_new && existingBadge) {
                                // Remove badge
                                existingBadge.remove();
                            }

                            updatedCount++;
                            break;
                        }
                    }
                });
                console.info(`[TreatUp] Successfully hydrated ${updatedCount} menu items from Supabase.`);
            }

            // 2. Hydrate Liquor Table
            const { data: liquorItems, error: liqErr } = await client
                .from('liquor_items')
                .select('*')
                .eq('is_active', true)
                .order('sort_order', { ascending: true });

            if (liqErr) {
                console.warn('[TreatUp] Supabase liquor items fetch error:', liqErr.message);
            } else if (liquorItems && liquorItems.length > 0) {
                const table = document.querySelector('.liquor-table');
                if (table) {
                    const rows = table.querySelectorAll('tr');
                    liquorItems.forEach(item => {
                        const normBrand = normalizeText(item.brand);
                        for (const row of rows) {
                            const cells = row.querySelectorAll('td');
                            if (cells.length >= 5 && normalizeText(cells[0].textContent) === normBrand) {
                                cells[1].textContent = item.ml_60 ? `${item.ml_60}/-` : '-';
                                cells[2].textContent = item.qtr ? `${item.qtr}/-` : '-';
                                cells[3].textContent = item.half ? `${item.half}/-` : '-';
                                cells[4].textContent = item.full ? `${item.full}/-` : '-';
                                break;
                            }
                        }
                    });
                    console.info(`[TreatUp] Successfully hydrated liquor table with ${liquorItems.length} brands.`);
                }
            }

            // Re-attach WhatsApp copy buttons to dynamic items
            attachCopyButtons();
        } catch (e) {
            console.warn('[TreatUp] Error during menu page hydration:', e);
        }
    }

    // Main Init
    function init() {
        // 1. Guard against unconfigured or placeholder credentials
        const isUrlMissing = typeof SUPABASE_URL === 'undefined' || !SUPABASE_URL || SUPABASE_URL.includes('YOUR_SUPABASE');
        const isKeyMissing = typeof SUPABASE_ANON_KEY === 'undefined' || !SUPABASE_ANON_KEY || SUPABASE_ANON_KEY.includes('YOUR_SUPABASE');

        if (isUrlMissing || isKeyMissing) {
            console.info('[TreatUp] Supabase credentials not configured. Serving static offline menu.');
            return;
        }

        // 2. Guard against missing supabase CDN library
        if (typeof window.supabase === 'undefined' || typeof window.supabase.createClient !== 'function') {
            console.info('[TreatUp] Supabase client library not loaded. Serving static offline menu.');
            return;
        }

        // 3. Initialize Supabase client
        try {
            const client = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

            // Execute appropriate hydrator
            if (document.querySelector('#menu .menu-grid')) {
                hydrateSpecials(client);
            }
            if (document.querySelector('#menu-content')) {
                hydrateMenuPage(client);
            }
        } catch (err) {
            console.warn('[TreatUp] Supabase client initialization failed:', err);
        }
    }

    // Run on DOM ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
