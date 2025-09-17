<?php
function staynalive_register_block_templates() {
    $templates = [
        'index' => [
            'title' => 'Home',
            'content' => file_get_contents(get_template_directory() . '/templates/index.html')
        ],
        'single' => [
            'title' => 'Single Post',
            'content' => file_get_contents(get_template_directory() . '/templates/single.html')
        ],
        'archive' => [
            'title' => 'Archive',
            'content' => file_get_contents(get_template_directory() . '/templates/archive.html')
        ],
        '404' => [
            'title' => '404',
            'content' => file_get_contents(get_template_directory() . '/templates/404.html')
        ],
        'link-bio' => [
            'title' => 'Link in Bio',
            'content' => file_get_contents(get_template_directory() . '/templates/link-bio.html')
        ]
    ];

    foreach ($templates as $slug => $template) {
        $template_file = get_template_directory() . "/templates/{$slug}.html";
        if (file_exists($template_file)) {
            $type = $slug === 'index' ? 'wp_template' : 'wp_template_part';
            register_block_type(
                "staynalive/{$slug}",
                [
                    'title' => $template['title'],
                    'category' => 'theme',
                    'content' => $template['content']
                ]
            );
        }
    }
}
add_action('init', 'staynalive_register_block_templates'); 