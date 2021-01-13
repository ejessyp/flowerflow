<?php

namespace Pan\About;

use Anax\Commons\ContainerInjectableInterface;
use Anax\Commons\ContainerInjectableTrait;


/**
 * A sample controller to show how a controller class can be implemented.
 */
class AboutController implements ContainerInjectableInterface
{
    use ContainerInjectableTrait;

    public function indexAction() : object
    {
        $page = $this->di->get("page");

        $page->add("about/index",);

        return $page->render([
            "title" => "About",
        ]);
    }
}
