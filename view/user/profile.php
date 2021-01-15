<?php

namespace Anax\View;

use Michelf\Markdown;

// $acceptAns = "NoShowAcceptButton";
?>

<div class=userprofile>
<div class=leftbar>
<img src="<?= $avatar?>" alt="" />

</div>
<div class=rightbar>Reputation:<p class=allposts><?=$reputation?> </p></div>
<div class=rightbar>User:<p class=allposts><?=$user?></p></div>
</div>
<h2 class="title">Posts</h2>
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

    $urlToShowPost = url("post/show/$item->id");?>

    <div class=posts>
        <div class=leftpost>
            <div class=countvotes><?=  $score[0]->postscore?:0?></div>
            <div class=countvotes>votes</div>
            <div class=countanswers><?= $answer[0]->totalanswer?: 0?></div>
            <div class=countvotes>answers</div>
        </div>
        <div class=rightpost>
            <div><b><a href="<?=$urlToShowPost ?>"><?= $item->title ?></a></b></div>
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

<h2 class="title">Answers</h2>
<?php if (!$answers) : ?>
        <p>There are no answers.</p>
    <?php
        return;
    endif;
?>

    <?php foreach ($answers as $answer):
        if ($answer->accepted==1) {
            $acceptAns ="accepted";
        } else {
            $acceptAns ="NoShowAcceptButton";
        };
        // var_dump($acceptAns);
    ?>
        <div class=profileposts>
                <a href="<?= url("post/show/{$answer->post_id}"); ?>"><?= Markdown::defaultTransform($answer->comment);?></a>
                <div class=<?=$acceptAns?>><i class="fa-2x fas fa-check"></i></div>
        </div>
    <?php endforeach; ?>

<h2 class="title">Comments</h2>
<?php if (!$comments) : ?>
        <p>There are no comments.</p>
    <?php
        return;
    endif;
?>
    <?php foreach ($comments as $comment): ?>
        <div>
                <a href="<?= url("post/show/{$comment->post_id}"); ?>"><?=Markdown::defaultTransform($comment->comment) ?></a>
        </div>
    <?php endforeach; ?>
