<?php

namespace Pan\Post;

use Anax\Commons\ContainerInjectableInterface;
use Anax\Commons\ContainerInjectableTrait;

// use Anax\Route\Exception\ForbiddenException;
// use Anax\Route\Exception\NotFoundException;
// use Anax\Route\Exception\InternalErrorException;

/**
 * A sample controller to show how a controller class can be implemented.
 */
class PostController implements ContainerInjectableInterface
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
     * Show all items.
     *
     * @return object as a response object
     */
    public function indexActionGet() : object
    {
        $page = $this->di->get("page");

        // Get settings from GET or use defaults
        $request = $this->di->get("request");
        $orderBy = $request->getGet("orderby") ?: "created";
        $order = $request->getGet("order") ?: "asc";

        $sql = "SELECT * FROM v_all ORDER BY $orderBy $order;";

        $posts = $this->db->executeFetchAll($sql);

        $page->add("post/view-all", [
            "items" => $posts,
        ]);

        return $page->render([
            "title" => "All Posts",
        ]);
    }



    /**
     * Handler with form to create a new item.
     *
     * @return object as a response object
     */
    public function createActionGet() : object
    {
        if ($this->currentUser) {
            $page = $this->di->get("page");
            $page->add("post/create");

            return $page->render([
                "title" => "Ask Question",
            ]);
        }
        $response = $this->di->get("response");
        return $response->redirect("user/login");
    }


    public function createActionPost() : object
    {
        $request = $this->di->get("request");
        $response = $this->di->get("response");
        $submit = $request->getPost("submit") ?: null;

        if ($submit) {
            $title = $request->getPost("Title") ?: null;
            $content = $request->getPost("Body") ?: null;
            $tags = $request->getPost("Tags") ?: null;

            $sql = "INSERT INTO posts (title, content, user_id) VALUES (?, ?, ?);";
            $this->db->execute($sql, [$title, $content, $this->userId]);
            $lastInsertId = $this->db->lastInsertId();
            var_dump($lastInsertId);
            $tagsArray = explode(",", $tags);
            foreach ($tagsArray as $value) {
                $sql = "INSERT INTO post2tag (post_id, tag_name) VALUES (?, ?);";
                $this->db->execute($sql, [$lastInsertId, trim($value)]);
            }

            return $response->redirect("post");
        }
    }

    /**
     * Handler with form to update an item.
     *
     * @param int $id the id to answer.
     *
     * @return object as a response object
     */
    public function answerActionPost() : object
    {
        $page = $this->di->get("page");
        $request = $this->di->get("request");
        $submit = $request->getPost("submit") ?: null;
        // one has to login to answer the question
        if ($this->currentUser) {
            if ($submit) {
                $post_id = $request->getPost("post_id") ?: null;
                $comment = $request->getPost("answer") ?: null;

                $sql = "INSERT INTO comments (comment, user_id, post_id, answer) VALUES (?, ?, ?, ?);";
                $this->db->execute($sql, [$comment, $this->userId, $post_id, 1]);
                $response = $this->di->get("response");
                return $response->redirect("post/show/$post_id");
            }
        } else {
            $response = $this->di->get("response");
            return $response->redirect("user/login");
        }
    }

    /**
     * Handler to view an item.
     *
     * @param int $id the id to view.
     *
     * @return object as a response object
     */
    public function showAction(int $id) : object
    {
        $page = $this->di->get("page");
        $postid = $id;
        $request = $this->di->get("request");
        $orderBy = $request->getGet("orderby") ?: "created";
        $order = $request->getGet("order") ?: "asc";
        $sql = "SELECT * from posts WHERE id=?;";
        $posts = $this->db->executeFetchAll($sql, [$postid]);
        $sql = "select * from post2tag where post_id=?;";
        $posttags = $db->executeFetchAll($sql, [$item->id]);
        $sql = "SELECT sum(score) as postscore from post_votes where post_id=?;";
        $score = $this->db->executeFetchAll($sql, [$item->id]);
        $sql = "SELECT sum(answer) as totalanswer from comments where post_id=?;";
        $answer = $this->db->executeFetchAll($sql, [$item->id]);

        $sql = "SELECT * from v_comments_user WHERE post_id=? and answer=1 order by accepted desc, $orderBy $order;";
        //Get the answers for the post
        $answers = $this->db->executeFetchAll($sql, [$postid]);
        $sql = "SELECT * from v_comments_user WHERE post_id=? and answer=0 and ISNULL(comment_reply_id);";
        // Get the comments for the post
        $comments0 = $this->db->executeFetchAll($sql, [$postid]);


        // check if the current user is the owner of the question, if yes, show the accepted answer button otherwise not
        // var_dump($this->currentUser,$posts[0]->username  );
        $isOwner=true;
        if ($this->currentUser != $posts[0]->username ) {
            $isOwner = false;
        }
        $page->add("post/show",
            ["post"  => $posts[0],
             "postscore"  => $postscore[0]->postscore?:0,
             "totalanswer"  => $answer[0]->totalanswer?:0,
            "answers"  => $answers,
            "comments0"  => $comments0,
            "isOwner"  => $isOwner,
            ]);

        return $page->render([
            "title" => "Show a Post",
        ]);
    }

    public function uppvoteAction(int $id) : object
    {
        $page = $this->di->get("page");

        $sql = "INSERT INTO post_votes (score, post_id, user_id) VALUES (?, ?, ?);";
        $this->db->execute($sql, [1, $id, $this->userId]);


        $response = $this->di->get("response");
        return $response->redirect("post/show/$id");
    }

    public function downvoteAction(int $id) : object
    {
        $page = $this->di->get("page");

        $sql = "INSERT INTO post_votes (score, post_id, user_id) VALUES (?, ?, ?);";
        $this->db->execute($sql, [-1, $id, $this->userId]);


        $response = $this->di->get("response");
        return $response->redirect("post/show/$id");
    }
}
