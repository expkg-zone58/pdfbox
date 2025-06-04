# Pdfbox
A `BaseX` interface for the `Apache Pdfbox library` version 3. 

> The [Apache PDFBox® library](https://pdfbox.apache.org/) is an open source Java tool for working with PDF documents. This project allows creation of new PDF documents, manipulation of existing documents and the ability to extract content from documents.

This interface is packaged in the [Expath XAR](https://docs.basex.org/main/Repository#expath_packaging) format. The package includes the required Pdfbox jars.
A test suite is available and workflow actions run these tests against BaseX 10.7 and 11.7.

> [!NOTE]  
>Currently (v0.3.6) works with BaseX 9.7, but this may change with future versions.

## Features

The features focus on extracting information from PDFs rather than creation or editing of PDFs.
### Supported
* Read PDF page count.
* Read any PDF outline and return as map(s) or XML.
* Read pagelabels.
* Read page text.
* Save pdf page range to a new pdf.
* Create image of rendered pdf page.
* Open PDF with password.
* Read XMP metadata. 
* Page size information.
* Datatype xs:base64Binary in function inputs and outputs to facilitate database and store usage.

### Not supported:
* creating PDFs with new content
* Form processing

## Documentation
* Function [documentation](doc.md)  
* The Apache Pdfbox 3 [FAQ](https://pdfbox.apache.org/3.0/faq.html) may be useful.

# Install
Pre-built `pdfbox-x.y.z.zar` files are available on the [releases](../../releases) page. They can be installed using the standard respository functions or using the GUI.

# Usage
```xquery
import module namespace pdfbox="org.expkg_zone58.Pdfbox3";

pdfbox:with-pdf("...path/to/pdf.pdf",
 function($pdf){
  (1 to pdfbox:number-of-pages($pdf))!pdfbox:page-text($pdf,.)
 }
)
```

## Build

* `scripts/make-xar.xq` packages the required `jar`s and `xqm` files to a `xar` file in the `dist` folder.

The `package.json` is (ab)used as a configuration source. Non standard information is held in the `expkg_zone58` section. This is experimental and may change.

`package.json` contains script to run
1. The XAR build.
2. The tests
3. The documentation
### Action support

The workflow `ci-basex.yaml` builds and tests the package. This can be used as an action on [github](https://github.com/features/actions), or on a local [gitea](https://docs.gitea.com/usage/actions/overview) or [forgejo](https://forgejo.org/) installation.
