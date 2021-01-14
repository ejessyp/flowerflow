<?php

namespace Pan\Comment;

use Anax\Commons\ContainerInjectableInterface;
use Anax\Commons\ContainerInjectableTrait;


// use Anax\Route\Exception\ForbiddenException;
// use Anax\Route\Exception\NotFoundException;
// use Anax\Route\Exception\InternalErrorException;

/**
 * A sample controller to show how a controller class can be implemented.
 */
class CommentController implements ContainerInjectableInterface
{
    use ContainerInjectableTrait;



    /**
     * @var $data description
     */
    private $currentUser;
    private $db;
    private $userId;



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
        if ($this->currentUser !=null) {
            $sql = "SELECT id from users where username = ?;";
            $res = $this->db->executeFetchAll($sql, [$this->currentUser]);
            $this->userId = $res[0]->id;
        }
    }


    public function createActionPost(int $id) : object
    {
        $request = $this->di->get("request");
        $response = $this->di->get("response");
        $submit = $request->getPost("submit") ?: null;
        var_dump($this->currentUser);
        if ($submit) {
            $comment = $request->getPost("comment") ?: null;
            $sql = "INSERT INTO comments (comment, post_id, user_id, answer) VALUES (?, ?, ?, ?);";
            $this->db->execute($sql, [$comment, $id, $this->userId, 0]);
            return $response->redirect("post/show/$id");
        }
    }

    /**
     * Handler with form to delete an item.
     *
     * @return object as a response object
     */
    public function deleteAction() : object
    {
        $page = $this->di->get("page");

    }



    public function uppvoteAction(int $id, int $post_id) : object
    {
        $page = $this->di->get("page");

        $sql = "INSERT INTO comment_votes (score, comment_id, user_id) VALUES (?, ?, ?);";
        $this->db->execute($sql, [1, $id, $this->userId]);

        $response = $this->di->get("response");
        return $response->redirect("post/show/$post_id");
    }

    public function downvoteAction(int $id, int $post_id) : object
    {
        $page = $this->di->get("page");

        $sql = "INSERT INTO comment_votes (score, comment_id, user_id) VALUES (?, ?, ?);";
        $this->db->execute($sql, [-1, $id, $this->userId]);

        $response = $this->di->get("response");
        return $response->redirect("post/show/$post_id");
    }

    /**
     * Handler to change the status of answer accepted or unaccepted
     *
     * @return object as a response object
     */
    public function acceptAction(int $id, int $post_id) : object
    {
        $page = $this->di->get("page");
        //get the status of this answer
        $sql = "select accepted from comments where post_id=? and id=?;";
        $res = $this->db->executeFetchAll($sql, [$post_id, $id]);

        if ($res[0]->accepted==0) {
            $accepted =1;
        } elseif ($res[0]->accepted==1) {
            $accepted=0;
        }
        //change the status of this answer
        $sql = "update comments set accepted=? where post_id=? and id=?;";
        $this->db->execute($sql, [$accepted, $post_id, $id]);
        $response = $this->di->get("response");
        return $response->redirect("post/show/$post_id");
    }

    /**
     * Handler with form to update an item.
     *
     * @param int $id the id to answer.
     *
     * @return object as a response object
     */
    public function replyActionPost(int $id, int $post_id) : object
    {
        $request = $this->di->get("request");
        $response = $this->di->get("response");
        $submit = $request->getPost("submit") ?: null;

        if ($submit) {
            $comment = $request->getPost("comment") ?: null;
            $sql = "INSERT INTO comments (comment, comment_reply_id, post_id, user_id, answer) VALUES (?, ?, ?, ?, ?);";
            $this->db->execute($sql, [$comment, $id, $post_id, $this->userId, 0]);
            return $response->redirect("post/show/$post_id");
        }
    }

}
