<!-- wp:template-part {"slug":"header","tagName":"header"} /-->

<!-- wp:group {"tagName":"main","className":"site-main index-page","layout":{"type":"constrained"}} -->
<main class="wp-block-group site-main index-page">
    <!-- wp:query {"queryId":1,"query":{"perPage":10,"offset":0,"postType":"post","order":"desc","orderBy":"date","author":"","search":"","sticky":"","inherit":true}} -->
    <div class="wp-block-query">
        <!-- wp:post-template -->
            <!-- wp:group {"className":"post-item"} -->
            <div class="wp-block-group post-item">
                <!-- wp:post-featured-image {"isLink":true,"align":"wide"} /-->
                <!-- wp:post-title {"isLink":true,"fontSize":"large"} /-->
                <!-- wp:group {"className":"post-meta","layout":{"type":"flex","flexWrap":"wrap"}} -->
                <div class="wp-block-group post-meta">
                    <!-- wp:post-date /-->
                    <!-- wp:post-author {"showAvatar":false} /-->
                    <!-- wp:post-terms {"term":"category"} /-->
                </div>
                <!-- /wp:group -->
                <!-- wp:post-excerpt {"moreText":"Read More"} /-->
            </div>
            <!-- /wp:group -->
        <!-- /wp:post-template -->

        <!-- wp:query-pagination {"paginationArrow":"arrow","layout":{"type":"flex","justifyContent":"space-between"}} -->
            <!-- wp:query-pagination-previous /-->
            <!-- wp:query-pagination-numbers /-->
            <!-- wp:query-pagination-next /-->
        <!-- /wp:query-pagination -->

        <!-- wp:query-no-results -->
            <!-- wp:paragraph {"placeholder":"Add text or blocks that will display when a query returns no results."} -->
            <p>No posts found.</p>
            <!-- /wp:paragraph -->
        <!-- /wp:query-no-results -->
    </div>
    <!-- /wp:query -->
</main>
<!-- /wp:group -->

<!-- wp:template-part {"slug":"footer","tagName":"footer"} /--> 