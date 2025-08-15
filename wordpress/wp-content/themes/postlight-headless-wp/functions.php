<?php
/**
 * Theme for the Postlight Headless WordPress Starter Kit.
 *
 * Read more about this project at:
 * https://postlight.com/trackchanges/introducing-postlights-wordpress-react-starter-kit
 *
 * @package  Postlight_Headless_WP
 */

// Frontend origin.
require_once 'inc/frontend-origin.php';

// ACF commands.
require_once 'inc/class-acf-commands.php';

// Logging functions.
require_once 'inc/log.php';

// CORS handling.
require_once 'inc/cors.php';

// Admin modifications.
require_once 'inc/admin.php';

// Add Menus.
require_once 'inc/menus.php';

// Add Headless Settings area.
require_once 'inc/acf-options.php';

// Add GraphQL resolvers.
require_once 'inc/graphql/resolvers.php';

/**
 * Charger les styles natifs de Gutenberg
 */
function postlight_headless_gutenberg_styles() {
    // Charger les styles de base des blocs Gutenberg
    wp_enqueue_style( 'wp-block-library' );
    
    // Charger les styles spécifiques au thème si supportés
    if ( current_theme_supports( 'wp-block-styles' ) ) {
        wp_enqueue_style( 'wp-block-library-theme' );
    }
    
    // Charger les styles d'édition pour l'admin
    if ( is_admin() ) {
        wp_enqueue_style( 'wp-edit-blocks' );
    }
}
add_action( 'enqueue_block_assets', 'postlight_headless_gutenberg_styles' );

/**
 * Activer le support des styles de blocs
 */
function postlight_headless_theme_supports() {
    // Activer le support des styles de blocs Gutenberg
    add_theme_support( 'wp-block-styles' );
    
    // Activer le support des couleurs de blocs
    add_theme_support( 'editor-color-palette' );
    
    // Activer le support de la typographie
    add_theme_support( 'editor-font-sizes' );
    
    // Activer le support des alignements larges
    add_theme_support( 'align-wide' );
}
add_action( 'after_setup_theme', 'postlight_headless_theme_supports' );

/**
 * Endpoint REST API pour les styles de Gutenberg
 */
function postlight_headless_gutenberg_styles_endpoint() {
    register_rest_route( 'postlight-headless/v1', '/gutenberg-styles', array(
        'methods' => 'GET',
        'callback' => 'postlight_headless_get_gutenberg_styles',
        'permission_callback' => '__return_true',
    ) );
}
add_action( 'rest_api_init', 'postlight_headless_gutenberg_styles_endpoint' );

/**
 * Récupérer les styles de Gutenberg
 */
function postlight_headless_get_gutenberg_styles() {
    // Forcer le chargement des styles de Gutenberg
    wp_enqueue_style( 'wp-block-library' );
    wp_enqueue_style( 'wp-block-library-theme' );
    wp_enqueue_style( 'wp-edit-blocks' );
    wp_enqueue_style( 'wp-format-library' );
    
    // Récupérer les URLs des styles
    $styles = array();
    
    // Styles de base des blocs
    $block_library_url = includes_url( 'css/dist/block-library/style.min.css' );
    $styles['block-library'] = $block_library_url;
    
    // Styles du thème
    $block_theme_url = includes_url( 'css/dist/block-library/theme.min.css' );
    $styles['block-theme'] = $block_theme_url;
    
    // Styles d'édition
    $block_editor_url = includes_url( 'css/dist/block-editor/style.min.css' );
    $styles['block-editor'] = $block_editor_url;
    
    // Styles de la bibliothèque de formats
    $format_library_url = includes_url( 'css/dist/format-library/style.min.css' );
    $styles['format-library'] = $format_library_url;
    
    // Styles globaux WordPress
    $global_styles_url = includes_url( 'css/dist/global-styles/style.min.css' );
    $styles['global-styles'] = $global_styles_url;
    
    return array(
        'styles' => $styles,
        'css_urls' => array(
            $block_library_url,
            $block_theme_url,
            $block_editor_url,
            $format_library_url,
            $global_styles_url
        ),
        'info' => array(
            'description' => 'Tous les styles Gutenberg nécessaires pour le frontend',
            'version' => get_bloginfo('version'),
            'theme' => get_template()
        )
    );
}
