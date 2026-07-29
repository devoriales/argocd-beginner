# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell
git clone git@github.com:devoriales/argocd-beginner.git
# cd into the cloned directory
git checkout 92aaf109b1e8855f0d4aae5cf62a6e40b024a8ae
kustomize build ./module-04-deploying-applications/02-kustomize/overlays/prod
```
