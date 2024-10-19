## Software provenance

> [!NOTE]
> These release assets were transparently built for easy verification of their provenance.

Using GitHub actions and workflows, binaries are verified using GitHub attestation and VirusTotal scanning, at build time, so that you can be certain the release assets you are using were transparently built from the source code.

- GitHub attestation will show where when and how the binary was built - [example](https://github.com/userdocs/iperf3-static/attestations/2474371)
- VirusTotal scanning will show the binary is malware free before release - [example](https://www.virustotal.com/gui/file/42647b55aae08c3b581e78e1a6bcadf2c7715d4edfc2c842ecbb194b0b47b084)

> [!TIP]
> The sha256sum of the GitHub attestations and VirusTotal scan should be the same for any release assets.

## GitHub artifact-attestations

<details closed>
<summary>Expand for details</summary>

Binaries built from the release of `3.17.1+` use [actions/attest-build-provenance](https://github.com/actions/attest-build-provenance) - [Github Docs](https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations/using-artifact-attestations-to-establish-provenance-for-builds#verifying-artifact-attestations-with-the-github-cli)

For example: using `gh` cli - [manual](https://cli.github.com/manual/gh_attestation_verify)

```bash
gh attestation verify iperf3-amd64 -o userdocs
```

</details>

<!-- Edit anything above this line to have to automatically update the release body. -->
<!-- If you need the URLs edited. Edit the release and delete the body text and it will updated from this file -->

<!-- split body -->
<!-- split urls -->

## VirusTotal scan results

<details closed>
<summary>Expand for details</summary>

Links to scan results

[iperf3-amd64]()

[iperf3-amd64-win]()

[iperf3-amd64-win-openssl]()

[iperf3-amd64-osx-13]()

[iperf3-arm64-osx-14]()

[iperf3-arm32v6]()

[iperf3-arm32v7]()

[iperf3-arm64v8]()

[iperf3-i386]()

[iperf3-ppc64le]()

[iperf3-riscv64]()

[iperf3-s390x]()

</details>
