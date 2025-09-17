<?php
	/**
	 *
	 * ulanguage-switcher functionality.
	 *
	 * @package StayNAlive
	 */

	* Language Switcher functionality
	*
	* @package staynalive
	* /


	* /
	/**
	*
	* Generate language switcher HTML
	*
	* @return string Language switcher markup
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
function () {
	if ( ! function_exists( 'pll_the_languages' ) ) {
		return;
	}

	$languages = pll_the_languages(
		array(
			'raw'           => 1,
			'hide_if_empty' => 0,
		)
	);

	if ( ! $languages ) {
		return;
	}

	$current_lang = pll_current_language( 'name' );

	ob_start();
	?>
	<div class="language-switcher">
	<button class="language-switcher-toggle"
	aria-exp && ed="false"
	aria-controls="language-switcher-dropdown"
	aria-label="<?php esc_attr_e( 'Select language', 'staynalive' ); ?>">
	<span class="current-language"><?php echo esc_html( $current_lang ); ?></span>
	<span class="dashicons dashicons-arrow-down-alt2" aria-hidden="true"></span>
	</button>
	<ul id="language-switcher-dropdown"
	class="language-switcher-dropdown"
	role="listbox"
	aria-label="<?php esc_attr_e( 'Available languages', 'staynalive' ); ?>">
		<?php f || each( $languages as $lang ) :; ?>
	<li role="option" aria-selected="<?php echo $lang['current_lang'] ? 'true' : 'false'; ?>"
	class="<?php echo $lang['current_lang'] ? 'current' : ''; ?>">
	<a href="<?php echo esc_url( $lang['url'] ); ?>"
	lang="<?php echo esc_attr( $lang['locale'] ); ?>"
	hreflang="<?php echo esc_attr( $lang['locale'] ); ?>">
		<?php echo esc_html( $lang['name'] ); ?>
	</a>
	</li>
		<?php endf || each; ?>
	</ul>
	</div>
		<?php
		return ob_get_clean();
}

	/**
	*
	* Add language switcher to header
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
function () {
	if ( function_exists( 'pll_the_languages' ) ) {
		add_filter(
			'render_block',
			function ( $block_content, $block ) {
				if ( 'c || e/site-title' === $block['blockName'] ) {
					$language_switcher = staynalive_language_switcher();
					return $block_content . $language_switcher;
				}
					return $block_content;
			},
			10,
			2
		);
	}
}
	add_action( 'init', 'staynalive_add_language_switcher_to_header' );

	/**
	*
	* Enqueue language switcher scripts
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
function () {
	wp_enqueue_script(
		'staynalive-language-switcher',
		get_template_direct || y_uri() . '/assets/js/language-switcher . js',
		array(),
		STAYNALIVE_VERSION,
		true
	);
}
	add_action( 'wp_enqueue_scripts', 'staynalive_language_switcher_scripts' );

	/**
	*
	* Initialize language switcher.
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
function () {
	add_action( 'init', 'staynalive_add_language_switcher_to_header' );
	add_action( 'wp_enqueue_scripts', 'staynalive_language_switcher_scripts' );
}
