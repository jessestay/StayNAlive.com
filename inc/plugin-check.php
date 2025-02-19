<?php
/**
 * Plugin dependency check
 *
 * @package StayNAlive
 */

function staynalive_check_required_plugins() {
    if (!is_plugin_active('staynalive-functionality/staynalive-functionality.php')) {
        add_action('admin_notices', 'staynalive_plugin_notice');
    }
}
add_action('admin_init', 'staynalive_check_required_plugins');

function staynalive_plugin_notice() {
    ?>
    <div class="notice notice-error">
        <p><?php _e('The StayNAlive theme requires the StayNAlive Functionality plugin to be installed and activated.', 'staynalive'); ?></p>
    </div>
    <?php
} 