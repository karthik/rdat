
[![Build Status](https://travis-ci.org/ropensci/rdat.svg)](https://travis-ci.org/ropensci/rdat)

# rdat
[![dat](http://i.imgur.com/1iD2dEx.png)](http://dat-data.com/)

_Software is pre-alpha. Not yet ready for testing or use with real world data_

The `rdat` package provides an R wrapper to the [Dat project](https://github.com/maxogden/). Dat (`git` for data) is a framework for data versioning, replication and synchronisation, see [dat-data.com](http://dat-data.com/).

## Installation instructions

If you have not already installed `dat`, follow instructions here:

```
git clone https://github.com/maxogden/dat
cd dat
npm install .
sudo npm link
```

[More detailed instructions](https://github.com/maxogden/dat#install)

Then install the R package:

```r
library(devtools)
install_github("ropensci/rdat")
```

To quickly run through the examples

```r
library(rdat)
example(dat)
```

[![ropensci footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)


## API

This api is experimental and hasn't been finalized or implemented. Stay tuned for updates

#### init
```r
repo <- dat("cars", path = getwd())
```
Inits a dat in the current working directory

#### insert
```r
# insert some data
repo$insert(cars[1:20,])
v1 <- repo$status()$version
v1
```
Inserts data from a data frame and gets the dat at a particular hash.

```r
# insert more data
repo$insert(cars[21:25,])
v2 <- repo$status()$version
v2

```
Inserts more data

#### get
```r
data1 <- repo$get(v1)
data2 <- repo$get(v2)
```
Get particular versions of the dataset.

#### diff
```r
diff <- repo$diff(v1, v2)
diff$key
```
list changes in between versions

#### branching
```r
# create fork
repo$checkout(v1)
repo$insert(cars[40:42,])
repo$forks()
v3 <- repo$status()$version
```

Fork a dataset from a particular version into a new breanch.

#### checkout
```r
# go back
repo$checkout(v2)
repo$get()
```
Checkout the data at a particular version.

#### files
```r
# store binary attachements
repo$write(serialize(iris, NULL), "iris")
unserialize(repo$read("iris"))
```

Save binary data (files) as attachements to the dataset.

#### cloning
```r
# Create another repo
dir.create(newdir <- tempfile())
repo2 <- dat("cars", path = newdir, remote = repo$path())
repo2$forks()
repo2$get()
```

Specifying a path or url as `remote` will clone an existing repo. In this case we clone the previous repo into a new location.

#### push and pull
```r
# Create a third repo
dir.create(newdir <- tempfile())
repo3 <- dat("cars", path = newdir, remote = repo$path())
```
This makes yet another clone of our original repository

```r
#' # Sync 2 with 3 via remote (1)
#' repo2$insert(cars[31:40,])
#' repo2$push()
#' repo3$pull()
#'
#' # Verify that repositories are in sync
#' mydata2 <- repo2$get()
#' mydata3 <- repo3$get()
#' all.equal(mydata2, mydata3)
```
Add data in repo2 and then `push` it back to repo1. Then `pull` data back into repo3. 

