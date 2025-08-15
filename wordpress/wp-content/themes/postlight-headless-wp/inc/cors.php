<?php
/**
 * REST API CORS filter.
 *
 * @package  Postlight_Headless_WP
 */

/**
 * Allow GET requests from origin
 * Thanks to https://joshpress.net/access-control-headers-for-the-wordpress-rest-api/
 */
add_action(
    'rest_api_init',
    function () {
        remove_filter( 'rest_pre_serve_request', 'rest_send_cors_headers' );

        add_filter(
            'rest_pre_serve_request',
            function ( $value ) {
                header( 'Access-Control-Allow-Origin: ' . get_frontend_origin() );
                header( 'Access-Control-Allow-Methods: GET, POST, OPTIONS' );
                header( 'Access-Control-Allow-Headers: Content-Type, Authorization, X-WP-Nonce' );
                header( 'Access-Control-Allow-Credentials: true' );
                
                // Handle preflight requests
                if ( $_SERVER['REQUEST_METHOD'] === 'OPTIONS' ) {
                    status_header( 200 );
                    exit();
                }
                
                return $value;
            }
        );
    },
    15
);

/**
 * Add CORS headers for all WordPress requests
 */
add_action( 'init', function() {
    if ( isset( $_SERVER['HTTP_ORIGIN'] ) ) {
        $allowed_origin = get_frontend_origin();
        
        // Check if the origin matches our frontend
        if ( $_SERVER['HTTP_ORIGIN'] === $allowed_origin ) {
            header( 'Access-Control-Allow-Origin: ' . $allowed_origin );
            header( 'Access-Control-Allow-Methods: GET, POST, OPTIONS' );
            header( 'Access-Control-Allow-Headers: Content-Type, Authorization, X-WP-Nonce' );
            header( 'Access-Control-Allow-Credentials: true' );
        }
    }
    
    // Handle preflight requests
    if ( $_SERVER['REQUEST_METHOD'] === 'OPTIONS' ) {
        status_header( 200 );
        exit();
    }
});
