# bbin workers
```shell
wrangler init "<name>"
```
https://dev.to/siddharthshyniben/new-in-nodejs-v18-1lmf
```node
fetch('https://jsonplaceholder.typicode.com/todos/1').then(response => response.json()).then(json => console.log(json))
fetch('https://jsonplaceholder.typicode.com/todos/1').then(response => response.json()).then(json => console.log(json.body))
fetch('https://clt.mnopi.com').then(response => console.log(response))
```

```shell
cfcli find --type AAAA --query name:clt.mnopi.com --format json
cfcli find --type AAAA --query name:clt.mnopi.com --format json | jq
cfcli find --type AAAA  --format json | jq -r .[].name
```
