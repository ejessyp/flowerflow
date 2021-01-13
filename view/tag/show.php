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

?>
<h1>Question tagged by [<?= $tagName ?>] </h1>

<?php if (!$items) : ?>
    <p>There are no items to show.</p>
<?php
    return;
endif;
?>
<?php foreach ($items as $item) :
    $urlToShow = url("post/show/$item->id");?>

    <div class=posts>
        <div class=leftpost>
            <div class=countvotes><?= $item->score?></div>
            <div class=countvotes>votes</div>
            <div class=countanswers><?= $item->answer?></div>
            <div class=countvotes>answers</div>
        </div>
        <div class=rightpost>
            <div><p><a href="<?= $urlToShow ?>"><?= $item->title ?></a></p></div>
            <div><p class=postcontent><?= $item->content ?></p></div>
            <div>
                <?php foreach (explode(",", $item->tags) as $tag) : ?>
                <a class=onetag href="tag/<?= $tag ?>"><?= $tag ?></a>

            <?php endforeach; ?>
            </div>
            <div>Asked <?= $item->created ?></div>
        </div>
    </div>

<?php endforeach; ?>
