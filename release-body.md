## Software provenance

> [!TIP] These release assets can be transparently verified to verify their provenance.

Using Github actions and workflows, the binaries are verified using Github attestation and VirusTotal scanning at build time so that you can be certain the release assets you are using were transparently built from the source code.

## Github artifact-attestations

<details closed>
<summary>Expand for details</summary>

Binaries built from the release of `3.17.1+` use [actions/attest-build-provenance](https://github.com/actions/attest-build-provenance) - [Github Docs](https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations/using-artifact-attestations-to-establish-provenance-for-builds#verifying-artifact-attestations-with-the-github-cli)

For example:, using `gh` cli - [manual](https://cli.github.com/manual/gh_attestation_verify)

```bash
gh attestation verify iperf3-amd64 -o userdocs
```

> [!NOTE]
> For the windows builds the `zip`, `iperf3.exe` and `cygwin1.dll` are verified.
>
> For Linux builds the main static binary is verified.

> [!TIP]
> The sha256sum of the Github attestations and VirusTotal will be the same.

</details>

## VirusTotal scan results

<details closed>
<summary>Expand for details</summary>

[iperf3-amd64]()

[iperf3-amd64-openssl-win]()

[iperf3-amd64-win]()

[iperf3-arm32v6]()

[iperf3-arm32v7]()

[iperf3-arm64v8]()

[iperf3-i386]()

[iperf3-ppc64le]()

[iperf3-riscv64]()

[iperf3-s390x]()

</details>
