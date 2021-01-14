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
    private $currentUser;
    private $db;
    private $userId;

    /**
     * The initialize method is optional and will always be called before the
     * target method/action. This is a convienient method where you could
     * setup internal properties that are commonly used by several methods.
     *
     * @return void
     */
    public function initialize() : void
    {
        // Get the current user from session
        $session = $this->di->get("session");
        // var_dump($session);
        $this->currentUser = $session->get("username");

        // Connect the database
        $this->db = $this->di->get("db");
        $this->db->connect();
        if ($this->currentUser !=null) {
            $sql = "SELECT id from users where username = ?;";
            $res = $this->db->executeFetchAll($sql, [$this->currentUser]);
            $this->userId = $res[0]->id;
        }
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
    public function indexActionGet() : object
    {
        $page = $this->di->get("page");

        $title = "User Profile";
        // var_dump($this->currentUser);
        if ($this->currentUser) {
            $user = new User();
            $user->setDb($this->di->get("dbqb"));
            $res = $user->find("username", $this->currentUser);
            $avatar = get_gravatar($res->email);
            //Get Posts
            $user_id = $res->id;
            $sql = "SELECT * from v_all WHERE user_id=?;";
            $posts =  $this->db->executeFetchAll($sql, [$user_id]);
            // var_dump($posts);
            //Get the answers for the user
            $sql = "SELECT * from v_comments_user WHERE user_id=? and answer=1;";
            $answers = $this->db->executeFetchAll($sql, [$user_id]);
            $bonus = 0;
            foreach ($answers as $value) {
                if ($value->accepted==1) {
                    $bonus += 1;
                }
            }

            // Get the comments for the user
            $sql = "SELECT * from v_comments_user WHERE user_id=? and answer=0;";
            $comments = $this->db->executeFetchAll($sql, [$user_id]);
            // var_dump($comments);
            $reputation = count($posts)*3 + (count($answers)- $bonus)*3 +
            + $bonus*100 + count($comments);
            $page->add("user/index",
                ["current_user" => $this->currentUser,
                "avatar" => $avatar,
                "reputation" => $reputation,
                "posts"  => $posts,
                "answers" => $answers,
                "comments" => $comments,
                ]);
            return $page->render(["title" => $title, ]);
        }
        $response = $this->di->get("response");
        return $response->redirect("user/login");
    }


    public function showActionGet(int $user_id) : object
    {
        $page = $this->di->get("page");

        $title = "User Profile";

        $user = new User();
        $user->setDb($this->di->get("dbqb"));
        $res = $user->find("id", $user_id);
        $avatar = get_gravatar($res->email);
        //Get Posts

        $sql = "SELECT * from v_all WHERE user_id=?;";
        $posts =  $this->db->executeFetchAll($sql, [$user_id]);
        // var_dump($res->email);
        //Get the answers for the user
        $sql = "SELECT * from v_comments_user WHERE user_id=? and answer=1;";
        $answers = $this->db->executeFetchAll($sql, [$user_id]);
        $bonus = 0;
        foreach ($answers as $value) {
            if ($value->accepted==1) {
                $bonus += 1;
            }
        }

        // Get the comments for the user
        $sql = "SELECT * from v_comments_user WHERE user_id=? and answer=0;";
        $comments = $this->db->executeFetchAll($sql, [$user_id]);
        // var_dump($comments);
        $reputation = count($posts)*3 + (count($answers)- $bonus)*3 +
        + $bonus*100 + count($comments);
        $page->add("user/profile",
            ["user" => $res->username,
            "avatar" => $avatar,
            "reputation" => $reputation,
            "posts"  => $posts,
            "answers" => $answers,
            "comments" => $comments,
            ]);
        return $page->render(["title" => $title, ]);
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
