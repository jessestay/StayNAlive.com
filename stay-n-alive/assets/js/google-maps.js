// Google Maps Widget Integration
function initGoogleMapsWidget() {
    const mapElements = document.querySelectorAll('.gmw-map');
    const apiKey = 'AIzaSyB5UXGleTjfdmWGLizMER67FQcX_nyDzQ4';  // From original site
    
    mapElements.forEach(element => {
        const location = element.dataset.location;
        const zoom = element.dataset.zoom || 14;
        const iframe = document.createElement('iframe');
        
        iframe.src = `https://www.google.com/maps/embed/v1/place?key=${apiKey}&q=${encodeURIComponent(location)}&zoom=${zoom}`;
        iframe.width = '100%';
        iframe.height = element.dataset.height || '300';
        iframe.style.border = '0';
        iframe.allowFullscreen = true;
        
        element.appendChild(iframe);
    });
}

document.addEventListener('DOMContentLoaded', initGoogleMapsWidget);
