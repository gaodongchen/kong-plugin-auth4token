# Install
Install module of Lua
```bash
$ luarocks install kong-plugin-auth4token-0.0.1-0.all.rock
```
Start the plugin of Kong
```bash
$curl -i -X POST \
    --url http://localhost:8001/plugins/ \
    --data 'name=auth4token' \
    --data 'config.url=http://some.com/user/token'
```
