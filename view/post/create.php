<?php

namespace Anax\View;

$urlToViewall = url("post");
?>
<h1>Ask a question</h1>
<form method='post'>
<fieldset>

<p>
<label for='form-element-Title'>Title:</label><br>
<input id='form-element-Title' type='text' name='Title'/>

</p>
<p class='cf-desc'></p><p>
<label for='form-element-Body'>Body:</label><br>
<textarea id='form-element-Body' name='Body'></textarea>
</p>
<p class='cf-desc'></p><p>
<label for='form-element-Tags'>Tags:</label><br>
<input id='form-element-Tags' type='text' name='Tags' placeholder="wedding,plant,flower"/>

</p>

<p class="buttonbar">
<span>
<input id='form-element-submit' type='submit' name='submit' value='Post the question' />
</span>
</p>


</fieldset>
</form>

<p>
    <a href="<?=$urlToViewall ?>">Browser all questions</a>
</p>
