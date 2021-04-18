#!/usr/bin/env python

import dataclasses
from os import write
import sys
import subprocess
import json
import logging
from copy import deepcopy
from dataclasses import dataclass, field
from glob import glob
from typing import Dict, List, Optional
import pyparsing as pp

additional_packages = [
    {
        'name': "nose",
        'fetcher': "github",
        'repo': "emacsattic/nose",
        'rev': "f8528297519eba911696c4e68fa88892de9a7b72",
    }
]
blacklist = [
    # built-ins and not actual
    "css-mode",
    "elisp-mode",
    "hideshow",
    "ruby-mode",
    "shell",
    "smerge-mode",
    "straight",
    "term",
    "vc",
    "vc-annotate",

    # problematic
    "evil-magit",
    "gnuplot"
]
copyvcs = {
    "treemacs": [
        "treemacs-evil",
        "treemacs-projectile",
        "treemacs-magit",
        "treemacs-persp",
    ],
    "flyspell-correct": [
        "flyspell-correct-ivy",
        "flyspell-correct-helm",
        "flyspell-correct-popup",
    ],
}
melpa_json_path = "/repos/melpa/recipes-archive-melpa.json"
pinned_file = f"{sys.path[0]}/pinned.json"

logging.basicConfig(level=logging.DEBUG)


@dataclass
class Package:
    name: str
    fetcher: Optional[str] = field(default=None)
    repo: Optional[str] = field(default=None)
    rev: Optional[str] = field(default=None)
    sha256: Optional[str] = field(default=None)
    origin: Optional[str] = field(default=None)

    @classmethod
    def from_sexp(cls, sexp):
        data = {}
        s = deepcopy(sexp)
        while s:
            val = s.pop(0)
            if val == "package!":
                data["name"] = s.pop(0)
            elif val == ":pin":
                data["rev"] = s.pop(0).strip('"')
            elif val == ":recipe":
                d = s.pop(0)
                sub = d if d != "`" else s.pop(0)
                while sub:
                    subval = sub.pop(0)
                    if subval == ":host":
                        data["fetcher"] = sub.pop(0).strip('"')
                    elif subval == ":repo":
                        data["repo"] = sub.pop(0).strip('"')
                    else:
                        sub.pop(0)
            else:
                s.pop(0)

        return cls(**data)


def get_project_root():
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True
    )
    if result.returncode > 0:
        raise RuntimeError(result)
    return result.stdout.strip("\n")


def get_flake_key(flake_path: str, key: str):
    result = subprocess.run(
        [
            "nix-instantiate",
            "--eval",
            "--expr",
            'let fl = builtins.getFlake "{}"; in fl.{}'.format(flake_path, key),
        ],
        capture_output=True,
        text=True,
    )
    if result.returncode > 0:
        raise RuntimeError(result)
    return str.join("\n", result.stdout.splitlines())


def build_packages_el_parser():
    sexp = pp.OneOrMore(pp.nestedExpr())
    sexp.ignore(pp.Literal(";") + pp.restOfLine)
    return sexp


def flatten_package_sexp(sexps):
    nested = deepcopy(sexps)
    while nested:
        sublist = nested.pop(0)
        if not isinstance(sublist, list) or len(sublist) < 1:
            continue
        if sublist[0] == "package!":
            yield sublist
        else:
            nested = sublist + nested


def load_doom_packages(root_path: str) -> List[Package]:
    doom_emacs_src = get_flake_key(
        root_path, "inputs.nix-doom-emacs.inputs.doom-emacs.outPath"
    ).strip('"')
    packages_els = glob("{}/**/packages.el".format(doom_emacs_src), recursive=True) + [
        f"{sys.path[0]}/doom.d/packages.el"
    ]
    pkgs: Dict[str, Package] = {}
    for el in packages_els:
        data = build_packages_el_parser().parseFile(el)
        for sexp in flatten_package_sexp(data.asList()):
            pkg = Package.from_sexp(sexp)
            prev = pkgs.get(pkg.name)
            if prev:
                prev.fetcher = pkg.fetcher or prev.fetcher
                prev.repo = pkg.repo or prev.repo
                prev.rev = pkg.rev or prev.rev
            else:
                pkgs[pkg.name] = pkg
    return list(pkgs.values())


def get_unpinned(pkgs: List[Package]):
    unpinned_pkgs: List[str] = []
    for pkg in pkgs:
        if not pkg.rev and pkg.name not in [
            name for names in copyvcs.values() for name in names
        ]:
            unpinned_pkgs.append(pkg.name)
    return unpinned_pkgs


def load_melpa_json(root_path: str):
    emacs_overlay_src = get_flake_key(
        root_path, "inputs.nix-doom-emacs.inputs.emacs-overlay.outPath"
    ).strip('"')
    with open(f"{emacs_overlay_src}{melpa_json_path}") as f:
        return json.loads(f.read())


def hydrate_from_melpa(pkgs: List[Package], melpa_json):
    pkgs = deepcopy(pkgs)
    logging.debug(f"Load data from melpa archive")
    pkg_names = [x.name for x in pkgs]
    for mpkg in filter(lambda x: x.get("ename") in pkg_names, melpa_json):
        for pkg in pkgs:
            if pkg.name == mpkg.get("ename"):
                pkg.origin = "melpa"
                if not (pkg.fetcher and pkg.repo):
                    pkg.fetcher = mpkg.get("fetcher")
                    pkg.repo = mpkg.get("repo") or mpkg.get("url")
    return pkgs


def copy_vcs(pkgs):
    pkgs = deepcopy(pkgs)
    for pkg in pkgs:
        if pkg.name in copyvcs.keys():
            src = pkg
            for to in filter(lambda x: x.name in copyvcs.get(src.name), pkgs):
                logging.info(f"Copy VCS data from {src.name} to {to.name}")
                to.fetcher = to.fetcher or src.fetcher
                to.repo = to.repo or src.repo
                to.rev = to.rev or src.rev
    return pkgs


def load_old_data() -> List[Package]:
    pkgs = []
    try:
        with open(pinned_file, "r") as f:
            data = json.loads(f.read())
    except json.decoder.JSONDecodeError:
        return pkgs
    for d in data:
        pkgs.append(Package(**d))
    return pkgs


def hydrate_from_old(new_pkgs: List[Package], old_pkgs: List[Package]):
    new_pkgs = deepcopy(new_pkgs)
    for new_pkg in filter(lambda x: not x.sha256, new_pkgs):
        for old_pkg in old_pkgs:
            if (
                new_pkg.fetcher == old_pkg.fetcher
                and new_pkg.repo == old_pkg.repo
                and new_pkg.rev == old_pkg.rev
                and old_pkg.sha256
            ):
                new_pkg.sha256 = old_pkg.sha256

    return new_pkgs


def nix_prefetch_git(url: str, rev: str):
    result = subprocess.run(
        ["nix-prefetch-git", "--url", url, "--rev", rev, "--quiet"],
        capture_output=True,
        text=True,
    )
    if result.returncode > 0:
        if result.stderr:
            logging.debug(result.stderr)
        raise RuntimeError(result)
    return json.loads(result.stdout).get("sha256")


def nix_prefetch_gitlab(url: str, rev: str):
    eslug = url.replace(".", "%2E").replace("/", "%2F")
    erev = rev.replace("+", "%2B").replace("%", "%25").replace("/", "%2F")
    url = "https://gitlab.com/api/v4/projects/{}/repository/archive.tar.gz?sha={}".format(
        eslug, erev
    )
    result = subprocess.run(
        ["nix-prefetch-url", "--type", "sha256", "--unpack", url],
        capture_output=True,
        text=True,
    )
    if result.returncode > 0:
        if result.stderr:
            logging.debug(result.stderr)
        raise RuntimeError(result)
    return result.stdout.strip("\n")


def nix_prefetch_github(url: str, rev: str):
    url = "https://github.com/{}/archive/{}.tar.gz".format(url, rev)
    result = subprocess.run(
        ["nix-prefetch-url", "--type", "sha256", "--unpack", url],
        capture_output=True,
        text=True,
    )
    if result.returncode > 0:
        if result.stderr:
            logging.debug(result.stderr)
        raise RuntimeError(result)
    return result.stdout.strip("\n")


def find_hashes(pkgs: List[Package]):
    pkgs = deepcopy(pkgs)
    for pkg in pkgs:
        if pkg.sha256:
            continue
        try:
            if not pkg.repo or not pkg.rev:
                raise ValueError(f"Package {pkg.name} without repo and rev")
            if pkg.fetcher == "git":
                pkg.sha256 = nix_prefetch_git(pkg.repo, pkg.rev)
            elif pkg.fetcher == "github":
                pkg.sha256 = nix_prefetch_github(pkg.repo, pkg.rev)
            elif pkg.fetcher == "gitlab":
                pkg.sha256 = nix_prefetch_gitlab(pkg.repo, pkg.rev)
            else:
                raise Exception(
                    f"Unknown fetcher {pkg.fetcher} for package `{pkg.name}`"
                )
            logging.info(f"Found hash for `{pkg.name}`")
        except Exception as e:
            logging.error(f"Can't find hash: {e}")
    return pkgs


if __name__ == "__main__":
    root_path = get_project_root()
    all_pkgs = load_doom_packages(root_path) + [Package(**p) for p in additional_packages]
    all_pkgs_wo_bl = list(filter(lambda x: x.name not in blacklist, all_pkgs))
    unpinned_pkgs = get_unpinned(all_pkgs_wo_bl)
    for pkgname in unpinned_pkgs:
        logging.info(f"Package `{pkgname}` is unpinned")
    pkgs_wo_unpinned = list(
        filter(lambda x: x.name not in unpinned_pkgs, all_pkgs_wo_bl)
    )
    melpa_json = load_melpa_json(root_path)
    pkgs_with_melpa = hydrate_from_melpa(pkgs_wo_unpinned, melpa_json)
    pkgs_with_melpa2 = copy_vcs(pkgs_with_melpa)

    old_pkgs = load_old_data()
    pkgs_with_old_hashes = hydrate_from_old(pkgs_with_melpa2, old_pkgs)
    pkgs_with_hashes = find_hashes(pkgs_with_old_hashes)

    bad_filter = lambda x: not (x.fetcher and x.repo and x.rev and x.sha256)
    bad_pkgs = filter(
        bad_filter, pkgs_with_hashes
    )
    bad_pkgs_names = [x.name for x in bad_pkgs]
    for pkg in bad_pkgs:
        logging.warn(f"Package `{pkg.name}` doesn't have hash and ignored")

    good_pkgs = sorted(
        filter(lambda x: not bad_filter(x), pkgs_with_hashes),
        key=lambda x: x.name,
    )

    with open(pinned_file, "w") as f:
        json.dump([dataclasses.asdict(x) for x in good_pkgs], f, indent=2)
        f.write("\n")
    logging.debug("Completed! And saved.")
