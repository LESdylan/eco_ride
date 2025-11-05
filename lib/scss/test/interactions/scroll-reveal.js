/**
 * Scroll Reveal Animations
 * Triggers animations when elements enter viewport
 */

class ScrollReveal {
    constructor(options = {}) {
        this.options = {
            threshold: 0.15,
            rootMargin: '0px 0px -50px 0px',
            ...options
        };
        this.init();
    }

    init() {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('revealed');
                    // Optionally unobserve after reveal
                    // observer.unobserve(entry.target);
                }
            });
        }, this.options);

        // Observe all reveal elements
        document.querySelectorAll('[class*="reveal-"]').forEach(el => {
            observer.observe(el);
        });
    }
}

// Initialize on DOM ready
document.addEventListener('DOMContentLoaded', () => {
    new ScrollReveal();
});
