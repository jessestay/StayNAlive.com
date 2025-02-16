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

    init() {
        this.container = document.querySelector('.social-feed-grid');
        this.tabs = document.querySelectorAll('.social-tab');
        
        this.tabs.forEach(tab => {
            tab.addEventListener('click', () => this.switchFeed(tab.dataset.feed));
        });
        
        this.loadFeeds();
    }

    async loadFeeds() {
        try {
            // Load all social feeds
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
            const card = document.createElement('div');
            card.className = 'social-card';
            card.innerHTML = `
                <div class="social-media-content">
                    ${type === 'instagram' ? this.renderInstagramItem(item) : type === 'tiktok' ? this.renderTikTokItem(item) : type === 'youtube' ? this.renderYouTubeItem(item) : this.renderTwitterItem(item)}
                </div>
                <div class="social-card-footer">
                    <span class="social-stats">
                        <span class="likes">${this.formatNumber(item.likes)} likes</span>
                        <span class="comments">${this.formatNumber(item.comments)} comments</span>
                    </span>
                    <a href="${item.link}" target="_blank" rel="noopener noreferrer" class="view-post">View Post</a>
                </div>
            `;
            
            this.container.appendChild(card);
            this.animateCard(card);
        });
    }

    renderInstagramItem(item) {
        return item.media_type === 'VIDEO' 
            ? `<video src="${item.media_url}" controls poster="${item.thumbnail_url}"></video>`
            : `<img src="${item.media_url}" alt="${item.caption || ''}" loading="lazy">`;
    }

    renderTikTokItem(item) {
        return `
            <div class="tiktok-embed" data-video-id="${item.id}">
                <blockquote class="tiktok-embed" cite="${item.share_url}">
                    <iframe src="https://www.tiktok.com/embed/${item.id}"></iframe>
                </blockquote>
            </div>
        `;
    }

    renderYouTubeItem(item) {
        return `
            <div class="youtube-embed">
                <iframe 
                    src="https://www.youtube.com/embed/${item.videoId}"
                    title="${item.title}"
                    frameborder="0"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                    allowfullscreen
                ></iframe>
            </div>
            <div class="video-info">
                <h3>${item.title}</h3>
                <p>${item.description}</p>
            </div>
        `;
    }

    renderTwitterItem(item) {
        return `
            <div class="twitter-content">
                <p>${this.formatTweet(item.text)}</p>
                ${item.media ? this.renderTwitterMedia(item.media) : ''}
            </div>
        `;
    }

    formatTweet(text) {
        return text
            .replace(/(https?:\/\/[^\s]+)/g, '<a href="$1" target="_blank">$1</a>')
            .replace(/@(\w+)/g, '<a href="https://twitter.com/$1" target="_blank">@$1</a>')
            .replace(/#(\w+)/g, '<a href="https://twitter.com/hashtag/$1" target="_blank">#$1</a>');
    }

    switchFeed(type) {
        this.currentFeed = type;
        this.tabs.forEach(tab => {
            tab.classList.toggle('active', tab.dataset.feed === type);
        });
        this.renderFeed(type);
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

    formatNumber(num) {
        return new Intl.NumberFormat('en-US', { notation: 'compact' }).format(num);
    }

    handleError() {
        const errorMessage = document.createElement('div');
        errorMessage.className = 'feed-error';
        errorMessage.innerHTML = `
            <p>Sorry, we couldn't load the feed. Please try again later.</p>
            <button onclick="location.reload()">Retry</button>
        `;
        this.container.appendChild(errorMessage);
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => new SocialFeed()); 