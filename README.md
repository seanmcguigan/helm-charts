# helm-charts

A collection of service Helm charts, published as a Helm repository on GitHub Pages.

| Chart | Description |
| ----- | ----------- |
| [hello-world](charts/hello-world) | nginx demo chart (`helm create` scaffold) |

## Using the charts

```bash
helm repo add seanmcguigan https://seanmcguigan.github.io/helm-charts
helm repo update
helm search repo seanmcguigan

helm install my-release seanmcguigan/hello-world --version 0.1.0
```

## Repository layout

```
charts/<chart-name>/        one directory per chart (Chart.yaml, values.yaml, templates/)
.github/ct.yaml             chart-testing config
.github/workflows/
  lint-test.yaml            pull requests: lint changed charts
  release.yaml              push to main: publish new chart versions
```

`main` holds chart source only. Packaged `.tgz` files live in GitHub Releases, and
`index.yaml` lives on the `gh-pages` branch. Both are written by CI, so don't commit them.

## Adding a chart

```bash
helm create charts/my-service      # or copy an existing chart
helm lint charts/my-service
```

Edit `Chart.yaml` (`name`, `description`, `version`, `appVersion`) and `values.yaml`, then
open a pull request. CI lints it. Once merged to `main`, it is released automatically
and appears in `helm search repo`.

## Releasing a change to an existing chart

Bump `version` in the chart's `Chart.yaml` in the same pull request as the change.

- The PR check fails if a chart changed without a version bump.
- Releases are keyed on the version: a version that already has a GitHub Release
  (tagged `<chart>-<version>`) is skipped, so un-bumped changes are never published.
- Versions are immutable once released. Publish a new version rather than editing an old one.
