<?php
/**
 * Frontend origin helper function.
 *
 * @package  Postlight_Headless_WP
 */

/**
 * Placeholder function for determining the frontend origin.
 *
 * @TODO Determine the headless client's URL based on the current environment.
 *
 * @return str Frontend origin URL, i.e., http://localhost:3000.
 */
function get_frontend_origin() {
    // Get the current site URL and replace wp- prefix with frontend- for the frontend domain
    $site_url = get_site_url();
    $frontend_url = str_replace('wp-', '', $site_url);
    
    // If no wp- prefix found, use the default pattern
    if ($frontend_url === $site_url) {
        $frontend_url = str_replace('wp-headless', 'frontend', $site_url);
    }
    
    // Fallback to localhost if still no change
    if ($frontend_url === $site_url) {
        $frontend_url = 'http://localhost:3000';
    }
    
    return $frontend_url;
}
