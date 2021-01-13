<?php

namespace Anax\View;

/**
 * View to display all books.
 */
// Show all incoming variables/functions
//var_dump(get_defined_functions());
//echo showEnvironment(get_defined_vars());

// Gather incoming variables and use default values if not set
$items = isset($items) ? $items : null;

$totalTags = count($items);
?>

<h1>All Tags</h1>

<?php if (!$items) : ?>
    <p>There are no questions to show.</p>
<?php
    return;
endif;
?>
<div class=tags>
<?php foreach ($items as $item) : ?>

        <div class=tag>
            <div><p><b><a href="tags/show/<?= $item->tagname ?>"><?= ucfirst($item->tagname) ?></a></b></p></div>
            <div><?= $item->description ?></div>
        </div>

<?php endforeach; ?>
</div>
