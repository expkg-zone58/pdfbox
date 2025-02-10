# Pdfbox
A BaseX interface for [Pdfbox](https://pdfbox.apache.org/) version 3. 
It is packaged using the [Expath](https://docs.basex.org/main/Repository#expath_packaging) format, and is tested against BaseX 10.7 and 11.7. Note: currently (v0.1.5) also works on V9.7

* The Pdfbox 3 [FAQ](https://pdfbox.apache.org/3.0/faq.html) may be useful.
## Features

The features focus on extracting information from PDFs rather than creation or editing.

* read PDF page count.
* read any PDF outline and return as map(s) or XML.
* read pagelabels.
* read page text.
* save pdf page range to a new pdf.
* save image of rendered pdf page.



# Install
Pre-built `pdfbox-x.y.z.zar` files are available on the releases page. They can be installed using the standard respository functions or using the GUI.

# Usage
```xquery
import module namespace pdfbox="org.expkg_zone58.Pdfbox3";

pdfbox:with-pdf("...path/to/pdf.pdf",
 function($pdf){
  (1 to pdfbox:page-count($pdf))!pdfbox:page-text($pdf,.)
 }
)
```

## Build

* `scripts/make-xar.xq` packages the required `jar`s and `xqm` files to a `xar` file in the `dist` folder.

### Action support

The workflow `ci-basex.yaml` builds and tests the package. This can be used as an action on [github](https://github.com/features/actions), or on a local [gitea](https://docs.gitea.com/usage/actions/overview) installation.
