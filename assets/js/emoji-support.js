/**
 * WordPress emoji support
 */
(function() {
    // Test if browser supports emoji
    const supportsEmoji = (function() {
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');
        const smiley = String.fromCodePoint(0x1F604);
        
        ctx.textBaseline = 'top';
        ctx.font = '32px Arial';
        ctx.fillText(smiley, 0, 0);
        
        return ctx.getImageData(16, 16, 1, 1).data[0] !== 0;
    })();

    if (!supportsEmoji) {
        // Load Twemoji if native emoji not supported
        const script = document.createElement('script');
        script.src = 'https://twemoji.maxcdn.com/v/latest/twemoji.min.js';
        document.head.appendChild(script);
        
        script.onload = function() {
            twemoji.parse(document.body);
        };
    }
})(); 