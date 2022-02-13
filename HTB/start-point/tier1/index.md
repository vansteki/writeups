# HTB writeup - Starting Point tier0

Created time: February 10, 2022 2:13 PM
Last Edited: February 13, 2022 9:46 PM
Property: February 10, 2022 2:13 PM
Tags: HTB, Sec, tier0, writeup
URL: https://app.hackthebox.com/starting-point

---

---

# ::Starting Point

基本上這篇比較像是熟悉 HTB 的使用方式，難度是 very easy，就是基本知識的等級

官方也有附上 writeup

## Setting

### use pwnbox

不用設定，直接用瀏覽器連到測試環境

也可以在 pwnbox instance 產生後再從 host 用 VNC (or xRDP) 連到到 pwnbox

### VPN

use openvpn in your VM or host machine to connect to HTB network

記得用 `sudo`

```bash
sudo openvpn <your-downloaded-openvpn-pack>.ovpn
```

### SSH

用他們提供的密碼登入

GS: Introduction to Pwnbox | Hack The Box Help Center
[https://help.hackthebox.com/en/articles/5185608-gs-introduction-to-pwnbox](https://help.hackthebox.com/en/articles/5185608-gs-introduction-to-pwnbox)

---

# Meow - Account Misconfiguration (FTP)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled.png)

[Hack The Box](https://app.hackthebox.com/starting-point)

---

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%201.png)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%202.png)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%203.png)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%204.png)

好像出了些問題，無法繼續下一關，所以重來一次．就可以繼續回答接下來的問題了，這關只是確認你會用 openvpn or pwnbox 連線，還有回答一些基本問題而已

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%205.png)

```
10.129.24.43
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%206.png)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%207.png)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%208.png)

openvpn network interface 通常都是 tun開頭，e.g `tun0`, `tun1`

```bash
tun
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%209.png)

接下來是一連串的小 task，這邊都是常識題

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2010.png)

```bash
ping
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2011.png)

```bash
nmap
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2012.png)

```bash
telnet
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2013.png)

```bash
root
```

最後一個 task 就是暗示你用 telnet 連進靶機，取得 flag

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2014.png)

### use nmap -Pn to ping it

```bash
nmap -Pn 10.129.24.43
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2015.png)

看起來機器活著，那接下來是著 test port 23

```bash
nmap -v -Pn -p 23 10.129.24.43
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2016.png)

### 靶機有時候會不正常

不過後來發現怪怪的，因為所有 port 都是 filterd，reset 靶機和重新連線也無效，最後切換成歐洲的線路，靶機才正常運作 QQ 

現在恢復正常了...

疑 等等 有點奇怪，我忘了加 `-` 在 `Pn` 前面，所以 nmap 掃描的主機是一台叫 `Pn` 的 server @@

```bash
nmap -v Pn 10.129.14.224
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2017.png)

拍照留念一下

繼續回來練習

```bash
nmap -v -Pn 10.129.14.224
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2018.png)

### port 23 is open

```bash
nmap -sV 10.129.14.224
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2019.png)

```bash
telnet 10.129.14.224
```

用 telenet 連線，直接用 root 登入不用密碼

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2020.png)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2021.png)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2022.png)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2023.png)

### get flag

```bash
b40abdfe23665f766f9c61ecba8a4c19
```

提交時要用加上 `HTB{...}` 在外面

```bash
HTB{b40abdfe23665f766f9c61ecba8a4c19}
```

![[https://www.hackthebox.com/achievement/machine/929350/394](https://www.hackthebox.com/achievement/machine/929350/394)](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2024.png)

[https://www.hackthebox.com/achievement/machine/929350/394](https://www.hackthebox.com/achievement/machine/929350/394)

# Fawn - Account Misconfiguration (FTP)

這題單純讓你練習 FTP

```
10.129.200.227
```

有一些常識題，可以幫你複習一些知識，因為太基礎，有些 task 就不做紀錄

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2025.png)

確認靶機 FTP version，用 `-sV` (scan port and service) scan 就可以看出來

答案是 `ftp vsftpd 3.0.3`

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2026.png)

```bash
nmap -Pn -T5 -F -sV 10.129.200.227
```

```bash
nmap -Pn -T5 -p21 -sV 10.129.200.227
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2027.png)

```bash
21/tcp open  ftp vsftpd 3.0.3
Service Info: OS: Unix
```

找出 OS type，用 nmap scan 即可

答案是 `Unix`

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2028.png)

```bash
sudo nmap -T4 -A 10.129.200.227
```

```bash
sudo nmap -T5 -O 10.129.200.227
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2029.png)

可以看出是 Linux

可以趁機熟悉一下 nmap 預設的行為，例如 我只想 fingerprint OS，但不想掃 port

但沒辦法，因為 port scan 是它用來判斷 OS 的方式之一

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2030.png)

在你很了解環境的情況下，可以用 `-F -Pn -T5` 來減少不必要的掃描和加快速度

### -F 會址掃描 100個 port

### -Pn assume target is alive

### -T5 最快速度

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2031.png)

不猜測 OS 的話，scan 100 ports 約 2~2 秒

```bash
nmap -Pn -T5 -F 10.129.200.227
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2032.png)

加上 guess OS 約 9~15 秒

```bash
nmap -Pn -T5 -F -O 10.129.200.227
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2033.png)

### get flag

```bash
sudo apt install ftp -y
ftp $target
```

用 ftp 指令需要輸入帳密，沒什麼頭緒，後來改用 filezilla 就順定進去了 @@，因為前面有暗示 filezilla 這套 ftp app

```bash
sudo apt install filezilla -y
```

```bash
ftp -v -p -n 10.129.187.227
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2034.png)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2035.png)

```bash
Status:	Connecting to 10.129.200.227:21...
Status:	Connection established, waiting for welcome message...
Status:	Insecure server, it does not support FTP over TLS.
Status:	Server does not support non-ASCII characters.
Status:	Logged in
Status:	Retrieving directory listing...
Status:	Directory listing of "/" successful
Status:	Connecting to 10.129.200.227:21...
Status:	Connection established, waiting for welcome message...
Status:	Insecure server, it does not support FTP over TLS.
Status:	Server does not support non-ASCII characters.
Status:	Logged in
Status:	Starting download of /flag.txt
Status:	File transfer successful, transferred 32 bytes in 1 second
Status:	Disconnected from server
Status:	Connection closed by server
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2036.png)

```bash
035db21c881520061c53e0536e44f815
```

![[https://www.hackthebox.com/achievement/machine/929350/393](https://www.hackthebox.com/achievement/machine/929350/393)](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2037.png)

[https://www.hackthebox.com/achievement/machine/929350/393](https://www.hackthebox.com/achievement/machine/929350/393)

---

## Dancing

Windows SMB 題

SMB runs at the Application or Presentation layers of the OSI model,

The Transport layer protocol that Microsoft SMB Protocol is most often used with is NetBIOS over TCP/IP (NBT). This is why, during scans, we will most likely see both protocols with open ports running on the target.

```
10.129.112.127
```

## Tasks

### What does the 3-letter acronym SMB stand for? → `Server Message Block`

### What port does SMB use to operate at? → `445` , `137 138 UDP, 139 TCP`

Windows:`445`

for communicate with Non-Windows (NetBIOS Name Service):  `137 138 UDP, 139 TCP`

### What is the service name for port 445 that came up in our nmap scan → `microsoft-ds`

```
nmap -T5 -Pn -sV 10.129.112.127
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2038.png)

### What is the tool we use to connect to SMB shares from our Linux distribution? → `smbclient`

```
smbclient -L 10.129.112.127
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2039.png)

列出 server 分享的資源，有些需要帳密進不去

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2040.png)

```
Enter WORKGROUP\root's password: 

	Sharename       Type      Comment
	---------       ----      -------
	ADMIN$          Disk      Remote Admin
	C$              Disk      Default share
	IPC$            IPC       Remote IPC
	WorkShares      Disk      
SMB1 disabled -- no workgroup available
```

try to connect to  ADMIN$ but failed

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2041.png)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2042.png)

試著瀏覽 `WorkSpace$`

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2043.png)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2044.png)

D 代表資料夾，所以可以進去裡面逛逛

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2045.png)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2046.png)

### flag

Use `get` to download a file from remote or `mget` to download multiple files

```
get Amy.J
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2047.png)

```
5f61c10dffbc77a704d76016a22f1664
```

![[https://www.hackthebox.com/achievement/machine/929350/395](https://www.hackthebox.com/achievement/machine/929350/395)](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2048.png)

[https://www.hackthebox.com/achievement/machine/929350/395](https://www.hackthebox.com/achievement/machine/929350/395)

---

# Explosion (RDP)

```
10.129.197.50
```

## Tasks

### What is the concept used to verify the identity of the remote host with SSH connections?

`public-key cryptography` aka Asymmetric cryptography

### What is the name of the tool that we can use to initiate a desktop projection to our host using the terminal?

`xfreerdp`

### What is the name of the service running on port 3389 TCP?

`ms-wbt-server`

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2049.png)

```
Starting Nmap 7.92 ( https://nmap.org ) at 2022-02-12 23:24 CST
Nmap scan report for 10.129.10.224
Host is up (0.21s latency).

PORT     STATE SERVICE       VERSION
3389/tcp open  ms-wbt-server Microsoft Terminal Services
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 7.45 seconds
```

### What is the switch used to specify the target host's IP address when using xfreerdp? → `/v:`

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2050.png)

嘗試失敗

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2051.png)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2052.png)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2053.png)

看 writeup 是使用 `/u:` 指定 user，可以先 try `user` `admin` `Administrator`  這類預設的帳號

使用 Administrator，password 直接 enter 不輸入

```
xfreerdp /v:10.129.197.50 /u:Administrator
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2054.png)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2055.png)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2056.png)

```
951fa96d7830c451b536be5a6be008a0
```

![[https://www.hackthebox.com/achievement/machine/929350/396](https://www.hackthebox.com/achievement/machine/929350/396)](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2057.png)

[https://www.hackthebox.com/achievement/machine/929350/396](https://www.hackthebox.com/achievement/machine/929350/396)

---

# Preignition (dir busting)

這關主要是體驗 dir busting，使用 gobuster

```
10.129.109.218
```

gobuster

OJ/gobuster: Directory/File, DNS and VHost busting tool written in Go
[https://github.com/OJ/gobuster](https://github.com/OJ/gobuster)

## Tasks

用 nmap scan 基本資訊

```
80/tcp http nginx 1.14.2
```

```
curl 10.129.109.218
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2058.png)

```
nmap -Pn -sV -T5 10.129.109.218
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2059.png)

```
gobuster
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2060.png)

### What switch do we use to specify to gobuster we want to perform dir busting specifically? → `dir`

```
gobuster dir --help
```

基本上用到的就這是個 options

```
dir : specify we are using the directory busting mode of the tool
-w : specify a wordlist, a collection of common directory names that are typically used
for sites
-u : specify the target's IP address
```

### shared wordlist

```
/usr/share/wordlists
```

```
/usr/share/wordlists/dirb/common.txt
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2061.png)

```
gobuster dir / -u 10.129.109.218 -w /usr/share/wordlists/dirb/common.txt
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2062.png)

found a path

```
/admin.php            (Status: 200) [Size: 999]
```

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2063.png)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2064.png)

用 admin:admin try try 看就登入了

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2065.png)

![[https://www.hackthebox.com/achievement/machine/929350/397](https://www.hackthebox.com/achievement/machine/929350/397)](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2066.png)

[https://www.hackthebox.com/achievement/machine/929350/397](https://www.hackthebox.com/achievement/machine/929350/397)

![Untitled](HTB%20writeup%20-%20Starting%20Point%20tier0%20c34b0f3b6dc441bb9ff22450fd9886c2/Untitled%2067.png)

---

# Ref

- [Hack The Box :: Login](https://app.hackthebox.com/login)
- [GS: Introduction to Pwnbox | Hack The Box Help Center](https://help.hackthebox.com/en/articles/5185608-gs-introduction-to-pwnbox)
- [OJ/gobuster: Directory/File, DNS and VHost busting tool written in Go](https://github.com/OJ/gobuster)