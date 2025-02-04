# Pdfbox
A BaseX interface for [Pdfbox](https://pdfbox.apache.org/) version 3. 
It is packaged using the [Expath](https://docs.basex.org/main/Repository#expath_packaging) format, and is tested against BaseX 10.7 and 11.7
## Features
* read PDF page count.
* read any PDF outline and return as maps or XML.
* read pagelabels.
* read page text.
* save pdf page range to a new pdf.
* save pdf page as an image.


## Build

* `scripts/make-xar.xq` packages the required `jar`s and `xqm` files to a `xar` file in the `dist` folder.

### Action support

The workflow `ci-basex.yaml` builds and tests the package. This can be used as an action on [github](https://github.com/features/actions), or on a local [gitea](https://docs.gitea.com/usage/actions/overview) installation.
