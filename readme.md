# SSH Ayrıntılar
**Linuxta ssh-client "~/.ssh" dizini altında ayarlarını saklar. Birçok server ve client aynı konumda verilerini tutar. Bu dizinde bağlantılar için gerekli olan private ve public keyler tutulur. Ayrıca konfigürasyon dosyaları da vardır.**


**~/.ssh/known_hosts dosyasında bağlanılan serverların **fingerprint** leri tutulur. Fingerprintler MITM saldırılarından korunmak için yararlıdır çünkü server'ın fingerprinti değişmişse bu bize bildirilir. Yani her zamanki bağlandığımız server mı yoksa aynı IP yi spooflayan başka birisi mi olduğunu anlarız.**


**SSH bağlanma**
> $ ssh root@<ssh_server_address>


**SSH Configuration**

*~/.ssh/config*
```
Host my_ssh_config_name
    HostName 200.78.44.7
    User root
    Port 22
    IdentityFile ~/.ssh/my_private.key
    StrictHostKeyChecking no
```

**Servere Bağlan**
> $ ssh my_ssh_config_name

## SSH Anahtarı oluşturma
**Normal koşullarda aşağıdaki komut ~/.ssh/ dizinine id_rsa ve
id_rsa.pub adlı private ve public key oluşturur. Bu dizin altındaki bu formattaki dosyalar halinde ssh keyler tutulur.**
> $ ssh-keygen

**Create SSH Key Pair**
>> \$ ssh-keygen -t rsa -b 4096 -f /path/to/private_key -C "root@my_server hatırlatma notları..."
>
>
>> $ ssh-keys -t ed25519 -b 4096 -f /path/to/private_key -C "my server" -f ~/.ssh/my_server_id_ed25519  *# Daha güvenli ve kısa keyli algoritma*

 **Ve oluşturduğumuz clienttan servera bağlanabilmemiz için buradaki 
**id_rsa.pub** içerisindeki 
public key'i serverdaki **~/.ssh/authorized_keys** dosyasına satır olarak eklememiz gerekir.
Bunu kolayca yapmanın bir diğer yolu şu komuttur:**
> $ ssh-copy-id -i ~/.ssh/id_rsa.pub root@200.78.44.7 -p 2222

**ssh-agent çalıştırılır. Password ile giriş yapılıyorsa, ssh, memoryde bu password'ı tutar ve bir daha yeniden başlayana kadar sormaz.**
> \$ eval "$(ssh-agent)"

**Add Private Key  To Memory**
> $ ssh-add /path/to/private_key

**List Keys**
> $ ssh-add -l

**Remove Private Key**
> $ ssh-add -d /path/to/private_key

**Connect Host**
> $ ssh -i /path/to/private_key user@hostname

## SSH Yönetimi

**Çoğu linux serverda "sshd" adında bir daemon çalışır. Bu servis ssh bağlantılarını bekler.** 

*Durumunu kontrol et ve sürekli açık bırak*

> $ systemctl status sshd # ssh

> $ systemctl enable sshd # ssh

**SSH'i yönetebilmek için /etc/ssh dizininden yararlanılır.**

*/etc/ssh/sshd_config dosyası ayarları tutar.*

**Bu dosyadaki bazı ayarlar şu şekilde olmalıdır.**

Parola ile ssh'a izin ver.
- PasswordAuthentication no

Root ile giriş sadece gerekliyse ayarla
- PermitRootLogin yes

**SSH klasörünün izni doğru olmalıdır.**
> $ chmod -R 644 ~/.ssh

**SSH Logs**
> $ tail -f /var/log/auth.log

> $ journalctl -fu ssh