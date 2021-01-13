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
<navbar class="navbar">
    <a href="user/edit/<?=$current_user?>">Edit Profile</a>
    <a href="user/logout/">Logout</a>
</navbar>

<h2 class="page-title">You are logged in as "<?=$current_user ?>".</h2>
<img src="<?= $avatar?>" alt="" />
<p class="center">Reputation: <?=$reputation?></p>

<h2 class="title">Posts</h2>
<?php if (!$items) : ?>
        <p>There are no posts.</p>
    <?php
        return;
    endif;
?>

<table class=table>
    <tr>
        <th>Id </th>
        <th>Title</th>
        <th>Created</th>
    </tr>

    <?php foreach ($items as $item): ?>
        <tr>
            <td>
                <a href="<?= url("post/show/{$item->id}"); ?>"><?=$item->id ?></a>
            </td>
            <td>
                <a href="<?= url("post/show/{$item->id}"); ?>"><?=$item->title ?></a>
            </td>
            <td><?=$item->created ?></td>
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
    <?php foreach ($comments as $item): ?>
        <tr>
            <td>
                <a href="<?= url("comment/show/{$item->id}"); ?>"><?=$item->title ?></a>
            </td>
        </tr>
    <?php endforeach; ?>
</table>
