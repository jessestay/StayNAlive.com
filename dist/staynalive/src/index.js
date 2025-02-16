// Initial webpack entry point
console.log('Theme initialized');

// Import styles
import '../assets/css/base/base.css';

// Import modules
import SocialFeed from '../assets/js/social-feed';

// Initialize components
document.addEventListener('DOMContentLoaded', () => {
    if (document.querySelector('.social-feed')) {
        new SocialFeed();
    }
}); 