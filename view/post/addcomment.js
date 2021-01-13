function add() {
    var element = document.getElementById('comments');
    element.classList.toggle("hide");
}


function myFunction(id) {
    var idid="comment" + id;
    console.log(idid);
    var element = document.getElementById(idid);
    element.classList.toggle("hide");
}
