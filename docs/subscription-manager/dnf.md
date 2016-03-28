---
title: DNF Package Manager
---
{% include toc.md %}

DNF will become the default package manager in Fedora 22 and beyond. We will need to ship DNF plugins equivalent to our yum plugins today.

# Initial Investigation

DNF's [plugin API](http://rpm-software-management.github.io/dnf/api_plugins.html) looks relatively straightforward compared to yum's.

It looks like plugins just need to be in the python path, install and examine 'dnf-plugins-core' for examples.

We should refactor code to core subscription-manager if it needs to be shared between the plugins.

We should take this opportunity to cleanup the plugin directory structure:

* src/plugins/yum/ - move contents of src/plugins/
* src/plugins/dnf/
* src/plugins/subscription_manager/ - move contents of src/content_plugins

Yum plugins currently are bundled up with the base subscription-manager package. Should we bundle dnf up here as well? Or split them out into sub-packages and deal with the wrangling that will need to be done to get them into appropriate base installations? Easier to just bundle provided the files are not harmful, but probably more correct to create sub-packages. Alternatively we could modify the spec file to only bundle DNF for Fedora 22+, otherwise yum.

Address the dependency on yum in our spec file. Conditional on RHEL / Fedora version?



## Product ID Yum Plugin

Our product-id.py yum plugin uses a posttrans hook, which looks like it maps to the DNF transaction() hook.

It passes along the yum 'base' object, which we use to get_enabled (repos), and get_active (repos). This looks to map to the [dnf base object](http://rpm-software-management.github.io/dnf/api_base.html)'s repos which is a [repodict](http://rpm-software-management.github.io/dnf/api_repos.html#dnf.repodict.RepoDict).

subscription_manager.productid.ProductManager will need to be updated to be less/not yum specific.

On the yum base object we make the following calls:

* yumbase.pkgSack.returnPackages() - lists all packages available (taking into account CLI enabled/disabled repos)
  * We then iterate the packages and read their 'repoid' attribute.
  * Check if they're installed: yumbase.rpmdb.searchNevra(pkgname, arch)
  * Should be repeatable in dnf with [base.sack.query()](http://rpm-software-management.github.io/dnf/api_queries.html#dnf.query.Query)
* yumbase.repos.listEnabled() - lists the enabled repositories
  * repo.retrieveMD(productid)
  * repo.id
  * dnf appears to expose the [metadata files](http://rpm-software-management.github.io/dnf/api_repos.html#dnf.repo.Metadata) as well.

## Subscription Manager Yum Plugin

Our subscription-manager.py yum plugin uses a postconfig hook, which looks like it maps to the DNF config() hook.

This plugin does not appear to use many yum internals, it's goal is just to trigger the generation of redhat.repo at the appropriate time.



