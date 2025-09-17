/**
 * Social feed functionality
 */
(function() {
    'use strict';

    class SocialFeed {
        constructor(element) {
            this.element = element;
            this.type = element.dataset.type;
            this.count = parseInt(element.dataset.count, 10);
            this.init();
        }

        async init() {
            try {
                const feed = await this.fetchFeed();
                this.renderFeed(feed);
            } catch (error) {
                console.error('Error loading social feed:', error);
                this.element.innerHTML = '<p>Error loading social feed</p>';
            }
        }

        async fetchFeed() {
            const response = await fetch(`/wp-json/staynalive/v1/${this.type}-feed`);
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        }

        renderFeed(feed) {
            // Render feed items here
            const items = feed.slice(0, this.count);
            const html = items.map(item => this.renderItem(item)).join('');
            this.element.innerHTML = html;
        }

        renderItem(item) {
            return `
                <div class="social-feed-item">
                    <div class="social-feed-content">${item.content}</div>
                    <div class="social-feed-meta">
                        <time datetime="${item.date}">${item.formatted_date}</time>
                    </div>
                </div>
            `;
        }
    }

    // Initialize all social feeds on the page
    document.addEventListener('DOMContentLoaded', () => {
        document.querySelectorAll('.social-feed').forEach(element => {
            new SocialFeed(element);
        });
    });
})(); 