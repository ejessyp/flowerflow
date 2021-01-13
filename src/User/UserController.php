<?php

namespace Pan\User;

use Anax\Commons\ContainerInjectableInterface;
use Anax\Commons\ContainerInjectableTrait;
use Pan\User\HTMLForm\UserLoginForm;
use Pan\User\HTMLForm\CreateUserForm;
use Pan\Post\Post;

// use Anax\Route\Exception\ForbiddenException;
// use Anax\Route\Exception\NotFoundException;
// use Anax\Route\Exception\InternalErrorException;

/**
 * A sample controller to show how a controller class can be implemented.
 */
class UserController implements ContainerInjectableInterface
{
    use ContainerInjectableTrait;



    /**
     * @var $data description
     */
    //private $data;



    // /**
    //  * The initialize method is optional and will always be called before the
    //  * target method/action. This is a convienient method where you could
    //  * setup internal properties that are commonly used by several methods.
    //  *
    //  * @return void
    //  */
    // public function initialize() : void
    // {
    //     ;
    // }



    /**
     * Description.
     *
     * @param datatype $variable Description
     *
     * @throws Exception
     *
     * @return object as a response object
     */
    public function indexActionGet() : object
    {
        $page = $this->di->get("page");

        $title = "User Profile";
        $session = $this->di->get("session");
        // var_dump($_SESSION);
        $currentUser = $session->get("username");
        if ($currentUser) {
            $user = new User();
            $user->setDb($this->di->get("dbqb"));
            $res = $user->find("username", $currentUser);
            // var_dump($res);
            $avatar = get_gravatar($res->email);
            $reputation = $res->points;

            //Get Posts
            $user_id = $res->id;

            $post = new Post();
            $post->setDb($this->di->get("dbqb"));
            $posts = $post->findAllWhere("user_id = ?", $user_id);
            //Get Answers
            $db = $this->di->get("db");
            $db->connect();
            $sql = "SELECT * from v_posts_comments WHERE user_id=?;";
            $comments = $db->executeFetchAll($sql, [$user_id]);
            // var_dump($comments);
            $page->add("user/profile",
                ["current_user" => $currentUser,
                "avatar" => $avatar,
                "reputation" => $reputation,
                "items"  => $posts,
                "comments" => $comments,
                ]);
            return $page->render(["title" => $title, ]);
        }
        $response = $this->di->get("response");
        return $response->redirect("user/login");
    }



    /**
     * Description.
     *
     * @param datatype $variable Description
     *
     * @throws Exception
     *
     * @return object as a response object
     */
    public function loginAction() : object
    {
        $page = $this->di->get("page");
        $form = new UserLoginForm($this->di);
        $form->check();

        $page->add("user/login", [
            "content" => $form->getHTML(),
        ]);

        return $page->render([
            "title" => "A login page",
        ]);
    }

    /**
     * Description.
     *
     * @param datatype $variable Description
     *
     * @throws Exception
     *
     * @return object as a response object
     */
    public function logoutAction() : object
    {
        $response = $this->di->get("response");
        $session = $this->di->get("session");
        $session->destroy();
        return $response->redirect("user/login");
    }


    /**
     * Description.
     *
     * @param datatype $variable Description
     *
     * @throws Exception
     *
     * @return object as a response object
     */
    public function createAction() : object
    {
        $page = $this->di->get("page");
        $form = new CreateUserForm($this->di);
        $form->check();

        $page->add("user/create", [
            "form" => $form->getHTML(),
        ]);

        return $page->render([
            "title" => "Register User",
        ]);
    }
}
