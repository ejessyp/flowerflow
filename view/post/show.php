<?php

namespace Anax\View;

use Michelf\Markdown;

$db =  $this->di->get("db");
// Gather incoming variables and use default values if not set
$post = isset($post) ? $post : null;
$urlToUppVote = url("post/uppvote/$post->id");
$urlToDownVote = url("post/downvote/$post->id");
$urlToComment = url("comment/create/$post->id");
$urlToAnswer = url("post/answer");
?>

<div><h1><?= $post->title?></h1></div>
<div><b>Asked</b> <?= $post->created ?> <b> By: </b><?= $post_owner ?></div>
<div class=posts>

    <div class=leftpost>
        <div class=arrow><a href='<?= $urlToUppVote?>'><i class="fa-2x fas fa-caret-up"></i></i></a></div>
        <div class=countvotes><?= $postscore?></div>
        <div class=arrow><a href='<?= $urlToDownVote?>'><i class="fa-2x fas fa-caret-down"></i></a></div>
    </div>
    <div class=rightpost>
        <div><?= Markdown::defaultTransform($post->content) ?></div>
        <div>
            <?php foreach ($posttags as $tag) :
                $urlToShowTag = url("tags/show/$tag->tag_name");?>
            <a class=onetag href="<?= $urlToShowTag ?>"><?= $tag->tag_name ?></a>
            <?php endforeach; ?>
        </div>
        <?php foreach ($comments0 as $comment) :
            $sql = "SELECT user_id FROM comments WHERE id=?;";
            $userId = $db->executeFetchAll($sql, [$comment->id]);
            $sql = "SELECT username FROM users WHERE id=?;";
            $username = $db->executeFetchAll($sql, [$userId[0]->user_id]);
            // var_dump($username);?>
        <div class=comments>

                <div><?= Markdown::defaultTransform($comment->comment) ?></div>
                <div><b>Commented:</b> <?= $comment->created ?> <b>By:</b><?= $username[0]->username ?></div>

        </div>
        <?php endforeach; ?>
    </div>
</div>

<?php
echo "<script type=text/javascript>";
include("addcomment.js");
echo "</script>";
?>
<div><a href="javascript:void(0)" onclick="add()"'>Add a comment</a></div>
<div class=rightbar>
<ul class="sortby">
<li><a href='?orderby=created&order=desc'>Date:<i class="fas fa-arrow-alt-circle-down"></i></a><a href='?orderby=created&order=asc'><i class="fas fa-arrow-alt-circle-up"></i></a></li>
<li><a href='?orderby=votes&order=desc'>Votes:<i class="fas fa-arrow-alt-circle-down"></i></a><a href='?orderby=votes&order=asc'><i class="fas fa-arrow-alt-circle-up"></i></a></li>
</ul>
</div>
<div id="comments" class=hide>
 <div>
 <form method=post action="<?= $urlToComment?>">
 <textarea name='comment'></textarea><br>
 <input type="submit" value="Add comment" name=submit>
 </form>
 </div>
</div>
<div class=countanswers><?= count($answers) ?> Answers</div>
<?php foreach ($answers as $answer) :
    $urlToCommentUppVote = url("comment/uppvote/$answer->id/$post->id");
    $urlToCommentDownVote = url("comment/downvote/$answer->id/$post->id");
    $urlToReply = url("comment/reply/$answer->id/$post->id");
    $urlToAccept = url("comment/accept/$answer->id/$post->id");
    // get the score for each answer

    $sql = "SELECT username FROM users WHERE id=?;";
    $username = $db->executeFetchAll($sql, [$answer->user_id]);

    $sql = "SELECT sum(score) as commentscore from comment_votes where comment_id=?;";
    $commentScore = $db->executeFetchAll($sql, [$answer->id]);

    $sql = "select * from comments where comment_reply_id=?;";
    $replys= $db->executeFetchAll($sql, [$answer->id]);

    // Set the accepted button according the status of answer and owner
    // var_dump($status, $answer->accepted);
    if ($isOwner) {
        if ($answer->accepted==0) {
            $acceptAns="check";
        } elseif ($answer->accepted==1) {
            $acceptAns="accepted";
        }
    } else {
        if ($answer->accepted==1) {
            $acceptAns="accepted";
        } elseif ($answer->accepted==0) {
            $acceptAns="NoShowAcceptButton";
        }
    }
    // if (!$commentscore) {
    //     $commentscore = 0;
    // } else {
    //     $commentscore = $commentscore[0]-> commentscore;
    // }
    $urlToComment =url("comment/$answer->id");
    // var_dump($acceptAns);?>
<div class=posts>
    <div class=leftpost>
        <div class=arrow><a href='<?= $urlToCommentUppVote?>'><i class="fa-2x fas fa-caret-up"></i></i></a></div>
        <div class=countvotes><?= $commentScore[0]->commentscore?:0?></div>
        <div class=arrow><a href='<?= $urlToCommentDownVote?>'><i class="fa-2x fas fa-caret-down"></i></a></div>
        <div class=<?=$acceptAns?>><a href='<?= $urlToAccept?>'><i class="fa-2x fas fa-check"></i></a></div>
    </div>
    <div class=rightpost>
        <div><?= Markdown::defaultTransform($answer->comment) ?></div>
        <div><b>Answered</b>: <?= $answer->created ?> <b>By:</b><?= $username[0]->username?></div>
        <?php foreach ($replys as $reply) :
            $sql = "SELECT username FROM users WHERE id=?;";
            $username = $db->executeFetchAll($sql, [$reply->user_id]);
            ?>
        <div class=comments>

                <div><?= Markdown::defaultTransform($reply->comment) ?></div>
                <div><b>Commented:</b> <?= $reply->created ?> <b>By:</b><?= $username[0]->username ?></div>

        </div>
        <?php endforeach; ?>
        <div><a href="javascript:void(0)" onclick="myFunction(<?= $answer->id ?>)"'>Add a comment</a></div>
        <div id="comment<?= $answer->id ?>" class=hide>
         <div>
         <form method=post action="<?=$urlToReply?>">
         <textarea name='comment'></textarea><br>
         <input type="submit" value="Add comment" name=submit>
         </form>
         </div>
        </div>
    </div>
</div>
<?php endforeach; ?>
<p>Your Answer</p>
<form method='post' action="<?= $urlToAnswer?>">
<input type='hidden' name='post_id' value='<?=$post->id?>' />
<textarea name='answer'></textarea>
<input type='submit' name='submit' value='Post your answer' />
</form>
