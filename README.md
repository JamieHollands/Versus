# Scrub
## Versus Systems Coding Challenge | Jamie Hollands

### Challenge:

Create a function called **_scrub_** that sanitizes data by replacing
> name "a_name"  *with* name "******"

> username "a_username" *with* username "******"

> password "a_password *with* password "******"

> email "email@website.com" *with* "******@website.com"
***
### Dependencies:
* Erlang
* Elixir

### Description:

There are a couple of available options packaged up here.

The **Scrub** module contains the function **_scrub/1_**.

**_scrub/1_** with sanitize the following data structures
* Maps
* Keyword Lists
* Lists of Maps
* Lists of Keyword Lists
* Maps of Keyword Lists
* Keyword Lists of Maps
* Lists of Maps of Keyword Lists
* Lists of Keyword List of Maps
* And any remaining combinations


*Using **_scrub/1_***

start iex -S mix and start testing combinations of data structures

```elixir
iex> Scrub.scrub([name: "a_name", username: "username", password: "a_password", email: "email@website.com"])

[email: "******@website.com", name: "******", password: "******", username: "******"]


iex> Scrub.scrub(%{"name" => "a_name", "username" => "a_username", password: "a_password", email: "email@website.com"})

%{:email => "******@website.com", :password => "******", "name" => "******", "username" => "******"}


iex> Scrub.scrub([map: %{name: "a_name"}, username: "a_username", list: [password: "password"]])

[list: [password: "******"], map: %{name: "******"}, username: "******"]
```
I do not believe that Lists and Tuples are appropriate data structures to hold key value pairs such as 
> name "a_name"  

therefore they are not scrubbed, only returned.

```elixir
iex> Scrub.scrub([list: ["return", :this, "list"], tuple: {"plus", "this", :tuple}, scrub_this: [name: "a_name"]])

[list: ["return", :this, "list"], scrub_this: [name: "******"], tuple: {"plus", "this", :tuple}]
```

There are more use cases is scrub_test.exs and some structures testing to a depth of 6.  As well as in the Scrub doc tests.

**JsonScrub** and **_json_from_file/1_**

**_json_from_file/1_**

The example given in the challenge document uses a .json file.  I decided to make a simple json scrubber. **_json_from_file_/1** takes a location to a file as a string.  If it is not a .json file it will return saying so, if it is a.json file it will get scrubbed and output into the same directory as "original_file_name"_scrubbed.json.

see the directory /test_files for some examples and as well as the tests and doc tests in json_scrub_test.exs

**_json_from_file_/1** does not check the validity of a json file only the keys value pairs in it.  

using **_json_from_file_/1** 

start iex -S mix

```elixir
iex> JsonScrub.json_from_file("./test_files/user_1.json")
:ok
```
check the user_1_scrubbed.json for the scrubbed file

To just check a string you can use **_scrub_json/1_**.


> Note: if you use **_scrub_json/1_**, you have to format it like a loaded .json file. With the appropriate escape characters otherwise it will not get scrubbed


**_scrub_json/1_**

start iex -S mix

```elixir
iex> JsonScrub.scrub_json("{\\n \\"id\\": 123,\\n \\"name\\": \\"Elle\\"}")
    
"{\\n \\"id\\": 123,\\n \\"name\\": \\"******\\"}"
```

Have fun and thank you for this opportunity !
