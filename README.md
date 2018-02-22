## Attention

This repository used to contain an R wrapper for an old version of `dat`. Meanwhile dat has changed a lot so this no longer works. 

[![Build Status](https://travis-ci.org/ropensci/rdat.svg)](https://travis-ci.org/ropensci/rdat)

# rdat
[![dat](http://i.imgur.com/1iD2dEx.png)](http://dat-data.com/)

_Software is in alpha stage. Not yet ready for use with real world data_

The `rdat` package provides an R wrapper to the [Dat project](https://github.com/maxogden/). Dat (`git` for data) is a framework for data versioning, replication and synchronisation, see [dat-data.com](http://dat-data.com/).



## Installation instructions

__Prerequisites:__ Instructions below require [R](http://cran.rstudio.com/), [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [nodejs (npm)](https://nodejs.org/download/).


### Installing `dat` stable

Install the latest stable version from npm:

```
sudo npm install -g dat
```

See [instructions](https://www.npmjs.com/package/dat#installation) for more details.


### Installing `dat` development version

If you have not already installed `dat` grab it from github:

```
git clone https://github.com/maxogden/dat ~/dat
cd ~/dat
npm install .
sudo npm link
```

To update an existing copy of `dat`

```
cd ~/dat
git pull
rm -Rf node_modules
npm install .
```

### Installing `rdat`

Then install the R package:

```r
library(devtools)
install_github("ropensci/rdat")
```

Run through the examples to verify that everything works:

```r
library(rdat)
example(dat)
```

## API

This api is experimental and hasn't been finalized or implemented. Stay tuned for updates

### init

When no `remote` is specified, `dat()` will init a new repository:

```r
repo <- dat("cars", path = getwd())
```

### insert

Inserts data from a data frame and gets the dat version key

```r
# insert some data
repo$insert(cars[1:20,])
v1 <- repo$status()$version
v1
```
Inserts more data, get a new version key

```r
# insert more data
repo$insert(cars[21:25,])
v2 <- repo$status()$version
v2

```

###  get

Retreive particular versions of the dataset from the key.

```r
data1 <- repo$get(v1)
data2 <- repo$get(v2)
```

### diff

List changes in between versions

```r
diff <- repo$diff(v1, v2)
diff$key
```

### branching

Fork a dataset from a particular version into a new branch.

```r
# create fork
repo$checkout(v1)
repo$insert(cars[40:42,])
repo$forks()
v3 <- repo$status()$version
```


### checkout

Checkout the data at a particular version.

```r
# go back to v2
repo$checkout(v2)
repo$get()
```

### binary data

Save binary data (files) as attachements to the dataset.

```r
# store binary attachements
repo$write(serialize(iris, NULL), "iris")
unserialize(repo$read("iris"))
```


### clone

```r
# Create another repo
dir.create(newdir <- tempfile())
repo2 <- dat("cars", path = newdir, remote = repo$path())
repo2$forks()
repo2$get()
```

Specifying a `remote` (path or url) to clone an existing repo. In this case we clone the previous repo into a new location.

### push and pull

Lets make yet another clone of our original repository

```r
# Create a third repo
dir.create(newdir <- tempfile())
repo3 <- dat("cars", path = newdir, remote = repo$path())
```

Add data in repo2 and then `push` it back to repo1.


```r
# Add some data and push to origin
repo2$insert(cars[31:40,])
repo2$push()
```

Then `pull` data back into repo3.

```r
# sync data with origin
repo3$pull()

# Verify that repositories are in sync
mydata2 <- repo2$get()
mydata3 <- repo3$get()
all.equal(mydata2, mydata3)
```


[![ropensci footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)


