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

[iperf3-amd64](https://www.virustotal.com/gui/file/84f9851d0647d3d618c66d64cac10ed1eb37583b3aaf3bb0baac88bf446fb10a)

[iperf3-amd64-openssl-win]()

[iperf3-amd64-win]()

[iperf3-arm32v6](https://www.virustotal.com/gui/file/b36b7535bf7556aa3db2066d0d109bdb31d36a9133ca0439b05eee517bd2da5f)

[iperf3-arm32v7](https://www.virustotal.com/gui/file/52c46a52c0d66006a0a605b0db7bbd5f94b435b70b4d3bd181334817b88a777c)

[iperf3-arm64v8](https://www.virustotal.com/gui/file/155eaaa6a7e2a8a7dd7518e8f3ef559a6032490b0b64b04c79a46fdcffec3e6f)

[iperf3-i386](https://www.virustotal.com/gui/file/3d9198606de7452687cd1332f19cc1b01acc423b893439d0c3b40a4dba413e10)

[iperf3-ppc64le](https://www.virustotal.com/gui/file/c917b8d7ba981bd1b611f7f719e7ea4059af2c05b56fcbd2d9770e13d2c2a5af)

[iperf3-riscv64](https://www.virustotal.com/gui/file/4ae2fb95ae0956b8977286088b5d84743a5a7d5446c0b2ef7b3b5ae530bc4b71)

[iperf3-s390x](https://www.virustotal.com/gui/file/0a2936974f201ed761e7af049bf7d4621956061bb7797bad1a97a9974190af71)

</details>
