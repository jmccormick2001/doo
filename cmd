*) modify the bundle/manifests/doo.clusterserviceversion.yaml to 
specify the correct image:  quay.io/jemccorm/doo-operator:v0.0.1

*) operator-sdk init --domain=example.com --repo=github.com/example-inc/doo-operator

*) operator-sdk create api --group cache --version v1 --kind Doo --resource=true --controller=true

*) make bundle

*) make docker-build docker-push IMG=quay.io/jemccorm/doo-operator:v0.0.1

*) docker build -f bundle.Dockerfile -t quay.io/jemccorm/doo-operator-bundle:v0.0.1 .

*) docker push quay.io/jemccorm/doo-operator-bundle:v0.0.1

*) opm index add --bundles quay.io/jemccorm/doo-operator-bundle:v0.0.1 --tag quay.io/jemccorm/doo-operator-index:v0.0.1

*) podman push quay.io/jemccorm/doo-operator-index:v0.0.1

*) NOTE:  if you create your own namespace, then you will need to create
an operatorgroup in that namespace

*) deploy catalogsource to namespace 'olm'

kind: CatalogSource
metadata:
  name: doo-operator
  namespace: olm
spec:
  sourceType: grpc
  image: quay.io/jemccorm/doo-operator-index:v0.0.1

*) create a subscription in the 'operators' namespace

apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: doo-subscription
  namespace: operators 
spec:
  channel: alpha
  name: doo
  source: doo-operator
  sourceNamespace: olm

*) verify it all works

breve:[~/projects/doo] kubectl -n operators get subscription
NAME               PACKAGE   SOURCE         CHANNEL
doo-subscription   doo       doo-operator   alpha

breve:[~/projects/doo] kubectl -n operators get csv
NAME         DISPLAY        VERSION   REPLACES   PHASE
doo.v0.0.1   doo-operator   0.0.1                Succeeded

breve:[~/projects/doo] kubectl -n operators get pod
NAME                                      READY   STATUS    RESTARTS   AGE
doo-controller-manager-6c4bdf7db6-jcvpn   2/2     Running   0          10m

*) create a CR in another namespace 

        {
          "apiVersion": "cache.example.com/v1",
          "kind": "Doo",
          "metadata": {
            "name": "doo-sample"
          },
          "spec": {
            "foo": "bar"
          }
        }

kubectl -n default create -f cr.json

