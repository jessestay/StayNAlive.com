/* global wp */

/**
 * Block Editor customizations and enhancements
 */

wp.domReady(() => {
    // Register custom block styles
    wp.blocks.registerBlockStyle('core/button', {
        name: 'outline',
        label: 'Outline'
    });

    // Register custom color palette
    wp.data.dispatch('core/editor').updateEditorSettings({
        colors: [
            { name: 'Primary', slug: 'primary', color: '#bf2a32' },
            { name: 'Text', slug: 'text', color: '#333333' },
            { name: 'Background', slug: 'background', color: '#ffffff' }
        ]
    });

    // Add custom block variations
    wp.blocks.registerBlockVariation('core/group', {
        name: 'content-section',
        title: 'Content Section',
        attributes: {
            className: 'content-section',
            backgroundColor: 'background'
        },
        innerBlocks: [
            ['core/heading', {}],
            ['core/paragraph', {}]
        ]
    });

    // Add custom block patterns category
    wp.blocks.registerBlockPattern('staynalive/header-with-cta', {
        title: 'Header with CTA',
        content: `<!-- wp:group -->...<!-- /wp:group -->`
    });
}); 