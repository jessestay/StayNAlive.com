/**
 * Animation utilities
 */
(function() {
    'use strict';

    class Animator {
        constructor() {
            this.observeElements();
        }

        observeElements() {
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('is-visible');
                        observer.unobserve(entry.target);
                    }
                });
            }, {
                threshold: 0.1
            });

            document.querySelectorAll('.animate-on-scroll').forEach(element => {
                observer.observe(element);
            });
        }

        static fadeIn(element, duration = 500) {
            element.style.opacity = 0;
            element.style.transition = `opacity ${duration}ms ease`;
            
            requestAnimationFrame(() => {
                element.style.opacity = 1;
            });
        }

        static slideUp(element, duration = 500) {
            element.style.transform = 'translateY(20px)';
            element.style.opacity = 0;
            element.style.transition = `transform ${duration}ms ease, opacity ${duration}ms ease`;
            
            requestAnimationFrame(() => {
                element.style.transform = 'translateY(0)';
                element.style.opacity = 1;
            });
        }
    }

    // Initialize animations
    document.addEventListener('DOMContentLoaded', () => {
        new Animator();
    });
})(); 