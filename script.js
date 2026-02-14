document.addEventListener('DOMContentLoaded', () => {

    // --- 1. Custom Cursor Logic ---
    const cursorDot = document.createElement('div');
    const cursorOutline = document.createElement('div');
    cursorDot.className = 'cursor-dot';
    cursorOutline.className = 'cursor-outline';
    document.body.appendChild(cursorDot);
    document.body.appendChild(cursorOutline);

    window.addEventListener('mousemove', (e) => {
        const posX = e.clientX;
        const posY = e.clientY;

        // Dot follows instantly
        cursorDot.style.left = `${posX}px`;
        cursorDot.style.top = `${posY}px`;

        // Outline follows with slight delay (handled via CSS transition or simple animation frame)
        // Using simple keyframe effect for smoother lag
        cursorOutline.animate({
            left: `${posX}px`,
            top: `${posY}px`
        }, { duration: 500, fill: "forwards" });
    });

    // Add hover state to interactive elements
    const interactiveElements = document.querySelectorAll('a, button, .menu-item, .gallery-card, input, select');
    interactiveElements.forEach(el => {
        el.addEventListener('mouseenter', () => document.body.classList.add('hovering'));
        el.addEventListener('mouseleave', () => document.body.classList.remove('hovering'));
    });

    // --- 2. Magnetic Buttons ---
    // --- 2. Magnetic Buttons ---
    const magneticBtns = document.querySelectorAll('.btn, .nav-link, .social-btn, .whatsapp-float');

    magneticBtns.forEach(btn => {
        btn.addEventListener('mousemove', (e) => {
            const rect = btn.getBoundingClientRect();
            const x = e.clientX - rect.left - rect.width / 2;
            const y = e.clientY - rect.top - rect.height / 2;

            // Adjust strength
            btn.style.transform = `translate(${x * 0.2}px, ${y * 0.2}px)`;
        });

        btn.addEventListener('mouseleave', () => {
            btn.style.transform = 'translate(0px, 0px)';
        });
    });

    // --- 2.1 WhatsApp Periodic Wiggle ---
    const whatsappIcon = document.querySelector('.whatsapp-float ion-icon');
    if (whatsappIcon) {
        setInterval(() => {
            whatsappIcon.classList.add('wiggle');
            setTimeout(() => {
                whatsappIcon.classList.remove('wiggle');
            }, 1000); // 1s wiggle duration
        }, 5000); // Every 5 seconds
    }

    // --- 3. Text & Image Reveal Animations (Observer) ---
    // Update existing observer to handle new reveal classes
    // We convert standard fade-ups to reveals in HTML or handle both here.

    // Convert generic titles to split reveal if needed, 
    // or just observe the explicit .reveal-text classes we will add in HTML

    const observerOptions = {
        threshold: 0.15,
        rootMargin: "0px 0px -50px 0px"
    };

    const observer = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    const animatedElements = document.querySelectorAll('.fade-up, .reveal-text, .reveal-img, .menu-grid');
    animatedElements.forEach(el => observer.observe(el));


    // --- 4. Existing Logic Preserved ---

    // Navigation Scroll
    const navbar = document.getElementById('navbar');
    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    });

    // Mobile Menu
    const mobileBtn = document.getElementById('mobile-menu-btn');
    const navList = document.getElementById('nav-list');
    const navLinks = document.querySelectorAll('.nav-link');

    mobileBtn.addEventListener('click', () => {
        navList.classList.toggle('active');
        mobileBtn.classList.toggle('active');
    });

    navLinks.forEach(link => {
        link.addEventListener('click', () => {
            navList.classList.remove('active');
            mobileBtn.classList.remove('active'); // Start fresh - remove active class from button too
        });
    });

    // Menu Tabs
    const tabBtns = document.querySelectorAll('.tab-btn');
    const menuGrids = document.querySelectorAll('.menu-grid');

    tabBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            tabBtns.forEach(b => b.classList.remove('active'));
            menuGrids.forEach(g => g.classList.remove('active'));

            btn.classList.add('active');
            const targetId = btn.getAttribute('data-tab');
            const targetGrid = document.getElementById(targetId);
            if (targetGrid) {
                targetGrid.classList.add('active');
            }
        });
    });

    // Parallax
    // Parallax
    const parallaxBg = document.querySelector('.parallax-bg');
    let scrollY = 0;

    window.addEventListener('scroll', () => {
        scrollY = window.pageYOffset;
    });

    function parallaxLoop() {
        if (parallaxBg) {
            // Apply transform in animation frame
            parallaxBg.style.transform = `translateY(${scrollY * 0.4}px)`;
        }
        requestAnimationFrame(parallaxLoop);
    }

    // Start the loop
    requestAnimationFrame(parallaxLoop);

    // Order Modal Logic
    const modal = document.getElementById('order-modal');
    const openBtn = document.getElementById('open-order-modal');
    const closeBtn = document.querySelector('.close-modal');

    if (openBtn && modal && closeBtn) {
        openBtn.addEventListener('click', (e) => {
            e.preventDefault();
            modal.classList.add('show');
        });

        closeBtn.addEventListener('click', () => {
            modal.classList.remove('show');
        });

        window.addEventListener('click', (e) => {
            if (e.target === modal) {
                modal.classList.remove('show');
            }
        });
    }

    // --- 5. Smart Order Features & Full Menu Toggle ---

    // Function to inject copy buttons
    function injectCopyButtons() {
        const menuItems = document.querySelectorAll('.item-name');
        menuItems.forEach(item => {
            // Check if icon already exists
            if (item.querySelector('.copy-btn')) return;

            // Create Icon
            const copyIcon = document.createElement('ion-icon');
            copyIcon.setAttribute('name', 'copy-outline');
            copyIcon.classList.add('copy-btn');
            copyIcon.setAttribute('title', 'Copy to Order');

            // Append to item name
            item.appendChild(copyIcon);

            // Click Event
            copyIcon.addEventListener('click', (e) => {
                e.stopPropagation();
                // Get text node content only (exclude the icon itself)
                const text = item.childNodes[0].textContent.trim();

                navigator.clipboard.writeText(text).then(() => {
                    // Feedback
                    const originalIcon = copyIcon.getAttribute('name');
                    copyIcon.setAttribute('name', 'checkmark-circle');
                    copyIcon.style.color = '#25d366'; // WhatsApp Green

                    showToast(`Copied: "${text}"`);

                    setTimeout(() => {
                        copyIcon.setAttribute('name', 'copy-outline');
                        copyIcon.style.color = ''; // Reset
                    }, 2000);
                }).catch(err => {
                    console.error('Failed to copy', err);
                });
            });
        });
    }

    // Initial Injection
    injectCopyButtons();



    // --- 6. Scrollbar Auto-Hide ---
    const scrollContainers = document.querySelectorAll('.category-scroll, .table-responsive');
    scrollContainers.forEach(container => {
        let isScrolling;
        container.addEventListener('scroll', () => {
            window.clearTimeout(isScrolling);
            container.classList.add('scrolling');
            isScrolling = setTimeout(() => {
                container.classList.remove('scrolling');
            }, 300); // Disappear after 0.3s
        });
    });

}); // End of DOMContentLoaded

// Toast Notification helper (outside DOMContentLoaded)
function showToast(message) {
    let toast = document.getElementById('toast');
    if (!toast) {
        toast = document.createElement('div');
        toast.id = 'toast';
        document.body.appendChild(toast);
    }
    toast.textContent = message;
    toast.className = 'show';
    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}
