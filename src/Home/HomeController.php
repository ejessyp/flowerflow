<?php

namespace Pan\Home;

use Anax\Commons\ContainerInjectableInterface;
use Anax\Commons\ContainerInjectableTrait;


// use Anax\Route\Exception\ForbiddenException;
// use Anax\Route\Exception\NotFoundException;
// use Anax\Route\Exception\InternalErrorException;

/**
 * A sample controller to show how a controller class can be implemented.
 */
class HomeController implements ContainerInjectableInterface
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

        $sql = "SELECT * FROM posts order by created desc;";
        $posts = $this->db->executeFetchAll($sql);

        $sql = "SELECT * FROM tags ORDER BY tagname asc limit 5;";
        $tags = $this->db->executeFetchAll($sql);
        //var_dump($tags);
        $sql = "SELECT * FROM users;";
        $users = $this->db->executeFetchAll($sql);

        $page->add("home/index", [
            "tags" => $tags,
            "posts" => $posts,
            "users" => $users,
        ]);

        return $page->render([
            "title" => "The home page ",
        ]);
    }
}
