<?php

namespace Anax\View;

use Michelf\Markdown;

// Gather incoming variables and use default values if not set
$items = isset($items) ? $items : null;

// Create urls for navigation
$urlToCreate = url("post/create");
$totalPosts = count($items);
?>
<div class=posts>
<div class=leftbar><p class=allposts>All Posts</p></div>
<div class=rightbar>
    <p class=askquestion><a  href="<?= $urlToCreate ?>">Ask Question<p></a>
</div>
</div>

<div class=posts>
<div class=leftbar>
<p ><b><?= $totalPosts ?> Posts</b></p></div>
<div class=rightbar>
<ul class="sortby">
<li><a href='?orderby=created&order=desc'>Date:<i class="fas fa-arrow-alt-circle-down"></i></a><a href='?orderby=created&order=asc'><i class="fas fa-arrow-alt-circle-up"></i></a></li>
<li><a href='?orderby=votes&order=desc'>Votes:<i class="fas fa-arrow-alt-circle-down"></i></a><a href='?orderby=votes&order=asc'><i class="fas fa-arrow-alt-circle-up"></i></a></li>
</ul>
</div>
</div>
<?php if (!$items) : ?>
    <p>There are no items to show.</p>
<?php
    return;
endif;
?>
<?php foreach ($items as $item) :
    $db =  $this->di->get("db");
    $sql = "SELECT sum(score) as postscore from post_votes where post_id=?;";
    $score = $db->executeFetchAll($sql, [$item->id]);
    $sql = "select * from post2tag where post_id=?;";
    $posttags = $db->executeFetchAll($sql, [$item->id]);
    $sql = "SELECT sum(answer) as totalanswer from comments where post_id=?;";
    $answer = $db->executeFetchAll($sql, [$item->id]);
    ?>

    <div class=posts>
        <div class=leftpost>
            <div class=countvotes><?= $score[0]->postscore?:0?></div>
            <div class=countvotes>votes</div>
            <div class=countanswers><?= $answer[0]->totalanswer?: 0?></div>
            <div class=countvotes>answers</div>
        </div>
        <div class=rightpost>
            <div><b><a href="post/show/<?= $item->id ?>"><?= $item->title ?></a></b></div>
            <div><p class=postcontent><?= Markdown::defaultTransform($item->content) ?></p></div>
            <div>
                <?php foreach ($posttags as $tag) : ?>
                <a class=onetag href="tag/<?= $tag->tag_name ?>"><?= $tag->tag_name ?></a>
                <?php endforeach; ?>
            </div>
            <div>Asked <?= $item->created ?></div>
        </div>
    </div>

<?php endforeach; ?>
