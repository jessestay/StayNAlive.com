document.addEventListener('DOMContentLoaded', function () {
    const languageSwitchers = document.querySelectorAll('.language-switcher');

    languageSwitchers.forEach(switcher => {
        const button = switcher.querySelector('.language-switcher-toggle');
        const dropdown = switcher.querySelector('.language-switcher-dropdown');
        const links = dropdown.querySelectorAll('a');

        // Toggle dropdown
        button.addEventListener('click', () => {
            const isExpanded = button.getAttribute('aria-expanded') === 'true';
            button.setAttribute('aria-expanded', !isExpanded);
            dropdown.classList.toggle('is-active');
        });

        // Close dropdown when clicking outside
        document.addEventListener('click', e => {
            if (!switcher.contains(e.target)) {
                button.setAttribute('aria-expanded', 'false');
                dropdown.classList.remove('is-active');
            }
        });

        // Keyboard navigation
        button.addEventListener('keydown', e => {
            if (e.key === 'ArrowDown' || e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                button.setAttribute('aria-expanded', 'true');
                dropdown.classList.add('is-active');
                links[0].focus();
            }
        });

        // Handle keyboard navigation within dropdown
        dropdown.addEventListener('keydown', e => {
            const currentLink = event.target.ownerDocument.activeElement;
            const currentIndex = Array.from(links).indexOf(currentLink);

            switch (e.key) {
                case 'ArrowDown':
                    e.preventDefault();
                    if (currentIndex < links.length - 1) {
                        links[currentIndex + 1].focus();
                    }
                    break;
                case 'ArrowUp':
                    e.preventDefault();
                    if (currentIndex > 0) {
                        links[currentIndex - 1].focus();
                    } else {
                        button.focus();
                    }
                    break;
                case 'Escape':
                    e.preventDefault();
                    button.setAttribute('aria-expanded', 'false');
                    dropdown.classList.remove('is-active');
                    button.focus();
                    break;
            }
        });
    });
});
