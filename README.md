# writeups

## DVWA

### DVWA security:low
```
./DVWA/low
```

### Run DVWA

```
docker run -d -p 8086:80 vulnerables/web-dvwa
```
### Change configs of DVWA

```
docker exec -it app-training-dvwa /bin/bash
```
```
apt update -y && apt install vim -y
```

Enable allow_url_include and add your reCAPTCHA key 

in `/etc/php/7.0/apache2/php.ini`:
```
allow_url_include = on
```

in `/var/www/html/config/config.inc.php`
```
$_DVWA[ 'recaptcha_public_key' ] = '<your reCAPTCHA public key>';
$_DVWA[ 'recaptcha_private_key' ] = '<your reCAPTCHA private key>';
```

```
service apache2 restart
```

## Ref

digininja/DVWA: Damn Vulnerable Web Application (DVWA)
https://github.com/digininja/DVWA

opsxcq/docker-vulnerable-dvwa: Damn Vulnerable Web Application Docker container
https://github.com/opsxcq/docker-vulnerable-dvwa
