/**
 * Dynamic Component Grid System
 * Automatically layouts components in a responsive grid with consistent sizing
 */

class ComponentGrid {
    constructor(containerId, options = {}) {
        this.container = document.getElementById(containerId);
        if (!this.container) {
            console.error(`Container #${containerId} not found`);
            return;
        }

        // Default options
        this.options = {
            minCardWidth: 280,        // Minimum card width in px
            maxCardWidth: 400,        // Maximum card width in px
            gap: 24,                  // Gap between cards in px
            padding: 32,              // Container padding in px
            aspectRatio: 1.2,         // Card height = width / aspectRatio
            animationDelay: 50,       // Delay between card animations in ms
            ...options
        };

        this.components = [];
        this.init();
    }

    init() {
        this.setupContainer();
        this.setupResizeObserver();
    }

    setupContainer() {
        this.container.style.display = 'grid';
        this.container.style.padding = `${this.options.padding}px`;
        this.container.style.gap = `${this.options.gap}px`;
        this.updateGrid();
    }

    setupResizeObserver() {
        // Update grid on window resize
        let resizeTimeout;
        window.addEventListener('resize', () => {
            clearTimeout(resizeTimeout);
            resizeTimeout = setTimeout(() => {
                this.updateGrid();
            }, 150);
        });
    }

    updateGrid() {
        const containerWidth = this.container.offsetWidth - (this.options.padding * 2);
        
        // Calculate optimal number of columns
        const columns = this.calculateColumns(containerWidth);
        
        // Calculate card width
        const totalGap = this.options.gap * (columns - 1);
        const cardWidth = (containerWidth - totalGap) / columns;
        
        // Update grid template
        this.container.style.gridTemplateColumns = `repeat(${columns}, 1fr)`;
        
        // Update all cards
        const cards = this.container.querySelectorAll('.component-card');
        cards.forEach(card => {
            const cardHeight = cardWidth / this.options.aspectRatio;
            card.style.height = `${cardHeight}px`;
        });

        console.log(`Grid updated: ${columns} columns, ${cardWidth.toFixed(0)}px per card`);
    }

    calculateColumns(containerWidth) {
        // Calculate how many cards can fit
        let columns = 1;
        
        while (true) {
            const totalGap = this.options.gap * (columns - 1);
            const cardWidth = (containerWidth - totalGap) / columns;
            
            // Check if card width is within acceptable range
            if (cardWidth < this.options.minCardWidth) {
                return Math.max(1, columns - 1);
            }
            
            if (cardWidth <= this.options.maxCardWidth) {
                return columns;
            }
            
            columns++;
            
            // Safety limit
            if (columns > 6) return 6;
        }
    }

    addComponent(component) {
        const card = this.createCard(component);
        this.container.appendChild(card);
        this.components.push(component);
        
        // Trigger animation
        setTimeout(() => {
            card.classList.add('revealed');
        }, this.components.length * this.options.animationDelay);
        
        // Update grid after adding
        this.updateGrid();
        
        return card;
    }

    createCard(component) {
        const card = document.createElement('div');
        card.className = 'component-card reveal-up';
        
        // Create card structure
        card.innerHTML = `
            <div class="component-card-inner">
                <div class="component-preview">
                    ${component.preview || ''}
                </div>
                <div class="component-info">
                    <h4 class="component-title">${component.title || 'Component'}</h4>
                    ${component.description ? `<p class="component-description">${component.description}</p>` : ''}
                    ${component.classes ? `<code class="component-classes">${component.classes}</code>` : ''}
                </div>
                ${component.interactive ? '<div class="component-interactive-badge">Interactive</div>' : ''}
            </div>
        `;
        
        // Add click handler if provided
        if (component.onClick) {
            card.style.cursor = 'pointer';
            card.addEventListener('click', () => component.onClick(card));
        }
        
        return card;
    }

    addComponents(components) {
        components.forEach(comp => this.addComponent(comp));
    }

    clear() {
        this.container.innerHTML = '';
        this.components = [];
    }

    setAspectRatio(ratio) {
        this.options.aspectRatio = ratio;
        this.updateGrid();
    }

    setGap(gap) {
        this.options.gap = gap;
        this.container.style.gap = `${gap}px`;
        this.updateGrid();
    }
}

// Export for use in other files
window.ComponentGrid = ComponentGrid;
