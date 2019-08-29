# TheSun Docker Wp

### Check List
* Working ssh key which is linked to Newsuk git.
* Make sure 8081 port is not assigned.
* Make sure other proxy servers not running while creating containers.

### Process to setup docker
* `git clone git@github.com:newsukarun/TheSunDockerWp.git cd sun_vip_go`
* `cd sun_vip_go`
* `./thesun-vip-go-bash.sh`

Sit back and relax, when ever terminal ask you to type [y|n] type Y.

### This will setup following:
* Wp sites ( Php 7.3 )
* * Thesun
* * Thesun com
* * Talksport
* * Dreamteam
* * Irish site
* * Scotland site
* Wp cli
* Php Unit test
* Photon Service
* memmcache
* Precommit hooks
* PhpMyadmin

### Crediantials:
* Site Url :  `thesun.local`
* Site admin : `thesun.local/wp-admin` Username : `wordpress` , password: `wordpress`
* PhpMyadmin:
* * Url: `thesun.local:8081/`
* * Username : `root`
* * Password: `<empty>`
