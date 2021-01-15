<?php

namespace Anax\View;
use Michelf\Markdown;

$acceptAns = "NoShowAcceptButton";
?>

<h2 class="page-title">You are logged in as "<?=$current_user ?>".  <a href="user/logout/"> Logout</a></h2>
<img src="<?= $avatar?>" alt="" />
<p class="center">Reputation: <?=$reputation?></p>

<h2 class="title">Posts</h2>
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

<h2 class="title">Answers</h2>
<?php if (!$answers) : ?>
        <p>There are no answers.</p>
    <?php
        return;
    endif;
?>

<table class=table>
    <?php foreach ($answers as $answer):
        if ($answer->accepted==1) {
            $acceptAns ="accepted";
        } else {
            $acceptAns ="NoShowAcceptButton";
        };
    ?>
        <tr>
            <td>
                <a href="<?= url("post/show/{$answer->post_id}"); ?>"><?=Markdown::defaultTransform($answer->comment) ?></a>
                <div class=<?=$acceptAns?>><i class="fa-2x fas fa-check"></i></div>
            </td>
        </tr>
    <?php endforeach; ?>
</table>


<h2 class="title">Comments</h2>
<?php if (!$comments) : ?>
        <p>There are no comments.</p>
    <?php
        return;
    endif;
?>

<table class=table>
    <?php foreach ($comments as $comment): ?>
        <tr>
            <td>
                <a href="<?= url("post/show/{$comment->post_id}"); ?>"><?=Markdown::defaultTransform($comment->comment) ?></a>
            </td>
        </tr>
    <?php endforeach; ?>
</table>
