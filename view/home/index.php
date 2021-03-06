<?php

namespace Anax\View;

use Michelf\Markdown;

// Create urls for navigation
$urlToCreate = url("post/create");
$totalPosts = count($posts);

?>
<div class=all>
<div class=rightpost>
<div class=posts><b>Latest Posts</b></div>

<?php if (!$posts) : ?>
    <p>There are no items to show.</p>
<?php
    return;
endif;
?>
<?php foreach ($posts as $item) :
    $db =  $this->di->get("db");
    $sql = "SELECT sum(score) as postscore from post_votes where post_id=?;";
    $score = $db->executeFetchAll($sql, [$item->id]);
    $sql = "select * from post2tag where post_id=?;";
    $posttags = $db->executeFetchAll($sql, [$item->id]);
    $sql = "SELECT sum(answer) as totalanswer from comments where post_id=?;";
    $answer = $db->executeFetchAll($sql, [$item->id]);
    // var_dump($answer);
    // if (!$score) {
    //     $score = 0;
    // } else {
    //     $score = $score[0]-> postscore;
    // }?>

    <div class=posts>
        <div class=leftpost>
            <div class=countvotes><?= $score[0]->postscore?: 0 ?></div>
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
</div>
<div>
    <div>
        <p class=rightcol><a  href="<?= $urlToCreate ?>">Ask Question<p></a>
    </div>
    <br>
<div>
<p class=middle><b>Tags</b><p>
<?php foreach ($tags as $tag) :?>
    <div class=rightcol><a href="tags/show/<?= $tag->tagname ?>"><?= ucfirst($tag->tagname) ?></a></div>
<?php endforeach; ?>
</div>
<div><p class=middle><b>Users</b><p>
    <?php foreach ($users as $user) :?>
        <div class=rightcol><p><a href="user/show/<?= $user->id ?>"><?= ucfirst($user->username) ?></a></p></div>
    <?php endforeach; ?>
</div>
</div>
</div>
