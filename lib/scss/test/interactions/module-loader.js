/**
 * Modular HTML Component Loader
 * Dynamically loads HTML modules into the main page
 */

class ModuleLoader {
    constructor() {
        this.modules = [
            { id: 'stats-showcase', path: 'components/stats-showcase.html' },
            { id: 'features-showcase', path: 'components/features-showcase.html' },
            { id: 'buttons-showcase', path: 'components/buttons-showcase.html' },
            { id: 'cards-showcase', path: 'components/cards-showcase.html' },
            { id: 'animations-showcase', path: 'components/animations-showcase.html' },
            { id: 'pricing-showcase', path: 'components/pricing-showcase.html' },
            { id: 'testimonials-showcase', path: 'components/testimonials-showcase.html' }
        ];
        this.init();
    }

    async init() {
        console.log('🚀 Loading component modules...');
        
        // Check if we're on localhost or file://
        const isLocalhost = window.location.protocol.startsWith('http');
        
        if (!isLocalhost) {
            console.error('⚠️  Please run this page on a local server to use dynamic components.');
            console.log('Run: cd test && python3 -m http.server 8080');
            console.log('Then open: http://localhost:8080/index.html');
            this.showServerRequiredMessage();
            return;
        }

        await this.loadAllModules();
        console.log('✅ All modules loaded successfully!');
        this.initializeInteractions();
    }

    showServerRequiredMessage() {
        const message = document.createElement('div');
        message.className = 'alert alert-warning';
        message.innerHTML = `
            <div class="alert-icon">⚠️</div>
            <div class="alert-content">
                <div class="alert-title">Local Server Required</div>
                <div class="alert-message">
                    Please run a local web server to use dynamic components.<br>
                    <code style="background: rgba(0,0,0,0.1); padding: 0.25rem 0.5rem; border-radius: 0.25rem; display: inline-block; margin-top: 0.5rem;">
                        cd test && python3 -m http.server 8080
                    </code>
                </div>
            </div>
        `;
        
        // Insert at top of body
        if (document.body.firstChild) {
            document.body.insertBefore(message, document.body.firstChild);
        } else {
            document.body.appendChild(message);
        }
    }

    async loadAllModules() {
        const promises = this.modules.map(module => this.loadModule(module.id, module.path));
        await Promise.all(promises);
    }

    async loadModule(containerId, path) {
        const container = document.getElementById(containerId);
        if (!container) {
            console.warn(`Container #${containerId} not found`);
            return;
        }

        // Show loading state
        container.innerHTML = `
            <div class="text-center py-20">
                <div class="spinner mb-4" style="margin: 0 auto;"></div>
                <p class="text-muted">Loading ${path}...</p>
            </div>
        `;

        try {
            const response = await fetch(path);
            if (response.ok) {
                const html = await response.text();
                container.innerHTML = html;
                console.log(`✓ Loaded: ${path}`);
            } else {
                console.error(`Failed to load: ${path} (${response.status})`);
                container.innerHTML = `
                    <div class="container py-12">
                        <div class="alert alert-danger">
                            <div class="alert-icon">❌</div>
                            <div class="alert-content">
                                <div class="alert-title">Module Load Error</div>
                                <div class="alert-message">Failed to load ${path} (${response.status})</div>
                            </div>
                        </div>
                    </div>
                `;
            }
        } catch (error) {
            console.error(`Error loading ${path}:`, error);
            container.innerHTML = `
                <div class="container py-12">
                    <div class="alert alert-danger">
                        <div class="alert-icon">❌</div>
                        <div class="alert-content">
                            <div class="alert-title">Network Error</div>
                            <div class="alert-message">Could not load ${path}. ${error.message}</div>
                        </div>
                    </div>
                </div>
            `;
        }
    }

    initializeInteractions() {
        // Smooth scroll for anchor links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', (e) => {
                e.preventDefault();
                const targetId = anchor.getAttribute('href');
                const target = document.querySelector(targetId);
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });

        // Add scroll reveal animation observer
        this.initScrollReveal();
    }

    initScrollReveal() {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('revealed');
                }
            });
        }, {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        });

        document.querySelectorAll('.reveal-up, .reveal-left, .reveal-right').forEach(el => {
            observer.observe(el);
        });
    }
}

// Initialize on DOM ready
document.addEventListener('DOMContentLoaded', () => {
    new ModuleLoader();
});
