class ShareThis {
    constructor(config = {}) {
        this.config = {
            networks: ['facebook', 'twitter', 'linkedin', 'email'],
            alignment: 'left',
            fontSize: 16,
            ...config
        };
        
        this.init();
    }

    init() {
        if (document.getElementById('sharethis-script')) {
            return;
        }

        const script = document.createElement('script');
        script.id = 'sharethis-script';
        script.src = 'https://platform-api.sharethis.com/js/sharethis.js';
        script.async = true;
        
        script.onload = () => this.configure();
        document.head.appendChild(script);
    }

    configure() {
        if (window.sharethis) {
            window.sharethis.configure(this.config);
        }
    }
} 