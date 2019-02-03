{ owner, repo, rev, sha256 }: builtins.fetchTarball {
  inherit sha256;
  url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
}
