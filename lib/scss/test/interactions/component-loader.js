/**
 * Component Loader
 * Loads HTML components dynamically
 */

class ComponentLoader {
    constructor() {
        this.components = {
            'header-component': 'components/header.html',
            'hero-component': 'components/hero.html',
            'carousel-component': 'components/carousel-showcase.html',
            'animations-2d-component': 'components/animations-2d.html',
            'animations-3d-component': 'components/animations-3d.html',
        };
        this.loadComponents();
    }

    async loadComponents() {
        for (const [id, path] of Object.entries(this.components)) {
            await this.loadComponent(id, path);
        }
        this.initializeAfterLoad();
    }

    async loadComponent(elementId, path) {
        const element = document.getElementById(elementId);
        if (!element) return;

        try {
            const response = await fetch(path);
            if (response.ok) {
                const html = await response.text();
                element.innerHTML = html;
            } else {
                console.warn(`Failed to load component: ${path}`);
            }
        } catch (error) {
            console.error(`Error loading component ${path}:`, error);
        }
    }

    initializeAfterLoad() {
        // Smooth scroll for navigation links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
            });
        });
    }
}

// Initialize component loader
document.addEventListener('DOMContentLoaded', () => {
    new ComponentLoader();
});
