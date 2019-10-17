<script>
  import { onMount } from 'svelte';
  let showSignup = true;

  onMount(async function() {
    const response = await fetch('http://' + process.env.APIURL + '/auth/token');
    const json = await response.json();
    console.log(json);
  })
</script>

<style>
  .form {
    background-color: var(--bg-med);
    padding: 40px;
    max-width: 600px;
    margin: 40px auto;
    border-radius: 3px;
    box-shadow: 5px 5px var(--text-secondary);
  }

  .tab-group {
    list-style: none;
    padding: 0;
    margin: 0 0 40px 0;
  }

  .tab-group:after {
    content: "";
    display: table;
    clear: both;
  }

  .tab-group li a {
    display: block;
    text-decoration: none;
    padding: 15px;
    /*background-color: */
    color: var(--text-main);
    font-size: 20px;
    float: left;
    width: 50%;
    text-align: center;
    cursor: pointer;
    transition: 0.5s ease;
  }

  .tab-group li a:hover {
    background: #179b77;
    color: #fff;
  }

  .tab-group .active a {
    background: #1ab188;
    color: #fff;
  }

  .tab-content > div:last-child {
    display: none;
  }

  label {
    position: absolute;
    transform: translateY(6px);
    left: 13px;
    color: rgba(255,255,255,0.5);
    transition: all 0.25s ease;
    -webkit-backface-visibility: hidden;
    pointer-events: none;
    font-size: 22px;
  }

  label .req {
    margin: 2px;
    color: #1ab188;
  }

  label .active {
    transform: translateY(50px);
    left: 2px;
    font-size: 14px;
  }
  
  label .active .req {
    opacity: 0;
  }

  label .highlight {
    color: #fff;
  }

  input, textarea {
    font-size: 22px;
    display: block;
    width: 100%;
    height: 100%;
    padding: 5px 10px;
    background: none;
    background-image: none;
    border: 1px solid #a0b3b0;
    color: #fff;
    border-radius: 0;
    transition: border-color 0.25s ease, box-shadow 0.25s ease;
  }

  input:focus, textarea:focus {
    outline: 0;
    border-color: #1ab188;
  }

  textarea {
    border: 2px solid #a0b3b0;
    resize: vertical;
  }

  .field-wrap {
    position: relative;
    margin-bottom: 40px;
  }

  .top-row:after {
    content: "";
    display: table;
    clear: both;
  }

  .top-row > div {
    float: left;
    width: 48%;
    margin-right: 4%;
  }

  .top-row > div:last-child {
    margin: 0;
  }

  .button {
    border: 0;
    outline: none;
    border-radius: 0;
    padding: 15px 0;
    font-size: 2rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.1em;
    background: #1ab188;
    color: #fff;
    transition: all 0.5s ease;
    -webkit-appearance: none;
  }

  .button:hover, .button:focus {
    background: #179b77;
  }
  
  .button-block {
    display: block;
    width: 100%;
  }
</style>

<login>
  <div class='form'>
    <ul class='tab-group'>
      <li class='tab active'>
        <a 
          href='/login/#signup'
        >
          Sign Up
        </a>
      </li> 
      <li class='tab'><a href='/login/#login'>Login</a></li>
    </ul>
    <div class='tab-content'>
      <div id='signup'>
        <h1>Arrr, get on board!</h1>
        <form action='/'>
          <div class='field-wrap'>
            <label>
              Email<span class='req'>*</span>
            </label> 
            <input type='text' required autocomplete='off' />
          </div>
          <div class='field-wrap'>
            <label>
              Set a password<span class='req'>*</span>
            </label>
            <input type='password' required autocomplete='off' />
          </div>
          <button type='submit' class='button button-block'>Come aboard</button>
        </form>
      </div> 
      <div id='login'>
        <h1>Welcome back, Cyber Bos'n</h1> 
        <form action='/'>
          <div class='field-wrap'>
            <label>
              Email<span class='req'>*</span>
            </label>
            <input type='email' required autocomplete='off' />
          </div>
          <div class='field-wrap'>
            <label>
              Password<span class='req'>*</span>
            </label> 
            <input type='password' required autocomplete='off' />
          </div>
          <button type='submit' class='button button-block'>Now git on this ship!</button>
        </form>
      </div>
    </div>
  </div>
</login>