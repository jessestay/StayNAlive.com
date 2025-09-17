class GoogleMapsLoader {
    constructor(apiKey) {
        this.apiKey = apiKey;
        this.maps = new Map();
    }

    loadAPI() {
        return new Promise((resolve, reject) => {
            if (window.google && window.google.maps) {
                resolve(window.google.maps);
                return;
            }

            const script = document.createElement('script');
            script.src = `https://maps.googleapis.com/maps/api/js?key=${this.apiKey}`;
            script.async = true;
            script.defer = true;
            
            script.onload = () => resolve(window.google.maps);
            script.onerror = () => reject(new Error('Failed to load Google Maps API'));
            
            document.head.appendChild(script);
        });
    }

    async initMap(elementId, options = {}) {
        try {
            const maps = await this.loadAPI();
            const element = document.getElementById(elementId);
            
            if (!element) {
                throw new Error(`Element with ID ${elementId} not found`);
            }

            const map = new maps.Map(element, {
                zoom: options.zoom || 12,
                center: options.center || { lat: -34.397, lng: 150.644 },
                ...options
            });

            this.maps.set(elementId, map);
            return map;
        } catch (error) {
            console.error('Error initializing map:', error);
            throw error;
        }
    }
} 