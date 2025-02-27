/**
 * Social feed functionality
 */

class SocialFeed {
    /**
     * Initialize social feed
     */
    constructor() {
        this.currentFeed = 'instagram';
        this.feeds = {
            instagram: [],
            tiktok: [],
            youtube: [],
            twitter: [],
        };
        this.init();
    }

    /**
     * Initialize feed functionality
     */
    async init() {
        try {
            const data = await this.fetchFeed();
            this.renderFeed(data);
        } catch (error) {
            console.error('Failed to fetch social feed:', error);
            this.handleError(error);
        }
    }

    /**
     * Fetch feed data
     *
     * @return {Promise} Feed data
     */
    async fetchFeed() {
        const response = await fetch('/wp-json/staynalive/v1/social-feed');
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
    }

    /**
     * Render feed data
     *
     * @param {Object} data Feed data to render
     */
    renderFeed(data) {
        const container = document.querySelector('.social-feed');
        if (!container) {
            return;
        }

        container.innerHTML = this.formatFeedData(data);
    }

    /**
     * Handle errors
     *
     * @param {Error} error Error to handle
     */
    handleError(error) {
        const container = document.querySelector('.social-feed');
        if (container) {
            container.innerHTML = `<p class="error">Failed to load social feed: ${error.message}</p>`;
        }
    }

    /**
     * Format feed data for display
     *
     * @param {Object} data Feed data to format
     * @return {string} Formatted HTML
     */
    formatFeedData(data) {
        return data
            .map(
                item => `
            <div class="social-feed-item">
                <h3>${item.title}</h3>
                <p>${item.content}</p>
            </div>
        `
            )
            .join('');
    }
}

export default SocialFeed;
