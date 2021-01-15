<?php

namespace Pan\Tag;

use Anax\Commons\ContainerInjectableInterface;
use Anax\Commons\ContainerInjectableTrait;


// use Anax\Route\Exception\ForbiddenException;
// use Anax\Route\Exception\NotFoundException;
// use Anax\Route\Exception\InternalErrorException;

/**
 * A sample controller to show how a controller class can be implemented.
 */
class TagController implements ContainerInjectableInterface
{
    use ContainerInjectableTrait;



    /**
     * @var $data description
     */
    private $currentUser;
    private $db;



    // /**
    //  * The initialize method is optional and will always be called before the
    //  * target method/action. This is a convienient method where you could
    //  * setup internal properties that are commonly used by several methods.
    //  *
    //  * @return void
    //  */
    public function initialize() : void
    {
        // Get the current user from session
        $session = $this->di->get("session");
        // var_dump($_SESSION);
        $this->currentUser = $session->get("username");

        // Connect the database
        $this->db = $this->di->get("db");
        $this->db->connect();
    }



    /**
     * Show all items.
     *
     * @return object as a response object
     */
    public function indexActionGet() : object
    {
        $page = $this->di->get("page");

        // Get settings from GET or use defaults
        // $request = $this->di->get("request");
        // $orderBy = $request->getGet("orderby") ?: "created";
        // $order = $request->getGet("order") ?: "asc";

        $sql = "SELECT * FROM tags ORDER BY tagname asc;";
        // var_dump($sql);
        $tags = $this->db->executeFetchAll($sql);
        $page->add("tag/view-all", [
            "items" => $tags,
        ]);

        return $page->render([
            "title" => "All posts",
        ]);
    }

    /**
     * Handler to view an item.
     *
     * @param string $tagname .
     *
     * @return object as a response object
     */
    public function showAction(string $tagname) : object
    {
        $page = $this->di->get("page");
        $sql = "SELECT * from v_all WHERE find_in_set(?, tags);";
        $posts = $this->db->executeFetchAll($sql, [$tagname]);
        var_dump($posts);
        $page->add("tag/show",
            ["tagName" => $tagname,
            "items"  => $posts,
            ]);

        return $page->render([
            "title" => "Show posts by tag",
        ]);
    }
}
