wp.domReady(() => {
    // Add custom block styles
    wp.blocks.registerBlockStyle('core/group', {
        name: 'card',
        label: 'Card',
    });

    wp.blocks.registerBlockStyle('core/group', {
        name: 'glass',
        label: 'Glass',
    });

    // Remove unwanted block patterns
    wp.blocks.unregisterBlockPattern('core/query-standard-posts');
    wp.blocks.unregisterBlockPattern('core/query-grid-posts');

    // Add custom block variations
    wp.blocks.registerBlockVariation('core/group', {
        name: 'content-section',
        title: 'Content Section',
        attributes: {
            className: 'content-section',
            layout: {
                type: 'constrained',
                contentSize: '800px',
            },
        },
    });
});
