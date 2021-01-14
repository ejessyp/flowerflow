<?php
/**
 * Supply the basis for the navbar as an array.
 */
return [
    // Use for styling the menu
    "wrapper" => null,
    "class" => "my-navbar rm-default rm-desktop",

    // Here comes the menu items
    "items" => [
        [
            "text" => "Home",
            "url" => "",
            "title" => "A homepage for flowerPlus.",
        ],
        [
            "text" => "Posts",
            "url" => "post",
            "title" => "All Posts",
        ],
        [
            "text" => "Tags",
            "url" => "tags",
            "title" => "View by tags.",
        ],
        [
            "text" => "User",
            "url" => "user",
            "title" => "User Profile.",
        ],
        [
            "text" => "About",
            "url" => "about",
            "title" => "About this websites.",
        ],
    ],
];
