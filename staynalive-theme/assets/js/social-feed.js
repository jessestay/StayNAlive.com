class SocialFeed {
    constructor() {
        this.currentFeed = 'instagram';
        this.feeds = {
            instagram: [],
            tiktok: [],
            youtube: [],
            twitter: []
        };
        this.init();
    }

    async init() {
        this.container = document.querySelector('.social-feed-grid');
        this.tabs = document.querySelectorAll('.social-tab');
        
        this.tabs.forEach(tab => {
            tab.addEventListener('click', () => this.switchFeed(tab.dataset.feed));
        });
        
        await this.loadFeeds();
    }

    async loadFeeds() {
        try {
            const endpoints = {
                instagram: '/wp-json/staynalive/v1/instagram-feed',
                tiktok: '/wp-json/staynalive/v1/tiktok-feed',
                youtube: '/wp-json/staynalive/v1/youtube-feed',
                twitter: '/wp-json/staynalive/v1/twitter-feed'
            };

            const responses = await Promise.all(
                Object.entries(endpoints).map(async ([platform, endpoint]) => {
                    const response = await fetch(endpoint);
                    const data = await response.json();
                    return [platform, data];
                })
            );

            responses.forEach(([platform, data]) => {
                this.feeds[platform] = data;
            });

            this.renderFeed(this.currentFeed);
        } catch (_error) {
            console.error('Failed to fetch social feed');
            this.handleError();
        }
    }

    renderFeed(type) {
        const feed = this.feeds[type];
        this.container.innerHTML = '';
        
        feed.forEach(item => {
            const card = this.createCard(item, type);
            this.container.appendChild(card);
            this.animateCard(card);
        });
    }

    createCard(item, type) {
        const card = document.createElement('div');
        card.className = 'social-card';
        card.innerHTML = type === 'instagram' ? 
            this.renderInstagramItem(item) : 
            this.renderTikTokItem(item);
        return card;
    }

    animateCard(card) {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        
        setTimeout(() => {
            card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
        }, 100);
    }
}

document.addEventListener('DOMContentLoaded', () => new SocialFeed());
