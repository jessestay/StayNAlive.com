/**
 * Navigation functionality
 */
(function() {
    'use strict';

    class Navigation {
        constructor() {
            this.mobileToggle = document.querySelector('.mobile-menu-toggle');
            this.mobileMenu = document.querySelector('.mobile-menu');
            this.init();
        }

        init() {
            if (this.mobileToggle && this.mobileMenu) {
                this.mobileToggle.addEventListener('click', () => this.toggleMobileMenu());
            }

            // Close menu on escape key
            document.addEventListener('keydown', (e) => {
                if (e.key === 'Escape') {
                    this.closeMobileMenu();
                }
            });

            // Close menu when clicking outside
            document.addEventListener('click', (e) => {
                if (!this.mobileMenu.contains(e.target) && !this.mobileToggle.contains(e.target)) {
                    this.closeMobileMenu();
                }
            });
        }

        toggleMobileMenu() {
            this.mobileMenu.classList.toggle('is-active');
            this.mobileToggle.setAttribute('aria-expanded', 
                this.mobileMenu.classList.contains('is-active'));
        }

        closeMobileMenu() {
            this.mobileMenu.classList.remove('is-active');
            this.mobileToggle.setAttribute('aria-expanded', 'false');
        }
    }

    // Initialize navigation
    document.addEventListener('DOMContentLoaded', () => {
        new Navigation();
    });
})(); 