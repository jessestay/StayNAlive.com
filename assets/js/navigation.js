/**
 * Navigation handling for mobile menu and accessibility
 */

(() => {
    const navigation = {
        init() {
            this.mobileToggle = document.querySelector(
                '.wp-block-navigation__responsive-container-open'
            );
            this.mobileMenu = document.querySelector('.wp-block-navigation__responsive-container');
            this.closeButton = document.querySelector(
                '.wp-block-navigation__responsive-container-close'
            );
            this.overlay = document.querySelector(
                '.wp-block-navigation__responsive-container-overlay'
            );

            this.bindEvents();
            this.setupAccessibility();
        },

        bindEvents() {
            // Mobile menu toggle
            if (this.mobileToggle) {
                this.mobileToggle.addEventListener('click', () => this.toggleMobileMenu());
            }

            // Close button
            if (this.closeButton) {
                this.closeButton.addEventListener('click', () => this.closeMobileMenu());
            }

            // Close on overlay click
            if (this.overlay) {
                this.overlay.addEventListener('click', () => this.closeMobileMenu());
            }

            // Close on escape key
            document.addEventListener('keydown', e => {
                if (e.key === 'Escape') {
                    this.closeMobileMenu();
                }
            });

            // Handle window resize
            window.addEventListener('resize', () => {
                if (window.innerWidth > 980) {
                    this.closeMobileMenu();
                }
            });
        },

        setupAccessibility() {
            // Add aria attributes to submenus
            const subMenus = document.querySelectorAll('.wp-block-navigation-submenu');
            subMenus.forEach(menu => {
                const toggle = menu.querySelector('.wp-block-navigation-submenu__toggle');
                const content = menu.querySelector('.wp-block-navigation-submenu__content');

                if (toggle && content) {
                    toggle.setAttribute('aria-expanded', 'false');
                    content.setAttribute('aria-hidden', 'true');

                    toggle.addEventListener('click', e => {
                        e.preventDefault();
                        const isExpanded = toggle.getAttribute('aria-expanded') === 'true';
                        toggle.setAttribute('aria-expanded', !isExpanded);
                        content.setAttribute('aria-hidden', isExpanded);
                    });
                }
            });

            // Handle keyboard navigation
            document.addEventListener('keydown', e => {
                if (e.key === 'Tab') {
                    document.body.classList.add('user-is-tabbing');
                }
            });

            document.addEventListener('mousedown', () => {
                document.body.classList.remove('user-is-tabbing');
            });
        },

        toggleMobileMenu() {
            if (this.mobileMenu) {
                const isOpen = this.mobileMenu.classList.contains('is-menu-open');
                this.mobileMenu.classList.toggle('is-menu-open');
                document.body.style.overflow = isOpen ? '' : 'hidden';

                if (this.mobileToggle) {
                    this.mobileToggle.setAttribute('aria-expanded', !isOpen);
                }
            }
        },

        closeMobileMenu() {
            if (this.mobileMenu && this.mobileMenu.classList.contains('is-menu-open')) {
                this.mobileMenu.classList.remove('is-menu-open');
                document.body.style.overflow = '';

                if (this.mobileToggle) {
                    this.mobileToggle.setAttribute('aria-expanded', 'false');
                }
            }
        },
    };

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => navigation.init());
    } else {
        navigation.init();
    }
})();
