document.addEventListener('DOMContentLoaded', function () {
    const schemes = [
        { name: 'default', primary: '#0073aa', accent: '#00a0d2' },
        { name: 'sunset', primary: '#ff6b6b', accent: '#ffd93d' },
        { name: 'forest', primary: '#6b9080', accent: '#a4c3b2' },
        { name: 'ocean', primary: '#1a535c', accent: '#4ecdc4' },
    ];

    // Create color scheme selector
    const selector = document.createElement('div');
    selector.className = 'color-scheme-selector';

    schemes.forEach(scheme => {
        const option = document.createElement('button');
        option.className = 'color-scheme-option';
        option.style.background = `linear-gradient(135deg, ${scheme.primary}, ${scheme.accent})`;
        option.setAttribute('data-scheme', scheme.name);
        option.setAttribute('aria-label', `Switch to ${scheme.name} theme`);

        option.addEventListener('click', () => {
            document.body.setAttribute('data-theme', scheme.name);
            localStorage.setItem('preferred-theme', scheme.name);
        });

        selector.appendChild(option);
    });

    document.body.appendChild(selector);

    // Load saved preference
    const savedTheme = localStorage.getItem('preferred-theme');
    if (savedTheme) {
        document.body.setAttribute('data-theme', savedTheme);
    }
});
