# writeups

## DVWA

### DVWA security:low
精簡版筆記:
```
./DVWA/**/low.md
```

完整版筆記:
```
./DVWA/notion-export/index.html
./DVWA/notion-export/index.md
```

Notion:

[DVWA Writeup](https://dogev0x.notion.site/DVWA-7ed9db8c64ed4531a35a5f585e5a205f "DVWA")

### Run DVWA

```
docker run -d -p 8086:80 vulnerables/web-dvwa
```
### Change configs of DVWA

install deps (optional)

```
docker exec -it app-training-dvwa /bin/bash
```
```
apt update -y && apt install vim -y
```

Enable allow_url_include and add your reCAPTCHA key 

### allow_url_include
in `/etc/php/7.0/apache2/php.ini`:
```
allow_url_include = on
```
or
```
docker cp ./DVWA/configs/php.ini <container_id>:/etc/php/7.0/apache2/
```
### reCAPTCHA

in `/var/www/html/config/config.inc.php`
```
$_DVWA[ 'recaptcha_public_key' ] = '<your reCAPTCHA public key>';
$_DVWA[ 'recaptcha_private_key' ] = '<your reCAPTCHA private key>';
```
or
```
docker cp ./DVWA/configs/php.ini <container_id>:/var/www/html/config/
```

### restart service

```
service apache2 restart
```

## Ref

digininja/DVWA: Damn Vulnerable Web Application (DVWA)
https://github.com/digininja/DVWA

opsxcq/docker-vulnerable-dvwa: Damn Vulnerable Web Application Docker container
https://github.com/opsxcq/docker-vulnerable-dvwa
