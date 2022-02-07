# File Upload

### Objective: Execute any PHP function of your choosing on the target system (such as [phpinfo()](https://secure.php.net/manual/en/function.phpinfo.php) or [system()](https://secure.php.net/manual/en/function.system.php)) thanks to this file upload vulnerability.

基本上如果可以上傳並執行任意檔案，就可以做很多事

OWASP 的文件整理得蠻詳細的，有提到上傳檔案也有不同的延伸應用和變化，例如壓縮後上傳以避免掃描或者塞爆硬碟空間之類的作法 XD

## 觀察

### 可以先測試檔案的型態, 大小, 格式 等限制

### 留意上傳檔案的位置，因為這代表我們有機會執行這個路徑上的檔案

試著上傳惡意檔案

這是目前頁面的路徑，可以看到檔案上傳的位置是在上上層

```markdown
http://localhost:8086/vulnerabilities/upload/
```

```markdown
http://localhost:8086/hackable/uploads/yo.php
```

將 `yo.php` 檔案內容換成 `phpinfo()` 即可

## memo

### 這部分也可以跟 Command injection 混搭測試，執行上傳的惡意檔案

```
;php /var/www/html/hackable/uploads/yo.php
```
