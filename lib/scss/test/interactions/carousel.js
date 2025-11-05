/**
 * Enhanced Carousel Interactions
 * Adds keyboard navigation and touch swipe support
 */

class CarouselEnhancer {
    constructor(carouselElement) {
        this.carousel = carouselElement;
        this.slides = Array.from(carouselElement.querySelectorAll('.carousel-nav'));
        this.currentSlide = 0;
        this.init();
    }

    init() {
        this.addKeyboardNavigation();
        this.addTouchSwipe();
        this.addAutoplay();
    }

    addKeyboardNavigation() {
        document.addEventListener('keydown', (e) => {
            if (e.key === 'ArrowLeft') this.prevSlide();
            if (e.key === 'ArrowRight') this.nextSlide();
        });
    }

    addTouchSwipe() {
        let touchStartX = 0;
        let touchEndX = 0;

        this.carousel.addEventListener('touchstart', (e) => {
            touchStartX = e.changedTouches[0].screenX;
        });

        this.carousel.addEventListener('touchend', (e) => {
            touchEndX = e.changedTouches[0].screenX;
            this.handleSwipe(touchStartX, touchEndX);
        });
    }

    handleSwipe(start, end) {
        const threshold = 50;
        const diff = start - end;

        if (Math.abs(diff) > threshold) {
            if (diff > 0) this.nextSlide();
            else this.prevSlide();
        }
    }

    nextSlide() {
        this.currentSlide = (this.currentSlide + 1) % this.slides.length;
        this.slides[this.currentSlide].checked = true;
    }

    prevSlide() {
        this.currentSlide = (this.currentSlide - 1 + this.slides.length) % this.slides.length;
        this.slides[this.currentSlide].checked = true;
    }

    addAutoplay(interval = 5000) {
        if (this.carousel.classList.contains('carousel-autoplay')) {
            this.autoplayInterval = setInterval(() => this.nextSlide(), interval);
            
            // Pause on hover
            this.carousel.addEventListener('mouseenter', () => {
                clearInterval(this.autoplayInterval);
            });
            
            this.carousel.addEventListener('mouseleave', () => {
                this.autoplayInterval = setInterval(() => this.nextSlide(), interval);
            });
        }
    }
}

// Initialize all carousels
document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.carousel').forEach(carousel => {
        new CarouselEnhancer(carousel);
    });
});
